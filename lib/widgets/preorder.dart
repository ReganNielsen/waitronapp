// Pre-order page

import 'package:flutter/material.dart'; // UI toolkit (Flutter)
import 'package:http/http.dart' as http; // HTTP package
import 'dart:convert'; // JSON encoding/decoding utilities

// Firebase connect URL for food and drink lists
final foodUrl = Uri.https(
    'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
    'menu/food.json'); //food path
final drinkUrl = Uri.https(
    'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
    'menu/drink.json'); //drink path

// Table list
const List<int> tableList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// Firebase connect
final url = Uri.https(
    'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
    'request-list.json');

// Stateful widget - UI Updates
class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

// State class - manage UI and Logic
class _CustomerState extends State<Customer> {
  // Initial draft page
  Map<String, dynamic> selectedFood = {};
  Map<String, dynamic> selectedDrink = {};
  int foodQuantity = 1;
  int drinkQuantity = 1;
  int selectedTable = tableList.first;

  // Text input for the notes
  final TextEditingController notesController = TextEditingController();

  // Store requests
  final List<Map<String, dynamic>> requestList = [];
  final List<String> notesList = [];

// List of food and drink items
  List<Map<String, dynamic>> foodList = [];
  List<Map<String, dynamic>> drinkList = [];

  // Fetch food and drink lists from Firebase
  Future<void> fetchMenu() async {
    try {
      final foodResponse = await http.get(foodUrl);
      final drinkResponse = await http.get(drinkUrl);

      if (foodResponse.statusCode == 200 && drinkResponse.statusCode == 200) {
        setState(() {
          // Handle food items as a Map
          final foodData = json.decode(foodResponse.body) as Map<String, dynamic>;
          foodList = foodData.values.map((item) => {
                'description': item['description'],
                'code': item['code'],
                'price': item['price'],
              }).toList();

          // Handle drink items as a Map
          final drinkData = json.decode(drinkResponse.body) as Map<String, dynamic>;
          drinkList = drinkData.values.map((item) => {
                'description': item['description'],
                'code': item['code'],
                'price': item['price'],
              }).toList();

          // print(foodList);
          // print(drinkList);

          if (foodList.isNotEmpty) {
            selectedFood = foodList.first;
          }
          if (drinkList.isNotEmpty) {
            selectedDrink = drinkList.first;
          }
        });
      } else {
        throw Exception('Failed to load menu');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching menu: $e')),
      );
    }
  }

  // List of request prices -> Calculate total price
  double get totalPrice {
    return requestList.fold(
        0.0, (sum, item) => sum + item['price'] * item['quantity']);
  }

  // Add food to request list
  void addFoodRequest() {
    setState(() {
      requestList.add({
        'description': selectedFood['description'],
        'code': selectedFood['code'],
        'price': int.parse(selectedFood['price']),
        'quantity': foodQuantity
      });
    });
  }


  // Add food to request list
  void addDrinkRequest() {
    setState(() {
      requestList.add({
        'description': selectedDrink['description'],
        'code': selectedDrink['code'],
        'price': int.parse(selectedDrink['price']),
        'quantity': drinkQuantity
      });
    });
  }

  // Add note to request list
  void addNote() {
    setState(() {
      if (notesController.text.isNotEmpty) {
        notesList.add(notesController.text);
        notesController.clear();
      }
    });
  }

  // Clear requests and selected fields
  void clearAll() {
    setState(() {
      selectedFood = foodList.first;
      selectedDrink = drinkList.first;
      foodQuantity = 1;
      drinkQuantity = 1;
      selectedTable = tableList.first;
      requestList.clear();
      notesList.clear();
      notesController.clear();
    });
  }

  // Confirm request - send data to firebase - clear form if successful
  Future<void> confirmRequest() async {
    if (requestList.isEmpty) return;

    // prepare request data for firebase
    final requestData = {
      'table': selectedTable,
      'requests': requestList,
      'notes': notesList,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'total_price': totalPrice,
    };

    try { // Post to firebase
      final response = await http.post(
        url,
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) { // Check
        clearAll(); // If successful - clear form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to kitchen')),
        );

      } else { // If != 200, failed to send
        throw Exception('Failed to send request');
      }

    } catch (e) { // If error - display error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending request: $e')),
      );
    }
  }

  // Fetch menu when the widget is initialized
  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  // Build for Page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
        'Send in a request!',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Drop down - table
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: DropdownButton<int>(
                  value: selectedTable,
                  onChanged: (int? value) {
                    setState(() {
                      selectedTable = value!;
                    });
                  },
                  items: tableList.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Table $value'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // Drop down - food
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedFood,
                  onChanged: (Map<String, dynamic>? value) {
                    setState(() {
                      selectedFood = value!;
                    });
                  },
                  items: foodList.map<DropdownMenuItem<Map<String, dynamic>>>(
                      (Map<String, dynamic> value) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: value,
                      child: Text('${value['description']}'),
                    );
                  }).toList(),
                ),
              ),

              // food - quantity (increase quantity value)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (foodQuantity > 1) foodQuantity--;
                      });
                    },
                  ),
                  Text('$foodQuantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        foodQuantity++;
                      });
                    },
                  ),
                ],
              ),
              // Adds food to request list
              ElevatedButton(
                onPressed: addFoodRequest,
                child: const Text('+'),
              ),
            ],
          ),

          // Drop down - drink
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedDrink,
                  onChanged: (Map<String, dynamic>? value) {
                    setState(() {
                      selectedDrink = value!;
                    });
                  },
                  items: drinkList.map<DropdownMenuItem<Map<String, dynamic>>>(
                      (Map<String, dynamic> value) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: value,
                      child: Text('${value['description']}'),
                    );
                  }).toList(),
                ),
              ),

              // drink - quantity (increase quantity value)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (drinkQuantity > 1) drinkQuantity--;
                      });
                    },
                  ),
                  Text('$drinkQuantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        drinkQuantity++;
                      });
                    },
                  ),
                ],
              ),

              // Adds drink to request list
              ElevatedButton(
                onPressed: addDrinkRequest,
                child: const Text('+'),
              ),
            ],
          ),

          // Note field
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Add Note'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: addNote,
              ),
            ],
          ),

          // Created request list (food, drink and notes - quantity and price)
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: requestList.length + notesList.length,
              itemBuilder: (BuildContext context, int index) {
                if (index < requestList.length) {
                  final item = requestList[index];
                  return Dismissible(
                    key: UniqueKey(), // A unique key for each item
                    direction: DismissDirection.endToStart, // Swipe direction
                    onDismissed: (direction) {
                      setState(() {
                        requestList.removeAt(index); // Remove item on swipe
                      });
                    },
                    child: ListTile(
                      title: Text(
                        '${item['description']} x${item['quantity']} - R${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      ),
                    ),
                  );

                // Display note with icon
                } else {
                  final noteIndex = index - requestList.length;
                  return ListTile(
                    leading: const Icon(Icons.note),
                    title: Text(notesList[noteIndex]),
                  );
                }
              },
            ),
          ),

          // Display total price, total price = sum of all (price x quantity) - displayed on right bottom corner
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Total: R${totalPrice.toStringAsFixed(2)}'),
              ],
            ),
          ),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton( // Clear page - reset to draft
                onPressed: clearAll,
                child: const Text('Clear All'),
              ),
              ElevatedButton( // Clear page - reset to draft - send order to DB
                onPressed: confirmRequest,
                child: const Text('Confirm Request'),
              ),
            ],
          ),
        ],
      ),
    ),
  );}
}
