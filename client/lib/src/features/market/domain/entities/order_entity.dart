/// Order entity for domain layer
class OrderEntity {
  final String id;
  final int userId;
  final String status;
  final double totalAmount;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
  });
}
