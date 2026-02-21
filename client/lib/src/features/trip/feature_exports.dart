/// Trip feature exports
library;

// Domain
export 'domain/entities/trip.dart';
export 'domain/repositories/trip_repository.dart';

// Data
export 'data/models/trip_dto.dart';
export 'data/datasources/trip_remote_data_source.dart';
export 'data/repositories/trip_repository_impl.dart';

// Presentation
export 'presentation/providers/trip_providers.dart';
export 'presentation/pages/trip_list_page.dart';
export 'presentation/pages/trip_detail_page.dart';
export 'presentation/pages/trip_create_page.dart';
export 'presentation/pages/add_items_page.dart';
export 'presentation/widgets/trip_card.dart';
export 'presentation/widgets/trip_status_badge.dart';
export 'presentation/trip_screen.dart';
