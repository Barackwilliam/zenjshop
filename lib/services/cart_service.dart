import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  bool isInCart(String productId) {
    return _items.any((item) => item.product.productId == productId);
  }

  void addToCart(ProductModel product) {
    final index = _items.indexWhere(
      (item) => item.product.productId == product.productId,
    );
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.productId == productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere(
      (item) => item.product.productId == productId,
    );
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere(
      (item) => item.product.productId == productId,
    );
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _items
        .map(
          (item) => {
            'productId': item.product.productId,
            'name': item.product.name,
            'price': item.product.price,
            'quantity': item.quantity,
            'total': item.total,
          },
        )
        .toList();
  }
}
