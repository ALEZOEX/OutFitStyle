package domain

type RecommendationListQuery struct {
	FromDate   *string
	ToDate     *string
	Occasion   *string
	MinRating  *int
	IsFavorite *bool

	Page  int
	Limit int
}
