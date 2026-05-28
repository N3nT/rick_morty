import 'package:flutter/material.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          "Lokacje",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Ekran lokacji – wkrótce",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}