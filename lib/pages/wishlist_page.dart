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
  bool isLoading = true; // To track if wishlist is loading

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  // Load wishlist items from SharedPreferences
  Future<void> _loadWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<Map<String, dynamic>> loadedItems = [];
    for (String key in keys) {
      final productData = prefs.getString(key);
      if (productData != null) {
        loadedItems.add(jsonDecode(productData));
      }
    }

    setState(() {
      wishlistItems = loadedItems;
      isLoading = false; // Set loading to false when data is fetched
    });
  }

  // Refresh method to reload wishlist items
  Future<void> _refresh() async {
    setState(() {
      isLoading = true; // Set loading to true while fetching
    });
    await _loadWishlistItems(); // Reload the wishlist items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4.0,
        centerTitle: true, // Centers the title in the app bar
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false, // Removes the back icon
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while loading
          : wishlistItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Your wishlist is empty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(178, 0, 150, 135),
                              Color.fromARGB(255, 0, 120, 115),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                              50), // Rounded corners for the button
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(
                                  0.3), // Shadow effect for the button
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .transparent, // Make the background transparent to show gradient
                            padding: const EdgeInsets.all(
                                15), // Increase padding for better touch target
                            elevation:
                                0, // Set elevation to 0 because it's now handled by the container shadow
                          ),
                          onPressed: _refresh, // Reload the wishlist
                          child: const Icon(
                            Icons.refresh,
                            size: 30, // Larger icon for better visibility
                            color: Colors.white, // White icon color
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: RefreshIndicator(
                    onRefresh: _refresh, // Refresh the wishlist
                    child: ListView.builder(
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
                                  productDescription: item['description'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            elevation:
                                6, // Increased elevation for a better shadow effect
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Price: \$${item['price']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.redAccent,
                                  size: 28,
                                ),
                                onPressed: () {
                                  _removeFromWishlist(item['id']);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  // Method to remove item from wishlist
  Future<void> _removeFromWishlist(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(id);
    _loadWishlistItems(); // Reload the wishlist after removing an item
  }
}
