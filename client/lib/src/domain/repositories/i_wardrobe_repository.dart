abstract class IWardrobeRepository {
  Future<List<dynamic>> getAllItems();
  Future<void> addItem(dynamic item);
  Future<void> updateItem(dynamic item);
  Future<void> deleteItem(String id);
  Future<List<dynamic>> getItemsByCategory(String category);
  Future<List<dynamic>> getItemsByWeather(double minTemp, double maxTemp);
}