import 'package:equatable/equatable.dart';

/// Cart item model
class CartItem extends Equatable {
  final String productId;
  final String? size;
  final String? color;
  final int quantity;
  final double price;
  final String? productName;
  final String? productImage;

  const CartItem({
    required this.productId,
    this.size,
    this.color,
    required this.quantity,
    required this.price,
    this.productName,
    this.productImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] as String,
      size: json['size'] as String?,
      color: json['color'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      productName: json['product_name'] as String?,
      productImage: json['product_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
      'product_name': productName,
      'product_image': productImage,
    };
  }

  double get total => price * quantity;

  @override
  List<Object?> get props => [
        productId,
        size,
        color,
        quantity,
        price,
        productName,
        productImage,
      ];

  CartItem copyWith({
    String? productId,
    String? size,
    String? color,
    int? quantity,
    double? price,
    String? productName,
    String? productImage,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
    );
  }
}

/// Cart model
class Cart extends Equatable {
  final String id;
  final int userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime updatedAt;

  const Cart({
    this.id = '',
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Cart(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as int,
      items: itemsJson
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [id, userId, items, totalAmount, updatedAt];

  Cart copyWith({
    String? id,
    int? userId,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Add to cart request
class AddToCartRequest {
  final String productId;
  final String? size;
  final String? color;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.size,
    this.color,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }
}
