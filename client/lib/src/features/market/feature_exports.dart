/// Market feature exports
library;

// Data
export 'data/market_api_client.dart';
export 'data/market_repository.dart';

// Models
export 'data/models/product.dart';
export 'data/models/cart.dart';
export 'data/models/order.dart';

// Domain
export 'domain/entities/product_entity.dart';
export 'domain/entities/cart_entity.dart';
export 'domain/entities/order_entity.dart';

// Presentation
export 'presentation/providers/market_provider.dart';
export 'presentation/providers/cart_provider.dart';

// Screens
export 'screens/market_screen.dart';
export 'screens/product_detail_screen.dart';
export 'screens/cart_screen.dart';
export 'screens/checkout_screen.dart';
export 'screens/orders_screen.dart';

// Widgets
export 'widgets/product_card.dart';
export 'widgets/cart_item_card.dart';
export 'widgets/order_card.dart';
