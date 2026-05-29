import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/api_service.dart';
import 'location_detail_screen.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<Location> locations = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations({int page = 1}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      currentPage = page;
    });

    try {
      final result = await ApiService.fetchLocations(page: page);
      setState(() {
        locations = result["locations"];
        totalPages = result["totalPages"];
      });
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Każdy typ lokacji dostaje inną ikonę
  IconData getLocationIcon(String type) {
    switch (type.toLowerCase()) {
      case "planet": return Icons.public;
      case "space station": return Icons.satellite_alt;
      case "microverse": return Icons.bubble_chart;
      case "tv": return Icons.tv;
      case "resort": return Icons.beach_access;
      case "fantasy town": return Icons.castle;
      case "dream": return Icons.nights_stay;
      case "dimension": return Icons.rotate_90_degrees_ccw;
      default: return Icons.location_on;
    }
  }

  Color getLocationColor(String type) {
    switch (type.toLowerCase()) {
      case "planet": return const Color(0xFF00D4AA);
      case "space station": return const Color(0xFF7C5CBF);
      case "microverse": return const Color(0xFFE89C2F);
      case "dimension": return const Color(0xFF4589E8);
      case "fantasy town": return const Color(0xFFE84545);
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          "Lokacje",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(errorMessage!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => loadLocations(page: currentPage),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
              child: const Text("Spróbuj ponownie"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocationDetailScreen(location: location),
            ),
          ),
          child: _buildLocationCard(location),
        );
      },
    );
  }

  Widget _buildLocationCard(Location location) {
    final color = getLocationColor(location.type);
    final icon = getLocationIcon(location.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          // Ikona typu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          // Nazwa, typ, wymiar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location.type,
                  style: TextStyle(color: color, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  location.dimension,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Liczba mieszkańców
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.people_outline, color: Colors.white24, size: 16),
              const SizedBox(height: 2),
              Text(
                "${location.residents.length}",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => loadLocations(page: currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            color: Colors.white,
            disabledColor: Colors.white24,
          ),
          Row(children: _buildPageButtons()),
          IconButton(
            onPressed: currentPage < totalPages ? () => loadLocations(page: currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            color: Colors.white,
            disabledColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    if (end - start < 4) start = (end - 4).clamp(1, totalPages);

    for (int i = start; i <= end; i++) {
      final bool isActive = i == currentPage;
      buttons.add(
        GestureDetector(
          onTap: isActive ? null : () => loadLocations(page: i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00D4AA) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? const Color(0xFF00D4AA) : const Color(0xFF30363D),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "$i",
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }
    return buttons;
  }
}