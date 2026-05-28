import 'package:flutter/material.dart';
import '../models/character.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Character> favorites;

  const FavoritesScreen({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          "Ulubione",
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
          "Ekran ulubionych – wkrótce",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}