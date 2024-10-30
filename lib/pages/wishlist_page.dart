import 'package:flutter/material.dart';
import 'package:nahdy/pages/product_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  // Load wishlist items from SharedPreferences
  Future<void> _loadWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    setState(() {
      wishlistItems = keys
          .map((key) {
            final productData = prefs.getString(key);
            return productData != null ? jsonDecode(productData) : null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: wishlistItems.isEmpty
          ? const Center(child: Text('No items in your wishlist'))
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                          title: item['name'],
                          imagePath: item['image'],
                          price: item['price'].toString(),
                          productId: item['id'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 182, 181, 181),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: ListTile(
                        leading: Image.network(item['image']),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.redAccent,
                            size: 33,
                          ),
                          onPressed: () {
                            _removeFromWishlist(item['id']);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

// Method to remove item from wishlist
  Future<void> _removeFromWishlist(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(id); // Remove the item by its ID
    _loadWishlistItems(); // Reload the wishlist items
  }
}
