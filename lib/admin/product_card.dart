import 'package:flutter/material.dart';
import 'package:nahdy/pages/product_details_page.dart';

Widget productCard(
    BuildContext context, String title, String imagePath, String price) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(
            title: title,
            imagePath: imagePath,
            price: price,
          ),
        ),
      );
    },
    child: Container(
      width: 180,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(imagePath, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '$price \$',
            style: const TextStyle(fontSize: 14, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Add to Cart functionality
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    ),
  );
}
