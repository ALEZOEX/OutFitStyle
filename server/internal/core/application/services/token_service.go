package services

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/hex"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"

	"outfitstyle/server/internal/core/domain"
)

// TokenService сервис для генерации и валидации JWT токенов
// Поддерживает как HS256 (симметричный), так и RS256 (асимметричный) алгоритмы
type TokenService struct {
	// Для HS256
	secret []byte
	
	// Для RS256
	privateKey *rsa.PrivateKey
	publicKey  *rsa.PublicKey
	
	// TTL токенов
	accessTTL  time.Duration
	refreshTTL time.Duration
	
	// Используемый алгоритм
	useRS256 bool
}

// AccessClaims claims для access токена
type AccessClaims struct {
	jwt.RegisteredClaims
	SessionID string `json:"sid"`
	JTI       string `json:"jti"` // JWT ID для возможности отзыва токена
}

// TokenServiceConfig конфигурация TokenService
type TokenServiceConfig struct {
	// Для HS256
	JWTSecret string
	
	// Для RS256
	PrivateKeyPath string
	PublicKeyPath  string
	
	// TTL
	AccessTTL  time.Duration
	RefreshTTL time.Duration
	
	// Использовать RS256 если true
	UseRS256 bool
}

// NewTokenService создает новый TokenService
// Если useRS256=true и ключи не найдены, генерирует новую пару RSA ключей
func NewTokenService(config TokenServiceConfig) (*TokenService, error) {
	service := &TokenService{
		accessTTL:  config.AccessTTL,
		refreshTTL: config.RefreshTTL,
		useRS256:   config.UseRS256,
	}
	
	if config.UseRS256 {
		// Загружаем или генерируем RSA ключи
		var err error
		service.privateKey, service.publicKey, err = loadOrGenerateRSAKeys(
			config.PrivateKeyPath,
			config.PublicKeyPath,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to load RSA keys: %w", err)
		}
	} else {
		// Используем HS256 с секретом
		service.secret = []byte(config.JWTSecret)
	}
	
	return service, nil
}

// loadOrGenerateRSAKeys загружает RSA ключи из файлов или генерирует новые
func loadOrGenerateRSAKeys(privateKeyPath, publicKeyPath string) (*rsa.PrivateKey, *rsa.PublicKey, error) {
	// Пытаемся загрузить существующие ключи
	privateKey, pubKey, err := loadRSAKeys(privateKeyPath, publicKeyPath)
	if err == nil {
		return privateKey, pubKey, nil
	}
	
	// Ключи не найдены, генерируем новые
	fmt.Printf("⚠️  RSA keys not found, generating new 2048-bit key pair...\n")
	fmt.Printf("   Private key: %s\n", privateKeyPath)
	fmt.Printf("   Public key:  %s\n", publicKeyPath)
	
	privateKey, pubKey, err = generateAndSaveRSAKeys(privateKeyPath, publicKeyPath)
	if err != nil {
		return nil, nil, err
	}
	
	fmt.Printf("✅ RSA keys generated successfully\n")
	return privateKey, pubKey, nil
}

// loadRSAKeys загружает существующие RSA ключи из файлов
func loadRSAKeys(privateKeyPath, publicKeyPath string) (*rsa.PrivateKey, *rsa.PublicKey, error) {
	privateKey, err := loadPrivateKey(privateKeyPath)
	if err != nil {
		return nil, nil, err
	}
	
	pubKey, err := loadPublicKey(publicKeyPath)
	if err != nil {
		return nil, nil, err
	}
	
	return privateKey, pubKey, nil
}

// generateAndSaveRSAKeys генерирует и сохраняет новую пару RSA ключей
func generateAndSaveRSAKeys(privateKeyPath, publicKeyPath string) (*rsa.PrivateKey, *rsa.PublicKey, error) {
	// Генерируем пару ключей 2048 бит
	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to generate RSA key: %w", err)
	}
	
	// Сохраняем приватный ключ (только для чтения владельцем)
	if err := savePrivateKey(privateKey, privateKeyPath); err != nil {
		return nil, nil, err
	}
	
	// Сохраняем публичный ключ
	if err := savePublicKey(&privateKey.PublicKey, publicKeyPath); err != nil {
		return nil, nil, err
	}
	
	return privateKey, &privateKey.PublicKey, nil
}

func (s *TokenService) AccessTTL() time.Duration  { return s.accessTTL }
func (s *TokenService) RefreshTTL() time.Duration { return s.refreshTTL }

// GenerateAccessToken генерирует access токен
func (s *TokenService) GenerateAccessToken(userID, sessionID domain.ID) (token string, expiresAt time.Time, err error) {
	now := time.Now()
	expiresAt = now.Add(s.accessTTL)

	// Security: генерируем уникальный JTI для возможности отзыва токена
	jti, err := generateJTI()
	if err != nil {
		return "", time.Time{}, fmt.Errorf("failed to generate JTI: %w", err)
	}

	claims := AccessClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID.String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			ID:        jti, // JTI для blacklist
		},
		SessionID: sessionID.String(),
		JTI:       jti,
	}

	var t *jwt.Token
	if s.useRS256 {
		t = jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
		token, err = t.SignedString(s.privateKey)
	} else {
		t = jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		token, err = t.SignedString(s.secret)
	}

	return token, expiresAt, err
}

// generateJTI генерирует уникальный идентификатор токена
func generateJTI() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

// ValidateAccessToken валидирует access токен и возвращает userID, sessionID и JTI
func (s *TokenService) ValidateAccessToken(tokenString string) (userID domain.ID, sessionID domain.ID, jti string, err error) {
	var methodName string

	if s.useRS256 {
		methodName = "RS256"
	} else {
		methodName = "HS256"
	}

	parser := jwt.NewParser(jwt.WithValidMethods([]string{methodName}))
	var claims AccessClaims

	_, err = parser.ParseWithClaims(tokenString, &claims, func(token *jwt.Token) (any, error) {
		// Проверяем алгоритм подписи
		if token.Method.Alg() != methodName {
			return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
		}

		if s.useRS256 {
			return s.publicKey, nil
		}
		return s.secret, nil
	})
	if err != nil {
		return domain.ID{}, domain.ID{}, "", err
	}

	if claims.Subject == "" || claims.SessionID == "" {
		return domain.ID{}, domain.ID{}, "", errors.New("missing claims")
	}

	userID, err = domain.ParseID(claims.Subject)
	if err != nil {
		return domain.ID{}, domain.ID{}, "", err
	}
	sessionID, err = domain.ParseID(claims.SessionID)
	if err != nil {
		return domain.ID{}, domain.ID{}, "", err
	}

	return userID, sessionID, claims.JTI, nil
}

// GenerateRefreshToken генерирует новый refresh токен
func (s *TokenService) GenerateRefreshToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(b), nil
}

// HashRefreshToken хеширует refresh токен для хранения в БД
func (s *TokenService) HashRefreshToken(refreshToken string) string {
	sum := sha256.Sum256([]byte(refreshToken))
	return hex.EncodeToString(sum[:])
}

// GetPublicKeyPEM возвращает публичный ключ в PEM формате
// Может использоваться другими сервисами для валидации токенов
func (s *TokenService) GetPublicKeyPEM() (string, error) {
	if !s.useRS256 {
		return "", errors.New("RS256 not enabled")
	}

	pubBytes, err := x509MarshalPKCS1PublicKey(s.publicKey)
	if err != nil {
		return "", err
	}

	pemBlock := &pem.Block{
		Type:  "RSA PUBLIC KEY",
		Bytes: pubBytes,
	}

	return string(pem.EncodeToMemory(pemBlock)), nil
}

// savePrivateKey сохраняет приватный ключ в файл
func savePrivateKey(privateKey *rsa.PrivateKey, filename string) error {
	privBytes := x509.MarshalPKCS1PrivateKey(privateKey)
	privPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: privBytes,
	})

	return os.WriteFile(filename, privPEM, 0600)
}

// savePublicKey сохраняет публичный ключ в файл
func savePublicKey(publicKey *rsa.PublicKey, filename string) error {
	pubBytes := x509.MarshalPKCS1PublicKey(publicKey)
	pubPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PUBLIC KEY",
		Bytes: pubBytes,
	})

	return os.WriteFile(filename, pubPEM, 0644)
}

// loadPrivateKey загружает приватный ключ из файла
func loadPrivateKey(filename string) (*rsa.PrivateKey, error) {
	// G304: Используем os.Root для ограничения доступа к файлам
	root := os.DirFS(".")
	file, err := root.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open private key file: %w", err)
	}
	defer file.(interface{ Close() error }).Close()

	pemBytes, err := io.ReadAll(file)
	if err != nil {
		return nil, fmt.Errorf("failed to read private key file: %w", err)
	}

	block, _ := pem.Decode(pemBytes)
	if block == nil {
		return nil, errors.New("failed to decode PEM block")
	}

	if block.Type != "RSA PRIVATE KEY" {
		return nil, fmt.Errorf("unexpected PEM block type: %s", block.Type)
	}

	return x509.ParsePKCS1PrivateKey(block.Bytes)
}

// loadPublicKey загружает публичный ключ из файла
func loadPublicKey(filename string) (*rsa.PublicKey, error) {
	// G304: Используем os.Root для ограничения доступа к файлам
	root := os.DirFS(".")
	file, err := root.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open public key file: %w", err)
	}
	defer file.(interface{ Close() error }).Close()

	pemBytes, err := io.ReadAll(file)
	if err != nil {
		return nil, fmt.Errorf("failed to read public key file: %w", err)
	}

	block, _ := pem.Decode(pemBytes)
	if block == nil {
		return nil, errors.New("failed to decode PEM block")
	}

	if block.Type != "RSA PUBLIC KEY" {
		return nil, fmt.Errorf("unexpected PEM block type: %s", block.Type)
	}

	return x509.ParsePKCS1PublicKey(block.Bytes)
}

// x509MarshalPKCS1PublicKey обёртка для marshalPublicKey
func x509MarshalPKCS1PublicKey(publicKey *rsa.PublicKey) ([]byte, error) {
	return x509.MarshalPKIXPublicKey(publicKey)
}
