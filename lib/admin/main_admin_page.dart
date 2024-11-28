import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:nahdy/admin/add_product_page.dart';
import 'package:nahdy/admin/customers_orders.dart';
import 'package:nahdy/admin/edit_product_page.dart';
import 'package:nahdy/pages/login_page.dart';

class MainAdminPage extends StatelessWidget {
  MainAdminPage({super.key});

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Page',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                // Sign out from Firebase
                await _auth.signOut();

                // Navigate to the login page after sign-out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                // Handle any errors during the sign-out process
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error signing out: $e")),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Welcome to the Admin Page',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 40),
            _buildButton(
              context,
              label: 'Add Products',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              label: 'Edit Products',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProductsPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              label: 'Customers\' Orders',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomersOrders()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Custom button widget for reusability and clean design
  Widget _buildButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 300, // Set your fixed width here
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.teal,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center, // Center the text within the button
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
