import 'dart:async';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import 'character_detail_screen.dart';

class CharactersScreen extends StatefulWidget {
  final List<Character> favorites;
  final Function(Character) onToggleFavorite;

  const CharactersScreen({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  List<Character> characters = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  // Filtry
  final TextEditingController searchController = TextEditingController();
  String? filterStatus;
  String? filterGender;
  String? filterSpecies;
  String? filterType;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> loadCharacters({int page = 1}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      currentPage = page;
    });

    try {
      final result = await ApiService.fetchCharacters(
        page: page,
        name: searchController.text,
        status: filterStatus,
        gender: filterGender,
        species: filterSpecies,
        type: filterType,
      );
      setState(() {
        characters = result["characters"];
        totalPages = result["totalPages"];
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadCharacters(page: 1);
    });
  }

  void goToPage(int page) => loadCharacters(page: page);

  bool get hasActiveFilters =>
      filterStatus != null ||
          filterGender != null ||
          filterSpecies != null ||
          filterType != null;

  void clearAllFilters() {
    setState(() {
      filterStatus = null;
      filterGender = null;
      filterSpecies = null;
      filterType = null;
      searchController.clear();
    });
    loadCharacters(page: 1);
  }

  void handleToggleFavorite(Character character) {
    final isFavorite = widget.favorites.any((c) => c.id == character.id);
    widget.onToggleFavorite(character);
    if (!isFavorite) _showFavoritePopup(character);
  }

  void _showFavoritePopup(Character character) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FavoritePopup(
        character: character,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  void openFilterSheet() {
    // Lokalne kopie do edycji w bottom sheet
    String? tempStatus = filterStatus;
    String? tempGender = filterGender;
    String? tempSpecies = filterSpecies;
    String? tempType = filterType;
    final speciesController = TextEditingController(text: filterSpecies ?? "");
    final typeController = TextEditingController(text: filterType ?? "");

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nagłówek
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempStatus = null;
                            tempGender = null;
                            tempSpecies = null;
                            tempType = null;
                            speciesController.clear();
                            typeController.clear();
                          });
                        },
                        child: const Text(
                          "Wyczyść",
                          style: TextStyle(color: Color(0xFF00D4AA)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status
                  const Text("Status", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["alive", "dead", "unknown"].map((s) {
                      final isSelected = tempStatus == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        onSelected: (_) => setSheetState(
                              () => tempStatus = isSelected ? null : s,
                        ),
                        selectedColor: const Color(0xFF00D4AA),
                        backgroundColor: const Color(0xFF0D1117),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00D4AA) : const Color(0xFF30363D),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  const Text("Płeć", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["female", "male", "genderless", "unknown"].map((g) {
                      final isSelected = tempGender == g;
                      return ChoiceChip(
                        label: Text(g),
                        selected: isSelected,
                        onSelected: (_) => setSheetState(
                              () => tempGender = isSelected ? null : g,
                        ),
                        selectedColor: const Color(0xFF00D4AA),
                        backgroundColor: const Color(0xFF0D1117),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00D4AA) : const Color(0xFF30363D),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Species
                  const Text("Gatunek", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  _filterTextField(
                    controller: speciesController,
                    hint: "np. Human, Alien...",
                    onChanged: (v) => tempSpecies = v.isEmpty ? null : v,
                  ),
                  const SizedBox(height: 16),

                  // Type
                  const Text("Typ", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  _filterTextField(
                    controller: typeController,
                    hint: "np. Parasite, Robot...",
                    onChanged: (v) => tempType = v.isEmpty ? null : v,
                  ),
                  const SizedBox(height: 24),

                  // Zastosuj
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          filterStatus = tempStatus;
                          filterGender = tempGender;
                          filterSpecies = tempSpecies;
                          filterType = tempType;
                        });
                        Navigator.pop(context);
                        loadCharacters(page: 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4AA),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Zastosuj",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterTextField({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0D1117),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00D4AA)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          "Rick & Morty",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (hasActiveFilters) _buildActiveFiltersRow(),
          Expanded(child: _buildBody()),
          if (totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Szukaj postaci...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                  onPressed: () {
                    searchController.clear();
                    loadCharacters(page: 1);
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFF161B22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Przycisk filtrów z kropką gdy aktywne
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: openFilterSheet,
                icon: const Icon(Icons.tune),
                color: hasActiveFilters ? const Color(0xFF00D4AA) : Colors.white54,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF161B22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: hasActiveFilters
                          ? const Color(0xFF00D4AA)
                          : const Color(0xFF30363D),
                    ),
                  ),
                ),
              ),
              if (hasActiveFilters)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D4AA),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    final chips = <Widget>[];

    if (filterStatus != null)
      chips.add(_filterChip("Status: $filterStatus", () {
        setState(() => filterStatus = null);
        loadCharacters(page: 1);
      }));
    if (filterGender != null)
      chips.add(_filterChip("Płeć: $filterGender", () {
        setState(() => filterGender = null);
        loadCharacters(page: 1);
      }));
    if (filterSpecies != null)
      chips.add(_filterChip("Gatunek: $filterSpecies", () {
        setState(() => filterSpecies = null);
        loadCharacters(page: 1);
      }));
    if (filterType != null)
      chips.add(_filterChip("Typ: $filterType", () {
        setState(() => filterType = null);
        loadCharacters(page: 1);
      }));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: chips),
            ),
          ),
          TextButton(
            onPressed: clearAllFilters,
            child: const Text("Wyczyść", style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4AA).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 11)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Color(0xFF00D4AA), size: 13),
          ),
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
              onPressed: () => loadCharacters(page: 1),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
              child: const Text("Spróbuj ponownie"),
            ),
          ],
        ),
      );
    }

    if (characters.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.white24, size: 64),
            SizedBox(height: 12),
            Text("Brak wyników", style: TextStyle(color: Colors.white38, fontSize: 16)),
            SizedBox(height: 4),
            Text("Spróbuj innych filtrów", style: TextStyle(color: Colors.white24, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF00D4AA),
      backgroundColor: const Color(0xFF161B22),
      onRefresh: () => loadCharacters(page: currentPage),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CharacterDetailScreen(
                  character: character,
                  isFavorite: widget.favorites.any((c) => c.id == character.id),
                  onToggleFavorite: handleToggleFavorite,
                ),
              ),
            ),
            child: _buildCharacterCard(character),
          );
        },
      ),
    );
  }

  Widget _buildCharacterCard(Character character) {
    final isFavorite = widget.favorites.any((c) => c.id == character.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.network(
                  character.image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA), strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.white38)),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => handleToggleFavorite(character),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: getStatusColor(character.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "${character.status} · ${character.species}",
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  character.locationName,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
            onPressed: currentPage > 1 ? () => goToPage(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            color: Colors.white,
            disabledColor: Colors.white24,
          ),
          Row(children: _buildPageButtons()),
          IconButton(
            onPressed: currentPage < totalPages ? () => goToPage(currentPage + 1) : null,
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
          onTap: isActive ? null : () => goToPage(i),
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

class _FavoritePopup extends StatefulWidget {
  final Character character;
  final VoidCallback onDone;

  const _FavoritePopup({required this.character, required this.onDone});

  @override
  State<_FavoritePopup> createState() => _FavoritePopupState();
}

class _FavoritePopupState extends State<_FavoritePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2A1F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      widget.character.image,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.character.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          "Dodano do ulubionych",
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}