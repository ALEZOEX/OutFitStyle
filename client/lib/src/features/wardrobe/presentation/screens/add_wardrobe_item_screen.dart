// AddWardrobeItemScreen с поддержкой всех платформ
// Использует conditional imports для определения платформы
export 'add_wardrobe_item_screen_io.dart'
    if (dart.library.html) 'add_wardrobe_item_screen_web.dart';
