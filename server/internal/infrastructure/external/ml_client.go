package external

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/pkg/errors"
)

type MLClient struct {
	baseURL string
	http    *http.Client
}

func NewMLClient(baseURL string, timeout time.Duration) *MLClient {
	return &MLClient{
		baseURL: baseURL,
		http:    &http.Client{Timeout: timeout},
	}
}

func (c *MLClient) Rank(ctx context.Context, req TZMLRankRequest) (TZMLRankResponse, error) {
	var out TZMLRankResponse

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal rank request")
	}

	u := fmt.Sprintf("%s/api/v1/rank", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("ml bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode response")
	}
	return out, nil
}
