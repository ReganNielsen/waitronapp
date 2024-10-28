// Request page

import 'package:flutter/material.dart'; // UI tooklkit (flutter)
import 'package:http/http.dart' as http; // HTTP package
import 'dart:convert'; // JSON encoding/decoding utilities


//Firebase connect
final url = Uri.https(
    'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
    'request-list.json');

// Stateful widget - UI Updates
class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  List<Map<String, dynamic>> requests = []; //Retrieve requests in map

// Call once - fetch requests from firebase
  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

// Fetch Request
  Future<void> fetchRequests() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) { //check
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<Map<String, dynamic>> loadedRequests = []; //requests displayed on map
        //print(data);
        // Iterate through data
        data.forEach((key, value) {
          loadedRequests.add({
            'id': key,
            'table': value['table'], // Assuming table exists
            'requests': value['requests'],
            'notes': value['notes'],
            'timestamp': value['timestamp'],
            'status': 'Received', // Initial status
          });
        });

        // Assigned parsed to main req list
        setState(() {
          requests = loadedRequests;
        });
      }

    // display error -> on snackbar message
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error fetching Requests: $e')),
      // );
    }
  }

  // Delete by request ID if denied
  Future<void> deleteRequest(String requestId,
      {bool showNotification = true}) async { // Set boolean for app/deny requests
    final url = Uri.https(
      'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
      'request-list/$requestId.json',
    );

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) { // check
        setState(() {
          requests.removeWhere((request) => request['id'] == requestId); // remove req
        });

        if (showNotification) {
          ScaffoldMessenger.of(context).showSnackBar( // If denied - boolean false - show it was denied
            const SnackBar(content: Text('Order denied')),
          );
        }

      } else { // if you cant deny for some reason (data is missing) display error
        throw Exception('Failed to deny');
      }

    } catch (e) { // catch error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error denying request: $e')),
      );
    }
  }


  // Transffering data from request table -> order table in db
  Future<void> transferRequestToOrder(
      String requestId, Map<String, dynamic> requestData) async {
    final url = Uri.https(
      'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
      'order-list.json',
    );

    // Trasfer -> create order data -> map field from request data (approved)
    final orderData = {
      'id': requestData['id'],
      'table': requestData['table'],
      'orders': requestData['requests'],
      'notes': requestData['notes'],
      'timestamp': requestData['timestamp'],
    };

    // POST request w/ newly mapped order data 
    try {
      final response = await http.post(
        url,
        body: jsonEncode(orderData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Call deleteRequest w/o "Order denied" notification
        await deleteRequest(requestId, showNotification: false);

        // Confirmation that order data sent to kitchen/order db
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to kitchen!')),
        );

      } else { // status != 200 -> throw error
        throw Exception('Failed to transfer request');
      }

    } catch (e) { // handle error -> display on snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error transferring request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
        'Requests',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: requests.isEmpty
            // If theres no requests -> display no req -> if there is build list
            ? const Center(child: Text('No current requests'))
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];

                  // Request card style
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request ${index + 1} - Table ${request['table']}', // Display table number here
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // Map item to string w/ name and quantity
                            'Items: ${request['requests'] != null ? (request['requests'] as List<dynamic>).map((item) {
                                  if (item is Map<String, dynamic> && item.containsKey('description') && item.containsKey('quantity')) {
                                    return '${item['description']} x${item['quantity']}';
                                  } else {
                                    return '';
                                  }
                                }).where((item) => item.isNotEmpty).join(', ') : ''}',
                          ),
                          const SizedBox(height: 4),
                          Text( // Display note w/ request
                              'Notes: ${(request['notes'] as List<dynamic>?)?.join(', ') ?? ''}'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton( // Deny button -> calls delete req
                                onPressed: () async {
                                  await deleteRequest(request['id']);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Deny'),
                              ),
                              ElevatedButton( // Cofirm button -> calls transfer
                                onPressed: () async {
                                  await transferRequestToOrder(request['id'], {
                                    'id': request['id'],
                                    'table':
                                        request['table'], // Include table info
                                    'requests': request['requests'],
                                    'notes': request['notes'],
                                    'timestamp': request['timestamp'],
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                                child: const Text('Confirm'),
                              ),
                            ],
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
