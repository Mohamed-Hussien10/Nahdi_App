import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  double price = 0.0;
  String description = '';
  String category = '';
  String imageUrl = '';
  bool isLoading = false; // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'Enter product\'s name'),
                  onChanged: (val) => setState(() => name = val),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Price', hintText: 'Enter product\'s price'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() => price = double.tryParse(val) ?? 0.0);
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(val) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter product\'s description'),
                  onChanged: (val) => setState(() => description = val),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'Enter product\'s category'),
                  onChanged: (val) => setState(() => category = val),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'Enter product\'s image URL'),
                  onChanged: (val) => setState(() => imageUrl = val),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    if (!Uri.parse(val).isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: isLoading // Disable button when loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true; // Set loading state
                            });
                            await addProductToFirestore();
                            setState(() {
                              isLoading = false; // Reset loading state
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: isLoading // Show loading indicator or text
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                              strokeWidth: 5,
                            ),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                          child: Text(
                            'Add Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addProductToFirestore() async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    await products.add({
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'image_url': imageUrl,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Product Added')));
  }
}
