package catalog

import (
	"context"
	"outfitstyle/server/internal/ml"
)

// mlClassifierAdapter adapts ml.ClassifierClient to catalog.MLClassifierClient
type mlClassifierAdapter struct {
	client ml.ClassifierClient
}

// NewMLClassifierAdapter creates an adapter that wraps ml.ClassifierClient
func NewMLClassifierAdapter(client ml.ClassifierClient) MLClassifierClient {
	if client == nil {
		return nil
	}
	return &mlClassifierAdapter{client: client}
}

// ClassifyItem adapts the ml.ClassifierClient.ClassifyItem to catalog interface
func (a *mlClassifierAdapter) ClassifyItem(ctx context.Context, req *MLClassifyRequest) (*MLClassifyResponse, error) {
	// Convert catalog request to ml request
	mlReq := &ml.ClassifyRequest{
		Name:        req.Name,
		Subcategory: req.Subcategory,
		Materials:   req.Materials,
		Style:       req.Style,
	}

	// Call the underlying ML client
	mlResp, err := a.client.ClassifyItem(ctx, mlReq)
	if err != nil {
		return nil, err
	}

	// Convert ml response to catalog response
	return &MLClassifyResponse{
		Category:   mlResp.Category,
		Confidence: mlResp.Confidence,
	}, nil
}
