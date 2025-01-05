import 'package:flutter/material.dart';
import 'package:nahdy/components/app_localizations.dart';
import 'package:nahdy/components/cart_provider.dart';
import 'package:nahdy/pages/product_details_page.dart';
import 'package:provider/provider.dart';

Widget productCard(BuildContext context, String title, String imagePath,
    String price, String productId, String productDescription) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(
            title: title,
            imagePath: imagePath,
            price: price,
            productId: productId,
            productDescription: productDescription,
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
          const SizedBox(height: 10),
          Image.network(imagePath, height: 75, fit: BoxFit.cover),
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
              Provider.of<Cart>(context, listen: false).addProduct(
                productId,
                title,
                price,
                imagePath,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .translate('addedToCartMessage'))),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              AppLocalizations.of(context).translate('addToCart'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
