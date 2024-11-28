import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart'; // Replace with the path to your Product model file

class EditProductsPage extends StatefulWidget {
  @override
  _EditProductsPageState createState() => _EditProductsPageState();
}

class _EditProductsPageState extends State<EditProductsPage> {
  late Future<List<Product>> futureProducts;
  List<Product> allProducts = []; // List to hold all products for filtering
  List<Product> displayedProducts = []; // List to hold filtered products
  TextEditingController searchController =
      TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
    searchController
        .addListener(_filterProducts); // Listen for changes in the search input
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final products =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      setState(() {
        allProducts = products; // Store the fetched products
        displayedProducts = products; // Initially show all products
      });
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Refresh method that will be triggered by pulling down the list
  Future<void> refreshProductList() async {
    setState(() {
      futureProducts = fetchProducts(); // Re-fetch products when refreshing
    });
  }

  // Function to delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      setState(() {
        futureProducts = fetchProducts(); // Re-fetch products after deletion
      });
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  // Function to filter products based on the search query
  void _filterProducts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      displayedProducts = allProducts.where((product) {
        return product.name
            .toLowerCase()
            .contains(query); // Filter by product name
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          } else {
            return RefreshIndicator(
              onRefresh:
                  refreshProductList, // Call refresh when the list is pulled down
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by product name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: ListView.builder(
                          itemCount: displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayedProducts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 6),
                              child: ListTile(
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text('\$${product.price}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.teal),
                                      onPressed: () {
                                        // Navigate to the product edit screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProductScreen(
                                              product: product,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        // Call deleteProduct when the delete icon is tapped
                                        deleteProduct(product.productId);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  final Product product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController imageUrlController;
  bool isLoading = false; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    stockController =
        TextEditingController(text: widget.product.stock.toString());
    imageUrlController = TextEditingController(text: widget.product.imageUrl);
  }

  Future<void> updateProduct() async {
    setState(() {
      isLoading = true; // Set loading to true when the update starts
    });

    try {
      final productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.productId);

      await productRef.update({
        'name': nameController.text,
        'price': double.parse(priceController.text),
        'stock': int.parse(stockController.text),
        'imageUrl': imageUrlController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading to false when the update completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : updateProduct, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Show loading indicator when updating
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
