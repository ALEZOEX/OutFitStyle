/// Cart entity for domain layer
class CartEntity {
  final String id;
  final int userId;
  final int itemCount;
  final double totalAmount;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.itemCount,
    required this.totalAmount,
  });
}
