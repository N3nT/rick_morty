import 'package:flutter/material.dart';
import '../models/character.dart';
import 'characters_screen.dart';
import 'favorites_screen.dart';
import 'episodes_screen.dart';
import 'locations_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  List<Character> favorites = [];

  void toggleFavorite(Character character) {
    setState(() {
      if (favorites.any((c) => c.id == character.id)) {
        favorites.removeWhere((c) => c.id == character.id);
      } else {
        favorites.add(character);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CharactersScreen(
        favorites: favorites,
        onToggleFavorite: toggleFavorite,
      ),
      FavoritesScreen(favorites: favorites, onToggleFavorite: toggleFavorite),
      const EpisodesScreen(),
      const LocationsScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFF00D4AA),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: "Postacie",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.star_border),
                if (favorites.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${favorites.length}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.star),
                if (favorites.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${favorites.length}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Ulubione",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.tv_outlined),
            activeIcon: Icon(Icons.tv),
            label: "Epizody",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: "Lokacje",
          ),
        ],
      ),
    );
  }
}