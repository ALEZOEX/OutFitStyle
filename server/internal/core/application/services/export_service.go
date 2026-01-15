package services

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

type ExportService struct {
	exportRepo repositories.ExportRepository
	filesRepo  repositories.UploadedFilesRepository
	storage    *external.S3Storage
}

func NewExportService(er repositories.ExportRepository, fr repositories.UploadedFilesRepository, storage *external.S3Storage) *ExportService {
	return &ExportService{exportRepo: er, filesRepo: fr, storage: storage}
}

type ExportResponse struct {
	DownloadURL string    `json:"download_url"`
	ExpiresAt   time.Time `json:"expires_at"`
}

func (s *ExportService) ExportUserData(ctx context.Context, userID domain.ID) (*ExportResponse, error) {
	if s.storage == nil {
		return nil, errors.New("storage not configured")
	}

	payload, err := s.exportRepo.BuildUserExport(ctx, userID)
	if err != nil {
		return nil, err
	}

	b, err := json.MarshalIndent(payload, "", "  ")
	if err != nil {
		return nil, err
	}

	objectPath := external.JoinObjectPath("exports", userID.String(), time.Now().UTC().Format("20060102T150405Z")+"-"+uuid.NewString()+".json")

	if err := s.storage.Put(ctx, objectPath, bytes.NewReader(b), int64(len(b)), "application/json"); err != nil {
		return nil, err
	}

	uid := userID
	_, _ = s.filesRepo.Create(ctx, &uid, s.storage.Bucket(), objectPath, "export.json", "application/json", int64(len(b)))

	url, expiresAt, err := s.storage.PresignGet(ctx, objectPath, 0)
	if err != nil {
		return nil, err
	}

	return &ExportResponse{DownloadURL: url, ExpiresAt: expiresAt}, nil
}
