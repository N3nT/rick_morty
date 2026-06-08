import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';

class ApiService {
  static const String baseUrl = "https://rickandmortyapi.com/api";
  static const Duration _timeout = Duration(seconds: 10);

  // Characters

  static Future<Map<String, dynamic>> fetchCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  }) async {
    final params = {"page": "$page"};
    if (name != null && name.isNotEmpty) params["name"] = name;
    if (status != null && status.isNotEmpty) params["status"] = status;
    if (species != null && species.isNotEmpty) params["species"] = species;
    if (type != null && type.isNotEmpty) params["type"] = type;
    if (gender != null && gender.isNotEmpty) params["gender"] = gender;

    final response = await _get("/character", params);
    if (response.statusCode == 404) {
      return {"characters": <Character>[], "totalPages": 0};
    }
    _checkStatus(response, "postaci");
    final data = jsonDecode(response.body);
    return {
      "characters": (data["results"] as List)
          .map((json) => Character.fromJson(json))
          .toList(),
      "totalPages": data["info"]["pages"],
    };
  }

  static Future<Character> fetchCharacter(int id) async {
    final response = await _get("/character/$id");
    _checkStatus(response, "postaci");
    return Character.fromJson(jsonDecode(response.body));
  }

  static Future<List<Character>> fetchCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final response = await _get("/character/${ids.join(",")}");
    _checkStatus(response, "postaci");
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((json) => Character.fromJson(json)).toList();
    }
    return [Character.fromJson(data)];
  }

  // Episodes

  static Future<Map<String, dynamic>> fetchEpisodes({int page = 1}) async {
    final response = await _get("/episode", {"page": "$page"});
    _checkStatus(response, "epizodów");
    final data = jsonDecode(response.body);
    return {
      "episodes": (data["results"] as List)
          .map((json) => Episode.fromJson(json))
          .toList(),
      "totalPages": data["info"]["pages"],
    };
  }

  static Future<Episode> fetchEpisode(int id) async {
    final response = await _get("/episode/$id");
    _checkStatus(response, "epizodu");
    return Episode.fromJson(jsonDecode(response.body));
  }

  // Locations

  static Future<Map<String, dynamic>> fetchLocations({int page = 1}) async {
    final response = await _get("/location", {"page": "$page"});
    _checkStatus(response, "lokacji");
    final data = jsonDecode(response.body);
    return {
      "locations": (data["results"] as List)
          .map((json) => Location.fromJson(json))
          .toList(),
      "totalPages": data["info"]["pages"],
    };
  }

  static Future<Location> fetchLocation(int id) async {
    final response = await _get("/location/$id");
    _checkStatus(response, "lokacji");
    return Location.fromJson(jsonDecode(response.body));
  }

  // HTTP core

  static Future<http.Response> _get(String path,
      [Map<String, String>? params]) async {
    try {
      final uri = Uri.parse("$baseUrl$path")
          .replace(queryParameters: params);
      return await http.get(uri).timeout(_timeout);
    } on SocketException {
      throw const AppException("Brak połączenia z internetem.");
    } on HttpException {
      throw const AppException("Błąd połączenia z serwerem.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException("Przekroczono czas oczekiwania na odpowiedź.");
    }
  }

  static void _checkStatus(http.Response response, String resource) {
    switch (response.statusCode) {
      case 200: return;
      case 404: throw AppException("Nie znaleziono $resource.");
      case 429: throw const AppException("Zbyt wiele zapytań. Poczekaj chwilę.");
      case 500:
      case 502:
      case 503: throw const AppException("Serwer chwilowo niedostępny.\nSpróbuj ponownie za chwilę.");
      default: throw AppException("Błąd serwera (${response.statusCode}).");
    }
  }
}

// Własny wyjątek z czytelnym komunikatem
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}