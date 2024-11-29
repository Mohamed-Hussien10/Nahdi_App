import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nahdy/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = '';
  String phoneNumber = '';
  String username = '';
  String role = '';

  List<Map<String, dynamic>> orders = [];

  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _getUserOrders();
  }

  void _getUserDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          email = user.email ?? 'No email';
          phoneNumber = userDoc['phone_number'] ?? 'No phone number';
          username = userDoc['username'] ?? 'No username';
          role = userDoc['role'] ?? 'No role';

          usernameController.text = username;
          phoneNumberController.text = phoneNumber;
        });
      }
    }
  }

  void _getUserOrders() async {
    User? user = _auth.currentUser;

    if (user != null) {
      var orderSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        orders = orderSnapshot.docs
            .map((doc) => {
                  'orderId': doc.id, // Use document ID as the order ID
                  'address': doc['address'] ?? 'Unknown Store',
                  'recipientName': doc['recipientName'] ?? 'Unknown Recipient',
                  'phoneNumber': doc['phoneNumber'] ?? 'No Phone',
                  'cartItems':
                      List<Map<String, dynamic>>.from(doc['cartItems']),
                  'timestamp': doc['timestamp']
                      .toDate()
                      .toString(), // Convert Firestore timestamp
                  'status': doc['status'] ?? 'Pending', // Order status
                })
            .toList();
      });
    }
  }

  void _updateUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      var userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.update({
        'username': usernameController.text,
        'phone_number': phoneNumberController.text,
      });

      setState(() {
        username = usernameController.text;
        phoneNumber = phoneNumberController.text;
        isEditing = false;
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // Editable Profile Information
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildEditableField(
                      label: 'Username',
                      controller: usernameController,
                      isEditable: isEditing,
                    ),
                    const SizedBox(height: 10),
                    _buildEditableField(
                      label: 'Phone Number',
                      controller: phoneNumberController,
                      isEditable: isEditing,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileField(label: 'Email', value: email),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Edit/Save Button
            ElevatedButton.icon(
              onPressed: () {
                if (isEditing) {
                  _updateUserData();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              icon: Icon(isEditing ? Icons.save : Icons.edit,
                  color: Colors.white),
              label: Text(
                isEditing ? 'Save Changes' : 'Edit Profile',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isEditing ? Colors.green : Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),

            // Orders Section
            const Text(
              "Your Orders",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            orders.isEmpty
                ? const Text("No orders found.")
                : RefreshIndicator(
                    onRefresh: () async {
                      _getUserOrders(); // Refresh the orders
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final cartItems =
                            order['cartItems'] as List<Map<String, dynamic>>;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Address: ${order['address']}"),
                                Text("Recipient: ${order['recipientName']}"),
                                Text("Phone: ${order['phoneNumber']}"),
                                Text("Date: ${order['timestamp']}"),
                                Text("Status: ${order['status']}",
                                    style: TextStyle(
                                      color: order['status'] == 'Confirmed'
                                          ? Colors.green
                                          : (order['status'] == 'Canceled'
                                              ? Colors.red
                                              : Colors.orange),
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                            children: cartItems.map((item) {
                              return ListTile(
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.teal,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 30,
                                    child: Image.network(
                                      item['imagePath'],
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(item['title']),
                                subtitle: Text(
                                    "Price: \$${item['price']} x ${item['quantity']}"),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return TextField(
      controller: controller,
      enabled: isEditable,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: isEditable ? const Icon(Icons.edit) : null,
      ),
    );
  }

  Widget _buildProfileField({required String label, required String value}) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
