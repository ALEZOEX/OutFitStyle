package services

import (
	"context"
	"crypto/sha256"
	"encoding/binary"
	"encoding/json"
	"errors"
	"strings"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ExperimentService struct {
	repo repositories.ExperimentRepository
}

func NewExperimentService(r repositories.ExperimentRepository) *ExperimentService {
	return &ExperimentService{repo: r}
}

// Assign returns variant for user in running experiment (or "" if no experiment).
func (s *ExperimentService) Assign(ctx context.Context, experimentName string, userID domain.ID) (variant string, experimentID *domain.ID, err error) {
	experimentName = strings.TrimSpace(experimentName)
	if experimentName == "" {
		return "", nil, nil
	}

	exp, err := s.repo.GetRunningByName(ctx, experimentName)
	if err != nil || exp == nil {
		return "", nil, err
	}

	// user_percentage gate
	if exp.UserPercentage < 100 {
		if !inPercentage(userID.String()+"|"+exp.Name, exp.UserPercentage) {
			return "", &exp.ID, nil
		}
	}

	assigned, err := s.repo.GetAssignment(ctx, exp.ID, userID)
	if err != nil {
		return "", &exp.ID, err
	}
	if assigned != nil {
		return assigned.Variant, &exp.ID, nil
	}

	v, err := pickVariantFromList(userID.String()+"|"+exp.Name, exp.Variants)
	if err != nil {
		return "", &exp.ID, err
	}

	_ = s.repo.CreateAssignment(ctx, exp.ID, userID, v)
	return v, &exp.ID, nil
}

func (s *ExperimentService) Record(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string, eventName string, value *float64, data any) error {
	var b []byte
	if data != nil {
		b, _ = json.Marshal(data)
	}
	return s.repo.RecordEvent(ctx, experimentID, userID, variant, eventName, value, b)
}

func inPercentage(key string, pct int) bool {
	if pct <= 0 {
		return false
	}
	if pct >= 100 {
		return true
	}
	h := sha256.Sum256([]byte(key))
	n := int(binary.BigEndian.Uint32(h[:4]) % 100)
	return n < pct
}

func pickVariantFromList(key string, variants []string) (string, error) {
	if len(variants) == 0 {
		return "", errors.New("variants list is empty")
	}

	// Create a map with equal weights for all variants
	m := make(map[string]float64)
	for _, variant := range variants {
		m[variant] = 1.0 // Equal weight for all variants
	}

	return pickFromMap(key, m), nil
}

func pickVariant(key string, variantsJSON []byte) (string, error) {
	// поддержим 2 формата:
	// 1) map: {"control":50,"test":50}
	// 2) array: [{"name":"control","weight":50}, ...]
	if len(variantsJSON) == 0 {
		return "", errors.New("variants json is empty")
	}

	// try map
	var m map[string]float64
	if err := json.Unmarshal(variantsJSON, &m); err == nil && len(m) > 0 {
		return pickFromMap(key, m), nil
	}

	// try array
	var arr []struct {
		Name   string  `json:"name"`
		Weight float64 `json:"weight"`
	}
	if err := json.Unmarshal(variantsJSON, &arr); err == nil && len(arr) > 0 {
		m2 := map[string]float64{}
		for _, v := range arr {
			if v.Name != "" && v.Weight > 0 {
				m2[v.Name] = v.Weight
			}
		}
		if len(m2) == 0 {
			return "", errors.New("variants weights are empty")
		}
		return pickFromMap(key, m2), nil
	}

	// try simple string array
	var stringArr []string
	if err := json.Unmarshal(variantsJSON, &stringArr); err == nil && len(stringArr) > 0 {
		m3 := make(map[string]float64)
		for _, variant := range stringArr {
			m3[variant] = 1.0 // Equal weight for all variants
		}
		return pickFromMap(key, m3), nil
	}

	return "", errors.New("unsupported variants json format")
}

func pickFromMap(key string, m map[string]float64) string {
	total := 0.0
	for _, w := range m {
		if w > 0 {
			total += w
		}
	}
	if total <= 0 {
		// fallback: first key
		for k := range m {
			return k
		}
		return "control"
	}

	h := sha256.Sum256([]byte(key))
	rnd := float64(binary.BigEndian.Uint32(h[:4])) / float64(^uint32(0))
	x := rnd * total

	acc := 0.0
	for name, w := range m {
		if w <= 0 {
			continue
		}
		acc += w
		if x <= acc {
			return name
		}
	}
	for k := range m {
		return k
	}
	return "control"
}
