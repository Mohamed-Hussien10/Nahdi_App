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
                  var orders = snapshot.data!.docs.where((order) {
                    var recipientName = order['recipientName'] as String;
                    return recipientName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

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
    final cartItems = order['cartItems'] as List;
    final phoneNumber = order['phoneNumber'] as String;
    final recipientName = order['recipientName'] as String;
    final storeName = order['storeName'] as String;
    final status = order['status'] as String; // Extract status

    // Determine color based on status
    Color getStatusColor(String status) {
      switch (status) {
        case 'confirmed':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'canceled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status at the top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(status), // Dynamic color
                  ),
                ),
                Text(
                  'Store: $storeName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
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
                  onPressed: status == 'pending'
                      ? () {
                          _confirmOrder(context, order.id, cartItems);
                        }
                      : null, // Disable button if not pending
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
                  onPressed: status == 'pending'
                      ? () {
                          _cancelOrder(context, order.id, cartItems);
                        }
                      : null, // Disable button if not pending
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

  void _confirmOrder(
      BuildContext context, String orderId, List cartItems) async {
    try {
      // Update order status to confirmed
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'confirmed',
      });

      // Update product stock for each item in the order
      for (var item in cartItems) {
        String productId = item['id']; // Assuming 'id' is the product ID
        int quantity = item['quantity'];

        // Decrease the stock
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({
          'stock': FieldValue.increment(-quantity), // Decrement the stock
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order confirmed!')));
    } catch (error) {
      print("Failed to confirm order: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm order.')));
    }
  }

  void _cancelOrder(
      BuildContext context, String orderId, List cartItems) async {
    try {
      // Update order status to canceled
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'canceled',
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order canceled!')));
    } catch (error) {
      print("Failed to cancel order: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel order.')));
    }
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
