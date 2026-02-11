// Domain (из общего слоя)
export '../../domain/entities/recommendation.dart';
export '../../domain/enums/recommendation_type.dart';
export '../../domain/enums/recommendation_source.dart';
export '../../domain/enums/outfit_weather.dart';
export '../../domain/repositories/recommendation_repository.dart';
export '../../domain/usecases/get_recommendations_usecase.dart';
export '../../domain/usecases/get_personalized_recommendations.dart';
export '../../domain/usecases/get_recommendations_by_occasion.dart';
export '../../domain/usecases/get_recommendations_by_weather.dart';
export '../../domain/usecases/save_recommendation_usecase.dart';

// Screens & Widgets
export 'recommendations_screen.dart';
export 'widgets/recommendation_card.dart';
export 'widgets/recommendation_detail_screen.dart';
export 'widgets/recommendation_feedback_dialog.dart';
export 'widgets/recommendation_filter_sheet.dart';
export 'widgets/recommendation_history_screen.dart';
export 'widgets/recommendation_stats_card.dart';
export 'widgets/saved_recommendations_screen.dart';
export 'widgets/user_preferences_screen.dart';
