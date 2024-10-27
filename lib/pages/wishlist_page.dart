import 'package:flutter/material.dart';
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
                  onTap: () {},
                  child: ListTile(
                    leading: Image.network(item['image']),
                    title: Text(item['name']),
                  ),
                );
              },
            ),
    );
  }
}
