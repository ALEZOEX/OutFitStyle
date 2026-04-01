// Пакет jwtutil предоставляет утилиты для работы с JWT токенами
// Включая генерацию RSA ключей для RS256 подписывания
package jwtutil

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"os"
)

// RSAKeyPair содержит приватный и публичный ключи
type RSAKeyPair struct {
	PrivateKey *rsa.PrivateKey
	PublicKey  *rsa.PublicKey
}

// GenerateRSAKeyPair генерирует новую пару RSA ключей
// Рекомендуется использовать 2048 или 4096 бит для production
func GenerateRSAKeyPair(bits int) (*RSAKeyPair, error) {
	if bits < 2048 {
		bits = 2048 // Минимальная безопасная длина
	}

	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
	if err != nil {
		return nil, fmt.Errorf("failed to generate private key: %w", err)
	}

	return &RSAKeyPair{
		PrivateKey: privateKey,
		PublicKey:  &privateKey.PublicKey,
	}, nil
}

// PrivateKeyToPEM конвертирует приватный ключ в PEM формат
func PrivateKeyToPEM(privateKey *rsa.PrivateKey) []byte {
	privBytes := x509.MarshalPKCS1PrivateKey(privateKey)
	return pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: privBytes,
	})
}

// PublicKeyToPEM конвертирует публичный ключ в PEM формат
func PublicKeyToPEM(publicKey *rsa.PublicKey) []byte {
	pubBytes := x509.MarshalPKCS1PublicKey(publicKey)
	return pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PUBLIC KEY",
		Bytes: pubBytes,
	})
}

// PrivateKeyFromPEM загружает приватный ключ из PEM
func PrivateKeyFromPEM(pemBytes []byte) (*rsa.PrivateKey, error) {
	block, _ := pem.Decode(pemBytes)
	if block == nil {
		return nil, errors.New("failed to decode PEM block")
	}

	if block.Type != "RSA PRIVATE KEY" {
		return nil, fmt.Errorf("unexpected PEM block type: %s", block.Type)
	}

	return x509.ParsePKCS1PrivateKey(block.Bytes)
}

// PublicKeyFromPEM загружает публичный ключ из PEM
func PublicKeyFromPEM(pemBytes []byte) (*rsa.PublicKey, error) {
	block, _ := pem.Decode(pemBytes)
	if block == nil {
		return nil, errors.New("failed to decode PEM block")
	}

	if block.Type != "RSA PUBLIC KEY" {
		return nil, fmt.Errorf("unexpected PEM block type: %s", block.Type)
	}

	return x509.ParsePKCS1PublicKey(block.Bytes)
}

// SavePrivateKeyToFile сохраняет приватный ключ в файл
func SavePrivateKeyToFile(privateKey *rsa.PrivateKey, filename string, perm os.FileMode) error {
	pemBytes := PrivateKeyToPEM(privateKey)
	return os.WriteFile(filename, pemBytes, perm)
}

// SavePublicKeyToFile сохраняет публичный ключ в файл
func SavePublicKeyToFile(publicKey *rsa.PublicKey, filename string, perm os.FileMode) error {
	pemBytes := PublicKeyToPEM(publicKey)
	return os.WriteFile(filename, pemBytes, perm)
}

// LoadPrivateKeyFromFile загружает приватный ключ из файла
func LoadPrivateKeyFromFile(filename string) (*rsa.PrivateKey, error) {
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
	return PrivateKeyFromPEM(pemBytes)
}

// LoadPublicKeyFromFile загружает публичный ключ из файла
func LoadPublicKeyFromFile(filename string) (*rsa.PublicKey, error) {
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
	return PublicKeyFromPEM(pemBytes)
}

// GenerateAndSaveKeys генерирует новую пару ключей и сохраняет в файлы
// Возвращает пути к файлам или ошибку
func GenerateAndSaveKeys(privateKeyPath, publicKeyPath string, bits int) (string, string, error) {
	keyPair, err := GenerateRSAKeyPair(bits)
	if err != nil {
		return "", "", err
	}

	if err := SavePrivateKeyToFile(keyPair.PrivateKey, privateKeyPath, 0600); err != nil {
		return "", "", fmt.Errorf("failed to save private key: %w", err)
	}

	if err := SavePublicKeyToFile(keyPair.PublicKey, publicKeyPath, 0644); err != nil {
		return "", "", fmt.Errorf("failed to save public key: %w", err)
	}

	return privateKeyPath, publicKeyPath, nil
}
