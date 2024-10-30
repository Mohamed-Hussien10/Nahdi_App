import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  // Add a product with an initial quantity
  void addProduct(String id, String title, String price, String imagePath) {
    double doublePrice = double.parse(price);
    final existingIndex = _items.indexWhere((item) => item['id'] == id);
    if (existingIndex >= 0) {
      _items[existingIndex]['quantity'] += 1;
    } else {
      _items.add({
        'id': id,
        'title': title,
        'price': doublePrice,
        'imagePath': imagePath,
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  // Update item quantity and remove if quantity is zero
  void updateItemQuantity(Map<String, dynamic> item, int quantity) {
    if (quantity <= 0) {
      _items.remove(item);
    } else {
      item['quantity'] = quantity;
    }
    notifyListeners();
  }

  // Calculate total price
  double get totalPrice {
    return _items.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }
}
