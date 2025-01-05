import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:nahdy/components/app_localizations.dart';
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
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('order_placed_successfully'))),
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
    var t = AppLocalizations.of(context).translate;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('checkout')),
      ),
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
                    Text(
                      t('delivery_information'),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(t('recipient_name'),
                        style: const TextStyle(fontSize: 16)),
                    TextFormField(
                      controller: _recipientNameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: t('enter_recipient_name'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a recipient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(t('address'), style: const TextStyle(fontSize: 16)),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: t('enter_address'),
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
                    Text(t('phone_number'),
                        style: const TextStyle(fontSize: 16)),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: t('enter_phone_number'),
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
                    Text(
                      t('payment_method'),
                      style: const TextStyle(fontSize: 18, color: Colors.teal),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                          child: Text(
                            t('confirm_order'),
                            style: const TextStyle(
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
