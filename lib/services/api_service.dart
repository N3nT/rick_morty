import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';

class ApiService {
  static const String baseUrl = "https://rickandmortyapi.com/api";

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

    final uri = Uri.parse("$baseUrl/character").replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return {
        "characters": results.map((json) => Character.fromJson(json)).toList(),
        "totalPages": data["info"]["pages"],
      };
    } else if (response.statusCode == 404) {
      return {"characters": <Character>[], "totalPages": 0};
    } else {
      throw Exception("Błąd pobierania postaci");
    }
  }

  static Future<Character> fetchCharacter(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/character/$id"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Character.fromJson(data);
    } else {
      throw Exception("Błąd pobierania postaci o id: $id");
    }
  }

  static Future<List<Character>> fetchCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final idsStr = ids.join(",");
    final response = await http.get(
      Uri.parse("$baseUrl/character/$idsStr"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API zwraca obiekt gdy jeden id, tablicę gdy wiele
      if (data is List) {
        return data.map((json) => Character.fromJson(json)).toList();
      } else {
        return [Character.fromJson(data)];
      }
    } else {
      throw Exception("Błąd pobierania postaci");
    }
  }

  static Future<Map<String, dynamic>> fetchEpisodes({int page = 1}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/episode?page=$page"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return {
        "episodes": results.map((json) => Episode.fromJson(json)).toList(),
        "totalPages": data["info"]["pages"],
      };
    } else {
      throw Exception("Błąd pobierania epizodów");
    }
  }

  static Future<Episode> fetchEpisode(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/episode/$id"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Episode.fromJson(data);
    } else {
      throw Exception("Błąd pobierania epizodu o id: $id");
    }
  }

  //Locations
  static Future<Map<String, dynamic>> fetchLocations({int page = 1}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/location?page=$page"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return {
        "locations": results.map((json) => Location.fromJson(json)).toList(),
        "totalPages": data["info"]["pages"],
      };
    } else {
      throw Exception("Błąd pobierania lokalizacji");
    }
  }

  static Future<Location> fetchLocation(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/location/$id"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Location.fromJson(data);
    } else {
      throw Exception("Błąd pobierania lokalizacji o id: $id");
    }
  }
}