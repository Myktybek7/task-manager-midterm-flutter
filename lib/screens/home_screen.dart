
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Task Manager'),
        centerTitle: true,
      ),

      body: const Center(
        child: Text(
          'Welcome to Task Manager!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Add button clicked!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
