import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import 'episode_detail_screen.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({super.key});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  List<Episode> episodes = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadEpisodes();
  }

  Future<void> loadEpisodes({int page = 1}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      currentPage = page;
    });

    try {
      final result = await ApiService.fetchEpisodes(page: page);
      setState(() {
        episodes = result["episodes"];
        totalPages = result["totalPages"];
      });
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Parsuje "S01E03" → sezon 1, epizod 3
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          "Epizody",
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
              onPressed: () => loadEpisodes(page: currentPage),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
              child: const Text("Spróbuj ponownie"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EpisodeDetailScreen(episode: episode),
            ),
          ),
          child: _buildEpisodeCard(episode),
        );
      },
    );
  }

  Widget _buildEpisodeCard(Episode episode) {
    final parsed = parseEpisodeCode(episode.episode);
    final season = parsed["season"];
    final seasonColor = getSeasonColor(season);

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
          // Badge z kodem epizodu
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: seasonColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: seasonColor.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text(
                  "S${season?.toString().padLeft(2, "0") ?? "??"}",
                  style: TextStyle(
                    color: seasonColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "E${parsed["episode"]?.toString().padLeft(2, "0") ?? "??"}",
                  style: TextStyle(
                    color: seasonColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Nazwa i info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  episode.airDate,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          // Liczba postaci
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.people_outline, color: Colors.white24, size: 16),
              const SizedBox(height: 2),
              Text(
                "${episode.characters.length}",
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
            onPressed: currentPage > 1 ? () => loadEpisodes(page: currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            color: Colors.white,
            disabledColor: Colors.white24,
          ),
          Row(children: _buildPageButtons()),
          IconButton(
            onPressed: currentPage < totalPages ? () => loadEpisodes(page: currentPage + 1) : null,
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
          onTap: isActive ? null : () => loadEpisodes(page: i),
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