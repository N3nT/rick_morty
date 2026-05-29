import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import 'character_detail_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final Location location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  List<Character> residents = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.location.residents.isNotEmpty) loadResidents();
  }

  Future<void> loadResidents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final ids = widget.location.residents
          .map((url) => int.parse(url.split("/").last))
          .toList();
      final result = await ApiService.fetchCharactersByIds(ids);
      setState(() => residents = result);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "alive": return Colors.green;
      case "dead": return Colors.red;
      default: return Colors.grey;
    }
  }

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
    final color = getLocationColor(widget.location.type);
    final icon = getLocationIcon(widget.location.type);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lokacja",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(color, icon),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildResidentsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(
                    widget.location.type,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.rotate_90_degrees_ccw_outlined, "Wymiar",
              widget.location.dimension.isEmpty ? "Nieznany" : widget.location.dimension, isFirst: true),
          const Divider(height: 1, color: Color(0xFF30363D), indent: 44),
          _buildInfoRow(Icons.people_outline, "Liczba mieszkańców",
              "${widget.location.residents.length}", isLast: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D4AA), size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResidentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Mieszkańcy",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${widget.location.residents.length}",
                style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.location.residents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.people_outline, color: Colors.white12, size: 48),
                  SizedBox(height: 8),
                  Text("Brak znanych mieszkańców", style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          )
        else if (isLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)))
        else if (errorMessage != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 36),
                  const SizedBox(height: 8),
                  Text(errorMessage!, style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                  TextButton(
                    onPressed: loadResidents,
                    child: const Text("Spróbuj ponownie", style: TextStyle(color: Color(0xFF00D4AA))),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: residents.length,
              itemBuilder: (context, index) => _buildResidentTile(residents[index]),
            ),
      ],
    );
  }

  Widget _buildResidentTile(Character character) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterDetailScreen(
            character: character,
            isFavorite: false,
            onToggleFavorite: (_) {},
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    character.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA), strokeWidth: 2));
                    },
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: getStatusColor(character.status),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                character.name,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}