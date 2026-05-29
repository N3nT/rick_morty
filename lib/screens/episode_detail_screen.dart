import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import 'character_detail_screen.dart';

class EpisodeDetailScreen extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailScreen({super.key, required this.episode});

  @override
  State<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  List<Character> characters = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final ids = widget.episode.characters
          .map((url) => int.parse(url.split("/").last))
          .toList();
      final result = await ApiService.fetchCharactersByIds(ids);
      setState(() => characters = result);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Map<String, int?> parseEpisodeCode(String code) {
    final match = RegExp(r'S(\d+)E(\d+)').firstMatch(code.toUpperCase());
    return {
      "season": match != null ? int.tryParse(match.group(1)!) : null,
      "episode": match != null ? int.tryParse(match.group(2)!) : null,
    };
  }

  Color getSeasonColor(int? season) {
    switch (season) {
      case 1: return const Color(0xFF00D4AA);
      case 2: return const Color(0xFF7C5CBF);
      case 3: return const Color(0xFFE89C2F);
      case 4: return const Color(0xFFE84545);
      case 5: return const Color(0xFF4589E8);
      default: return Colors.white38;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "alive": return Colors.green;
      case "dead": return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parseEpisodeCode(widget.episode.episode);
    final season = parsed["season"];
    final color = getSeasonColor(season);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.episode.episode,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(color, season, parsed),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildCharactersSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, int? season, Map<String, int?> parsed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge sezonu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              "Sezon ${season ?? "?"} · Odcinek ${parsed["episode"] ?? "?"}",
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.episode.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
          _buildInfoRow(Icons.calendar_today_outlined, "Data premiery", widget.episode.airDate, isFirst: true),
          const Divider(height: 1, color: Color(0xFF30363D), indent: 44),
          _buildInfoRow(Icons.tv_outlined, "Kod odcinka", widget.episode.episode),
          const Divider(height: 1, color: Color(0xFF30363D), indent: 44),
          _buildInfoRow(Icons.people_outline, "Liczba postaci", "${widget.episode.characters.length}", isLast: true),
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

  Widget _buildCharactersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Postacie",
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
                "${widget.episode.characters.length}",
                style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)))
        else if (errorMessage != null)
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 8),
                Text(errorMessage!, style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                TextButton(
                  onPressed: loadCharacters,
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
            itemCount: characters.length,
            itemBuilder: (context, index) => _buildCharacterTile(characters[index]),
          ),
      ],
    );
  }

  Widget _buildCharacterTile(Character character) {
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
                  // Kolorowa kropka statusu
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