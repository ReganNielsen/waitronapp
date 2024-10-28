import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/appbar.dart';


// Ensures flutter bindings are correct before using Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); // Run app widget as root
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // Sets up materialapp
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Think Ninja', // Title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey), // Scheme
        useMaterial3: true,
      ),
      home: const App(), // Home page
    );
  }
}
