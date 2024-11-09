import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:nahdy/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class ReceiptPage extends StatefulWidget {
  final String storeName;
  final String recipientName;
  final String address;
  final String phoneNumber;
  final List<Map<String, dynamic>> cartItems;

  const ReceiptPage({
    super.key,
    required this.storeName,
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    required this.cartItems,
  });

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  // Request permissions with checks for Android versions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      if (await Permission.storage.isGranted) {
        return true;
      }

      // For Android 11 and above, request MANAGE_EXTERNAL_STORAGE permission
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      return await Permission.manageExternalStorage.isGranted;
    }
    return true;
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    bool hasPermission = await requestPermissions();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Storage permission denied. Please enable it in settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    try {
      // Load the logo image
      final ByteData bytes = await rootBundle.load('assets/images/logo.png');
      final image = pw.MemoryImage(bytes.buffer.asUint8List());

      // Create PDF document
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              // This centers the entire column
              child: pw.Column(
                mainAxisAlignment: pw
                    .MainAxisAlignment.center, // Vertically center the content
                crossAxisAlignment: pw.CrossAxisAlignment
                    .center, // Horizontally center the content
                children: [
                  pw.Image(image, width: 150, height: 150),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    widget.storeName,
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}',
                  ),
                  pw.Text('Recipient: ${widget.recipientName}'),
                  pw.Text('Address: ${widget.address}'),
                  pw.Text('Phone: ${widget.phoneNumber}'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Itemized Receipt',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  // Add a fixed height for the item list
                  pw.SizedBox(
                    height: 200, // Set a fixed height for the item list
                    child: pw.ListView(
                      children: widget.cartItems.map((item) {
                        double itemTotal = (item['price'] as num).toDouble() *
                            (item['quantity'] as num).toInt();
                        return pw.Text(
                          '${item['title']} - Quantity: ${item['quantity']} x \$${item['price']} = \$${itemTotal.toStringAsFixed(2)}',
                          textAlign:
                              pw.TextAlign.center, // Center text for each item
                        );
                      }).toList(),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Total: \$${widget.cartItems.fold<double>(0, (sum, item) => sum + (item['price'] as num).toDouble() * (item['quantity'] as num).toInt()).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Thank you for shopping with us!'),
                ],
              ),
            );
          },
        ),
      );

      // Ask the user to select a directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        // User canceled the directory selection or an error occurred
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Directory selection canceled or failed.')),
        );
        // Use app's documents directory as a fallback
        directoryPath = (await getApplicationDocumentsDirectory()).path;
      }

      // Save the file to the selected or fallback directory
      final filePath = '$directoryPath/receipt.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      setState(() {
        widget.cartItems.clear();
      });

      // Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: Text(
                  'Receipt saved to: $filePath\nYour order has been confirmed!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold<double>(
      0,
      (sum, item) {
        double price = (item['price'] as num).toDouble();
        int quantity = (item['quantity'] as num).toInt();
        return sum + (price * quantity);
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Text(widget.storeName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold))),
            Center(
                child: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                    style: const TextStyle(fontSize: 16))),
            const Divider(thickness: 1),
            Text('Recipient: ${widget.recipientName}'),
            Text('Address: ${widget.address}'),
            Text('Phone: ${widget.phoneNumber}'),
            const Divider(thickness: 1),
            const Text(
              'Itemized Receipt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  double itemTotal = (item['price'] as num).toDouble() *
                      (item['quantity'] as num).toInt();
                  return ListTile(
                    title: Text(item['title']),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: Text('\$${itemTotal.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _downloadReceipt(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Download Receipt',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Thank you for shopping with us!',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
