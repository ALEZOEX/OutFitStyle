package services

import (
	"context"
	"errors"
	"io"
	"time"

	"github.com/google/uuid"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

type FileService struct {
	storage *external.S3Storage
	files   repositories.UploadedFilesRepository
	users   repositories.UserRepository
}

func NewFileService(storage *external.S3Storage, files repositories.UploadedFilesRepository, users repositories.UserRepository) *FileService {
	return &FileService{storage: storage, files: files, users: users}
}

type UploadResult struct {
	URL  string    `json:"url"`
	Path string    `json:"path"`
	FileID domain.ID `json:"file_id"`
}

func (s *FileService) UploadAvatar(ctx context.Context, userID domain.ID, filename string, contentType string, size int64, r io.Reader) (*UploadResult, error) {
	if s.storage == nil {
		return nil, errors.New("storage not configured")
	}
	if size <= 0 || size > 10*1024*1024 {
		return nil, errors.New("file too large (max 10MB)")
	}
	ext := external.ExtFromContentType(contentType)
	if ext == "" {
		return nil, errors.New("unsupported content type (jpeg/png/webp)")
	}

	objectPath := external.JoinObjectPath("avatars", userID.String(), uuid.NewString()+ext)
	if err := s.storage.Put(ctx, objectPath, r, size, contentType); err != nil {
		return nil, err
	}

	// записываем uploaded_files
	uid := userID
	fileID, _ := s.files.Create(ctx, &uid, s.storage.Bucket(), objectPath, external.SafeFilename(filename), contentType, size)

	// вычисляем URL
	url, ok := s.storage.PublicURL(objectPath)
	if !ok {
		// fallback: signed (будет истекать)
		u, _, err := s.storage.PresignGet(ctx, objectPath, 24*time.Hour)
		if err != nil {
			return nil, err
		}
		url = u
	}

	// обновляем users.avatar_url
	u, err := s.users.GetUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, errors.New("user not found")
	}
	u.AvatarURL = &url
	if err := s.users.UpdateUser(ctx, u); err != nil {
		return nil, err
	}

	return &UploadResult{URL: url, Path: objectPath, FileID: fileID}, nil
}