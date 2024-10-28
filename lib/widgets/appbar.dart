// App bar traverse through pages
// Import pages and UI tooklkit (flutter)

import 'package:flutter/material.dart';
import 'order.dart';
import 'chef.dart';
import 'menu.dart';
import 'preorder.dart';
import 'request.dart';

// Stateful widget - UI Updates
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 4 tabs for full app
    const int tabsCount = 5;

    return DefaultTabController(
      initialIndex: 0, // Start page on tab 0
      length: tabsCount,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text('Think Ninja Waiters',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 1;
          },
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          bottom: const TabBar(
            tabs: <Widget>[
              // Tab names and icons - navigation
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.campaign)),
              Tab(icon: Icon(Icons.menu_book)),
              Tab(icon: Icon(Icons.lunch_dining)),
              Tab(
                icon: Icon(Icons.restaurant_menu),
              ),
            ],
          ),
        ),

        // Content assosciated with each tab
        body: const TabBarView(
          children: <Widget>[
            Customer(),
            Request(),
            Menu(),
            WaiterPage(),
            Kitchen(),
          ],
        ),
      ),
    );
  }
}
