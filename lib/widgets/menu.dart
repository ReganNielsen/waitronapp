// Menu Page

import 'package:flutter/material.dart'; // UI tooklkit (flutter)
import 'package:http/http.dart' as http; // HTTP package
import 'dart:convert'; // JSON encoding/decoding utilities

// Food + Drink Firebase urls
final foodUrl = Uri.https(
  'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
  'menu/food.json',
);
final drinkUrl = Uri.https(
  'thinkninja-c11a3-default-rtdb.europe-west1.firebasedatabase.app',
  'menu/drink.json',
);

// Stateful widget - UI Updates
class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

// State class for Menu
class _MenuState extends State<Menu> {
  // Input field controllers
  final TextEditingController foodCodeController = TextEditingController();
  final TextEditingController fooddescriptionController = TextEditingController();
  final TextEditingController foodPriceController = TextEditingController();

  final TextEditingController drinkCodeController = TextEditingController();
  final TextEditingController drinkdescriptionController = TextEditingController();
  final TextEditingController drinkPriceController = TextEditingController();

  Future<void> addItem(String type) async {
    // URL changes based on added item
    final url = type == 'food' ? foodUrl : drinkUrl;

    // Item data -> Firebase (depends on if food/drink was added)
    final itemData = {
      'code': type == 'food' ? foodCodeController.text : drinkCodeController.text,
      'description': type == 'food' ? fooddescriptionController.text : drinkdescriptionController.text,
      'price': type == 'food' ? foodPriceController.text : drinkPriceController.text,
    };

    try { // Post request to DB
      final response = await http.post(
        url,
        body: jsonEncode(itemData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) { // Check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.capitalize()} added to menu!')), // Added
        );
        // If added -> clear input fields
        if (type == 'food') {
          foodCodeController.clear();
          fooddescriptionController.clear();
          foodPriceController.clear();
        } else {
          drinkCodeController.clear();
          drinkdescriptionController.clear();
          drinkPriceController.clear();
        }
      } else { // error
        throw Exception('Failed to add item');
      }
    } catch (e) { //catch error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding $type item: $e')),
      );
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Title
      appBar: AppBar(title: const Text(
        'Menu', 
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column( //Add food item
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Food Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: foodCodeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: fooddescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: foodPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => addItem('food'),
                child: const Text('Add Food Item'),
              ),
              
              // Space between Food/Drink forms
              const Divider(),

              const Text( // Add drink item
                'Add Drink Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: drinkCodeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: drinkdescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: drinkPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => addItem('drink'),
                child: const Text('Add Drink Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Ensure first letter of the items description is capitalized when notifcation pops up
extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
