package external

import (
	"context"
	"fmt"
	"io"
	"net/url"
	"path"
	"strings"
	"time"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"github.com/pkg/errors"
)

type S3Storage struct {
	client        *minio.Client
	bucket        string
	publicBaseURL string
	presignTTL    time.Duration
}

type S3Config struct {
	Endpoint      string
	Bucket        string
	AccessKey     string
	SecretKey     string
	Region        string // not used by minio client but keep for parity
	PublicBaseURL string
	PresignTTL    time.Duration
}

func NewS3Storage(cfg S3Config) (*S3Storage, error) {
	if cfg.Endpoint == "" || cfg.Bucket == "" || cfg.AccessKey == "" || cfg.SecretKey == "" {
		return nil, errors.New("S3 config is incomplete (S3_ENDPOINT/S3_BUCKET/S3_ACCESS_KEY/S3_SECRET_KEY)")
	}

	endpoint, secure, err := parseEndpoint(cfg.Endpoint)
	if err != nil {
		return nil, err
	}

	mc, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.AccessKey, cfg.SecretKey, ""),
		Secure: secure,
	})
	if err != nil {
		return nil, errors.Wrap(err, "init minio client")
	}

	return &S3Storage{
		client:        mc,
		bucket:        cfg.Bucket,
		publicBaseURL: strings.TrimRight(cfg.PublicBaseURL, "/"),
		presignTTL:    cfg.PresignTTL,
	}, nil
}

func (s *S3Storage) Bucket() string { return s.bucket }

// Put uploads stream to objectPath
func (s *S3Storage) Put(ctx context.Context, objectPath string, r io.Reader, size int64, contentType string) error {
	_, err := s.client.PutObject(ctx, s.bucket, objectPath, r, size, minio.PutObjectOptions{
		ContentType: contentType,
	})
	return errors.Wrap(err, "put object")
}

func (s *S3Storage) PresignGet(ctx context.Context, objectPath string, ttl time.Duration) (string, time.Time, error) {
	if ttl <= 0 {
		ttl = s.presignTTL
	}
	u, err := s.client.PresignedGetObject(ctx, s.bucket, objectPath, ttl, url.Values{})
	if err != nil {
		return "", time.Time{}, errors.Wrap(err, "presign get")
	}
	return u.String(), time.Now().Add(ttl), nil
}

func (s *S3Storage) PublicURL(objectPath string) (string, bool) {
	if s.publicBaseURL == "" {
		return "", false
	}
	// publicBaseURL + /bucket/objectPath OR publicBaseURL + /objectPath?
	// В проде обычно CDN настроен именно на bucket root, поэтому используем /objectPath.
	return s.publicBaseURL + "/" + strings.TrimLeft(path.Clean(objectPath), "/"), true
}

func parseEndpoint(raw string) (host string, secure bool, err error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", false, errors.New("empty S3 endpoint")
	}
	if strings.HasPrefix(raw, "http://") || strings.HasPrefix(raw, "https://") {
		u, e := url.Parse(raw)
		if e != nil {
			return "", false, errors.Wrap(e, "parse endpoint url")
		}
		secure = (u.Scheme == "https")
		return u.Host, secure, nil
	}
	// assume host:port
	secure = false
	return raw, secure, nil
}

func JoinObjectPath(parts ...string) string {
	pp := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.Trim(p, "/")
		if p != "" {
			pp = append(pp, p)
		}
	}
	return strings.Join(pp, "/")
}

func ExtFromContentType(ct string) string {
	ct = strings.ToLower(strings.TrimSpace(ct))
	switch ct {
	case "image/jpeg":
		return ".jpg"
	case "image/png":
		return ".png"
	case "image/webp":
		return ".webp"
	default:
		return ""
	}
}

func SafeFilename(name string) string {
	name = strings.TrimSpace(name)
	if name == "" {
		return "file"
	}
	// минимум sanitization
	name = strings.ReplaceAll(name, "/", "_")
	name = strings.ReplaceAll(name, "\\", "_")
	return name
}

func Must1[T any](v T, _ error) T { return v }

func sprintf(format string, a ...any) string { return fmt.Sprintf(format, a...) }