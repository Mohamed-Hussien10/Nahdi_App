import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nahdy/admin/product_card.dart';
import 'package:nahdy/components/app_localizations.dart';
import 'package:nahdy/pages/cart_page.dart';
import 'package:nahdy/pages/wishlist_page.dart';
import 'package:nahdy/pages/profile_page.dart'; // Import Profile Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  // Method to update the selected tab index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to handle the back button press
  Future<bool> _onWillPop() async {
    // Show a dialog to confirm if the user wants to exit the app
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).translate('exitAppTitle')),
            content:
                Text(AppLocalizations.of(context).translate('exitAppMessage')),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Don't exit
                child: Text(AppLocalizations.of(context).translate('no')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit
                child: Text(AppLocalizations.of(context).translate('yes')),
              ),
            ],
          ),
        )) ??
        false; // If the user doesn't select anything, don't exit
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context).translate;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop, // Trigger on back press
      child: Scaffold(
        // AppBar is shown only on the Home screen
        appBar: _selectedIndex == 0
            ? AppBar(
                title: Text(
                  t('appTitle'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.teal,
                elevation: 0,
              )
            : null, // No AppBar for other screens

        body: IndexedStack(
          index: _selectedIndex, // Control the page using selected index
          children: const [
            HomeContent(), // Home Page Content
            CartPage(), // Cart Page
            WishlistScreen(), // Wishlist Page
            ProfilePage(), // Profile Page
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type:
              BottomNavigationBarType.fixed, // Fixes the bar and centers items
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: t('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: t('cart'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: t('wishlist'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: t('profile'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = ''; // Track the selected category

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context).translate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner Section
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('welcomeMessage'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t('welcomeSubtitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar Section
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              labelText: t('searchPlaceholder'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Categories Section
          Text(
            t('categories'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                categoryCard(t('all'), Icons.all_inclusive),
                categoryCard(t('masks'), Icons.masks),
                categoryCard(t('gloves'), Icons.handshake),
                categoryCard(t('syringes'), Icons.local_hospital),
                categoryCard(t('thermometers'), Icons.thermostat),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Featured Products Section
          Text(
            t('featuredProducts'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Products Grid
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching products.'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No products available.'));
              } else {
                var filteredProducts = snapshot.data!.docs.where((product) {
                  var productName = product['name'].toString().toLowerCase();
                  var productCategory =
                      product['category'].toString().toLowerCase();
                  return productName.contains(searchQuery) &&
                      (selectedCategory.isEmpty ||
                          productCategory == selectedCategory.toLowerCase());
                }).toList();

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.80,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product = filteredProducts[index];
                    return productCard(
                      context,
                      product['name'],
                      product['image_url'],
                      product['price'].toString(),
                      product['productId'],
                      product['description'],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Category Card Widget
  Widget categoryCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title == 'All' ? '' : title;
        });
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedCategory == title ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 40,
                color: selectedCategory == title ? Colors.white : Colors.teal),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selectedCategory == title ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
