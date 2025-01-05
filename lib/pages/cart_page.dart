import 'package:flutter/material.dart';
import 'package:nahdy/components/app_localizations.dart';
import 'package:nahdy/components/cart_provider.dart';
import 'package:nahdy/pages/check_out_page.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    var t = AppLocalizations.of(context).translate;

    // Calculate total price
    final totalPrice = cart.items
        .fold(0.0, (sum, item) => sum + item['price'] * item['quantity']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('cart_page_title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal, // Custom background color for app bar
        elevation: 4.0, // Add slight elevation for better contrast
        centerTitle: true, // Centers the title in the app bar
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
                20), // Rounded corners at the bottom of the app bar
          ),
        ),
        automaticallyImplyLeading: false, // Removes the back icon
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];

                return Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.black),
                  ),
                  child: ListTile(
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '\$${item['price']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    leading: Image.network(item['imagePath']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey[300],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              cart.updateItemQuantity(
                                  item, item['quantity'] - 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey[300],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cart.updateItemQuantity(
                                  item, item['quantity'] + 1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${t('total_price')}\$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: totalPrice > 0
                ? () {
                    // Pass the cart items to CheckoutPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          cartItems: cart.items, // Pass cart items here
                        ),
                      ),
                    );
                  }
                : null, // Disable button when totalPrice is zero
            style: ElevatedButton.styleFrom(
              backgroundColor: totalPrice > 0
                  ? Colors.teal
                  : Colors.grey, // Change color to grey when disabled
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              child: Text(
                t('check_out'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
