import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistIcon extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productDescription;
  final Function(bool)? onWishlistChanged; // Optional callback for changes

  const WishlistIcon({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
    this.onWishlistChanged,
  });

  @override
  _WishlistIconState createState() => _WishlistIconState();
}

class _WishlistIconState extends State<WishlistIcon> {
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _loadWishlistStatus();
  }

  // Load wishlist status from SharedPreferences
  Future<void> _loadWishlistStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final productData = prefs.getString(widget.productId);

    setState(() {
      // Set isWishlisted based on whether productData exists
      isWishlisted = productData != null;
    });
  }

  // Toggle wishlist status and save product data to SharedPreferences
  Future<void> _toggleWishlistStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final newStatus = !isWishlisted;

    setState(() {
      isWishlisted = newStatus;
    });

    if (newStatus) {
      // Add product to wishlist
      final productData = jsonEncode({
        'id': widget.productId,
        'name': widget.productName,
        'image': widget.productImage,
        'price': widget.productPrice,
        'description': widget.productDescription,
      });
      await prefs.setString(widget.productId, productData);
    } else {
      // Remove product from wishlist
      await prefs.remove(widget.productId);
    }

    if (widget.onWishlistChanged != null) {
      widget.onWishlistChanged!(newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: const BoxDecoration(
        color: Color(0xffE8E8E8),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: IconButton(
        icon: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: isWishlisted ? Colors.red : Colors.grey,
          size: 35,
        ),
        onPressed: _toggleWishlistStatus,
      ),
    );
  }
}
