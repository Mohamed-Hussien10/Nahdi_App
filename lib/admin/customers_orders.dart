import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomersOrders extends StatefulWidget {
  const CustomersOrders({super.key});

  @override
  _CustomersOrdersState createState() => _CustomersOrdersState();
}

class _CustomersOrdersState extends State<CustomersOrders> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders.'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                } else {
                  // Filter the orders based on the search query
                  var orders = snapshot.data!.docs.where((order) {
                    var recipientName = order['recipientName'] as String;
                    return recipientName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  // Display the list of filtered orders
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order = orders[index];
                      return OrderCard(order: order);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by Recipient Name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Retrieve order details
    final cartItems = order['cartItems'] as List;
    final phoneNumber = order['phoneNumber'] as String;
    final recipientName = order['recipientName'] as String;
    final storeName = order['storeName'] as String;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text('Store: $storeName',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Recipient: $recipientName'),
            Text('Phone: $phoneNumber'),
            const SizedBox(height: 10),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: cartItems.map((item) {
                return CartItemCard(item: item);
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Logic to confirm the order
                    _confirmOrder(order.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logic to cancel the order
                    _cancelOrder(order.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(String orderId) {
    // Logic to update the order status to confirmed
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'confirmed',
    }).then((_) {
      print("Order $orderId confirmed.");
    }).catchError((error) {
      print("Failed to confirm order: $error");
    });
  }

  void _cancelOrder(String orderId) {
    // Logic to update the order status to canceled
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'canceled',
    }).then((_) {
      print("Order $orderId canceled.");
    }).catchError((error) {
      print("Failed to cancel order: $error");
    });
  }
}

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Image.network(item['imagePath']),
        title: Text(item['title']),
        subtitle: Text('Price: \$${item['price']} x ${item['quantity']}'),
        trailing: Text(
            'Total: \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
      ),
    );
  }
}
