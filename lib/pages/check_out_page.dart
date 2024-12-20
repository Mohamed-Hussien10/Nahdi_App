import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:nahdy/pages/order_details_page.dart'; // Your Order Details Page

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _recipientNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    // Get Firestore instance
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user == null) {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order')),
      );
      return;
    }

    // Create order data
    final orderData = {
      'userId': user.uid, // Add user ID to the order
      'recipientName': _recipientNameController.text,
      'address': _addressController.text,
      'phoneNumber': _phoneNumberController.text,
      'cartItems': widget.cartItems,
      'storeName': 'Al-nahdi',
      'status': 'pending', // Add initial order status
      'timestamp':
          FieldValue.serverTimestamp(), // Optional: Timestamp for ordering
    };

    try {
      // Save the order to the 'orders' collection
      await firestore.collection('orders').add(orderData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Navigate to Order Details Page after saving
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            recipientName: _recipientNameController.text,
            address: _addressController.text,
            phoneNumber: _phoneNumberController.text,
            cartItems: widget.cartItems,
            storeName: 'Al-nahdi',
          ),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Information',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('Recipient Name',
                        style: TextStyle(fontSize: 16)),
                    TextFormField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter recipient name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a recipient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Address', style: TextStyle(fontSize: 16)),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter delivery address',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Phone Number', style: TextStyle(fontSize: 16)),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter phone number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Method: Pay on Delivery',
                      style: TextStyle(fontSize: 18, color: Colors.teal),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Save order to Firestore
                            await _saveOrder();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                          child: Text(
                            'Confirm Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
