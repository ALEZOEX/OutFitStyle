package domain

type SortOrder string

const (
	SortAsc  SortOrder = "asc"
	SortDesc SortOrder = "desc"
)

type WardrobeListQuery struct {
	Category   *string
	Style      *string
	Season     *string
	IsFavorite *bool
	IsArchived *bool
	Search     *string

	Sort  string    // updated_at|created_at|wear_count|name
	Order SortOrder // asc|desc

	Page  int
	Limit int
}