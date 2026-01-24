package services

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"path"
	"time"

	"github.com/google/uuid"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

// ErrStorageNotConfigured ошибка, когда хранилище не настроено
var ErrStorageNotConfigured = errors.New("storage not configured")

// Константы для экспорта данных
const (
	contentTypeJSON     = "application/json" // Тип контента для JSON-файлов
	presignTTLSeconds   = 3600               // Время жизни подписанного URL (1 час)
	exportTimeKeyLayout = "20060102T150405Z" // Формат времени для ключа экспорта
)

// ExportService сервис для экспорта пользовательских данных
type ExportService struct {
	exportRepo repositories.ExportRepository        // Репозиторий для экспорта данных
	filesRepo  repositories.UploadedFilesRepository // Репозиторий для работы с загруженными файлами
	storage    *external.S3Storage                 // Хранилище для сохранения файлов
}

// NewExportService создает новый экземпляр сервиса экспорта данных
func NewExportService(
	er repositories.ExportRepository,
	fr repositories.UploadedFilesRepository,
	storage *external.S3Storage,
) *ExportService {
	return &ExportService{
		exportRepo: er,
		filesRepo:  fr,
		storage:    storage,
	}
}

// ExportResponse структура ответа на запрос экспорта данных
type ExportResponse struct {
	DownloadURL string    `json:"download_url"` // URL для скачивания экспортированных данных
	ExpiresAt   time.Time `json:"expires_at"`   // Время истечения срока действия URL
}

// ExportUserData экспортирует данные пользователя в JSON-файл и сохраняет в хранилище
// Возвращает URL для скачивания и время истечения срока действия
func (s *ExportService) ExportUserData(ctx context.Context, userID domain.ID) (*ExportResponse, error) {
	// Проверяем, что хранилище настроено
	if s.storage == nil {
		return nil, ErrStorageNotConfigured
	}

	// Проверяем, что ID пользователя не является нулевым
	if userID == domain.NilID {
		return nil, fmt.Errorf("invalid user ID: %v", userID)
	}

	// Получаем данные пользователя для экспорта
	payload, err := s.exportRepo.BuildUserExport(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("build user export: %w", err)
	}

	// Маршалим данные в JSON с отступами
	b, err := json.MarshalIndent(payload, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("marshal export data: %w", err)
	}

	// Генерируем уникальное имя файла
	now := time.Now().UTC()
	objectName := fmt.Sprintf("%s-%s.json", now.Format(exportTimeKeyLayout), uuid.NewString())
	objectPath := external.JoinObjectPath("exports", userID.String(), objectName)

	// Сохраняем файл в хранилище
	size := int64(len(b))
	if err := s.storage.Put(ctx, objectPath, bytes.NewReader(b), size, contentTypeJSON); err != nil {
		return nil, fmt.Errorf("store export data: %w", err)
	}

	// Извлекаем имя файла из пути объекта
	filename := path.Base(objectPath)

	// Создаем запись о файле в базе данных
	if _, err := s.filesRepo.Create(ctx, &userID, s.storage.Bucket(), objectPath, filename, contentTypeJSON, size); err != nil {
		// Логируем ошибку, но не прерываем операцию экспорта
		log.Printf("export: failed to create file record (user=%s, key=%s): %v", userID.String(), objectPath, err)
	}

	// Генерируем подписанный URL для скачивания
	url, expiresAt, err := s.storage.PresignGet(ctx, objectPath, presignTTLSeconds)
	if err != nil {
		return nil, fmt.Errorf("generate presigned url: %w", err)
	}

	return &ExportResponse{
		DownloadURL: url,
		ExpiresAt:   expiresAt,
	}, nil
}
