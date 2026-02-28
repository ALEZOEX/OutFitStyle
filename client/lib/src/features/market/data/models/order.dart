import 'package:equatable/equatable.dart';

/// Order status enum
enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'В обработке';
      case OrderStatus.paid:
        return 'Оплачен';
      case OrderStatus.shipped:
        return 'Отправлен';
      case OrderStatus.delivered:
        return 'Доставлен';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }
}

/// Order item model
class OrderItem extends Equatable {
  final String productId;
  final String? size;
  final String? color;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    this.size,
    this.color,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      size: json['size'] as String?,
      color: json['color'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
    };
  }

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, size, color, quantity, price];
}

/// Order model
class Order extends Equatable {
  final String id;
  final int userId;
  final OrderStatus status;
  final double totalAmount;
  final List<OrderItem> items;
  final Map<String, dynamic>? shippingAddress;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.items,
    this.shippingAddress,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as int,
      status: OrderStatus.fromString(json['status'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: itemsJson
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status.name,
      'total_amount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        totalAmount,
        items,
        shippingAddress,
        paymentMethod,
        createdAt,
        updatedAt,
      ];

  Order copyWith({
    String? id,
    int? userId,
    OrderStatus? status,
    double? totalAmount,
    List<OrderItem>? items,
    Map<String, dynamic>? shippingAddress,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Create order request
class CreateOrderRequest {
  final Map<String, dynamic> shippingAddress;
  final String paymentMethod;

  CreateOrderRequest({
    required this.shippingAddress,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
    };
  }
}
