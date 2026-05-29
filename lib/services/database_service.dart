import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String _charactersBox = 'characters';
  static const String _episodesBox = 'episodes';
  static const String _locationsBox = 'locations';

  // Inicjalizacja Hive — wywołać raz w main()
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_charactersBox);
    await Hive.openBox(_episodesBox);
    await Hive.openBox(_locationsBox);
  }

  // ─── Zapis ────────────────────────────────────────────────────────────────

  static Future<void> saveCharacters(int page, List<dynamic> characters) async {
    final box = Hive.box(_charactersBox);
    await box.put('page_$page', jsonEncode(characters.map((c) => _characterToJson(c)).toList()));
    await box.put('page_${page}_time', DateTime.now().toIso8601String());
  }

  static Future<void> saveEpisodes(int page, List<dynamic> episodes) async {
    final box = Hive.box(_episodesBox);
    await box.put('page_$page', jsonEncode(episodes.map((e) => _episodeToJson(e)).toList()));
    await box.put('page_${page}_time', DateTime.now().toIso8601String());
  }

  static Future<void> saveLocations(int page, List<dynamic> locations) async {
    final box = Hive.box(_locationsBox);
    await box.put('page_$page', jsonEncode(locations.map((l) => _locationToJson(l)).toList()));
    await box.put('page_${page}_time', DateTime.now().toIso8601String());
  }

  static Future<void> saveTotalPages(String type, int totalPages) async {
    final boxName = type == 'characters' ? _charactersBox
        : type == 'episodes' ? _episodesBox
        : _locationsBox;
    await Hive.box(boxName).put('total_pages', totalPages);
  }

  // ─── Odczyt ───────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>>? loadCharacters(int page) {
    final box = Hive.box(_charactersBox);
    final raw = box.get('page_$page');
    if (raw == null) return null;
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static List<Map<String, dynamic>>? loadEpisodes(int page) {
    final box = Hive.box(_episodesBox);
    final raw = box.get('page_$page');
    if (raw == null) return null;
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static List<Map<String, dynamic>>? loadLocations(int page) {
    final box = Hive.box(_locationsBox);
    final raw = box.get('page_$page');
    if (raw == null) return null;
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static int loadTotalPages(String boxName) {
    final box = Hive.box(boxName == 'characters' ? _charactersBox
        : boxName == 'episodes' ? _episodesBox
        : _locationsBox);
    return box.get('total_pages', defaultValue: 1);
  }

  // Sprawdza czy dane są świeże (mniej niż 1h)
  static bool isFresh(String boxName, int page) {
    final box = Hive.box(boxName == 'characters' ? _charactersBox
        : boxName == 'episodes' ? _episodesBox
        : _locationsBox);
    final raw = box.get('page_${page}_time');
    if (raw == null) return false;
    final saved = DateTime.tryParse(raw);
    if (saved == null) return false;
    return DateTime.now().difference(saved).inHours < 1;
  }

  // ─── Helpers: obiekty → Map ───────────────────────────────────────────────

  static Map<String, dynamic> _characterToJson(dynamic c) => {
    'id': c.id,
    'name': c.name,
    'status': c.status,
    'species': c.species,
    'type': c.type,
    'gender': c.gender,
    'image': c.image,
    'origin': {'name': c.originName, 'url': ''},
    'location': {'name': c.locationName, 'url': ''},
    'episode': c.episodeUrls,
    'url': '',
    'created': '',
  };

  static Map<String, dynamic> _episodeToJson(dynamic e) => {
    'id': e.id,
    'name': e.name,
    'air_date': e.airDate,
    'episode': e.episode,
    'characters': e.characters,
    'url': '',
    'created': '',
  };

  static Map<String, dynamic> _locationToJson(dynamic l) => {
    'id': l.id,
    'name': l.name,
    'type': l.type,
    'dimension': l.dimension,
    'residents': l.residents,
    'url': '',
    'created': '',
  };
}