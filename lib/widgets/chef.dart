// Kitchen Page

import 'package:flutter/material.dart'; // UI tooklkit (flutter)
import 'package:http/http.dart' as http; // HTTP package
import 'dart:convert'; // JSON encoding/decoding utilities

// Firebase connect
final url = Uri.https(
    'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
    'order-list.json');

// Stateful widget - UI Updates
// Super -> parent class
class Kitchen extends StatefulWidget {
  const Kitchen({super.key});

  @override
  State<Kitchen> createState() => _KitchenState(); // Widget state
}

class _KitchenState extends State<Kitchen> {
  List<Map<String, dynamic>> orders = []; // Retrieved orders in map

// Call once - fetch orders from firebase
  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

// Future - Placeholder for result that isn't immediately avalible
// Vod - Function - Complete w/o value return
  Future<void> fetchOrders() async {
    try {
      final response = await http.get(url); // Get req
      if (response.statusCode == 200) { // Check
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<Map<String, dynamic>> loadedOrders = []; 

        // Loop through entry data
        data.forEach((key, value) {
          loadedOrders.add({
            'id': key, // Unique ID
            'table': value['table'], // Assume table of data exists
            'orders': value['orders'],
            'notes': value['notes'],
            'timestamp': value['timestamp'],
            'status': 'Received', // Starting status
          });
        });

        // Assign parsed orders => main order list 
        setState(() {
          orders = loadedOrders;
        });
      }

    // Handle errors -> error message (snackbar)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  // Delete order by ID
  Future<void> deleteOrder(String orderId) async {
    final deleteUrl = Uri.https(
        'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
        'order-list/$orderId.json'); 

    // HTTP Delete req
    try {
      final response = await http.delete(deleteUrl);
      if (response.statusCode == 200) { // Check
        setState(() {
          orders.removeWhere((order) => order['id'] == orderId); // Remove order
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order collected and delivered!')), // Confirm
        );
      } else {
        throw Exception('Failed to delete order'); // Failed Delete
      }

    // Catch error - display in notification
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting order: $e')),
      );
    }
  }

  // Update status
  void updateOrderStatus(int index, String newStatus) {
    setState(() {
      orders[index]['status'] = newStatus;
    });
    if (newStatus == 'Complete') { // Check if comp - noti waiter
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent to waiter to collect the order')),
      );
    }
  }

  // Display orders
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
        'Kitchen',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder( // Listview = display each order
          itemCount: orders.length, // No. order to display
          itemBuilder: (context, index) {
            final order = orders[index]; // Current order data

          // Block for each order + some styling
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ${index + 1} - Table ${order['table']}', // Table no.
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // Display items -> check for null value
                            'Items: ${order['orders'] != null ? order['orders'].map((item) => '${item['description']} x${item['quantity']}').join(', ') : ''}'),
                        const SizedBox(height: 4),
                        Text(
                          // Display notes -> check for null value
                            'Notes: ${(order['notes'] as List<dynamic>?)?.join(', ') ?? ''}'),
                        const SizedBox(height: 4),
                        Text(
                          // Current status
                          'Status: ${order['status']}',
                          style: TextStyle(
                            // Color of text dep. on status 
                            // (condition ? valueIfTrue : valueIfFalse)
                            color: order['status'] == 'Complete'
                                ? Colors.green
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton( // Received
                              onPressed: () => updateOrderStatus(index, 'Received'),
                              child: const Text('Order'),
                            ),
                            ElevatedButton( // In progress
                              onPressed: () => updateOrderStatus(index, 'In Progress'),
                              child: const Text('Preparing'),
                            ),
                            ElevatedButton( // Completed
                              onPressed: () => updateOrderStatus(index, 'Complete'),
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.green),
                              child: const Text('Complete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Order has been picked up and is out for delivery - waiter deletes
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.playlist_add_check_circle, color: Colors.green),
                        onPressed: () => deleteOrder(order['id']), //delete by order id
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
