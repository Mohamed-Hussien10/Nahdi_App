import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productId;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final int stock;

  Product({
    required this.productId,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      productId: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] ?? 0.0,
      stock: data['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'stock': stock,
    };
  }
}
