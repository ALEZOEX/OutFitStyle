// Domain entities
export '../../domain/entities/achievement.dart';
export '../../domain/entities/user_achievement_status.dart';

// Domain enums
export '../../domain/enums/achievement_type.dart';
export '../../domain/enums/achievement_status.dart';

// Data layer
export 'data/repositories/achievements_repository_impl.dart';
export 'data/repositories/achievement_definitions.dart';
export 'data/services/achievements_api_service.dart';
export 'data/models/achievement_dto.dart';

// Presentation - Pages
export 'presentation/pages/achievements_page.dart';
export 'presentation/pages/achievement_detail_page.dart';

// Presentation - Widgets
export 'presentation/widgets/achievement_card_widget.dart';
export 'presentation/widgets/achievement_card.dart';
export 'presentation/widgets/achievement_list_widget.dart';
export 'presentation/widgets/achievement_category_tab.dart';
export 'presentation/widgets/achievement_icon.dart';
export 'presentation/widgets/achievement_badge.dart';

// Presentation - Providers
export 'presentation/providers/achievements_providers.dart';

// Presentation - Services
export 'presentation/services/achievement_notification_service.dart';
