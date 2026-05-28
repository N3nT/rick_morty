import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';

class ApiService {
  static const String baseUrl = "https://rickandmortyapi.com/api";

  static Future<Map<String, dynamic>> fetchCharacters({int page = 1}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/character?page=$page")
    );

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return {
        "characters": results.map((json) => Character.fromJson(json)).toList(),
        "totalPages": data["info"]["pages"],
      };
    } else {
      throw Exception("Błąd pobierania postaci");
    }
  }

  static Future<Character> fetchCharacter(int id) async {
    final response = await http.get(
        Uri.parse("$baseUrl/character/$id")
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Character.fromJson(data);
    } else {
      throw Exception("Bład pobierania postaci id:$id");
    }
  }

  //episodes
  static Future<Map<String, dynamic>> fetchEpisodes({int page = 1}) async {
    final response = await http.get(
        Uri.parse("$baseUrl/episode?page=$page")
    );

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return {
        "episodes": results.map((json) => Character.fromJson(json)).toList(),
        "totalPages": data["info"]["pages"],
      };
    } else {
      throw Exception("Błąd pobierania odcinków");
    }
  }

  //episode
  static Future<Episode> fetchEpisode(int id) async {
    final response = await http.get(
        Uri.parse("$baseUrl/episode/$id")
    );

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return Episode.fromJson(data);
    } else{
      throw Exception("Błąd pobierania odcinka id: $id");
    }
  }

  //locations
  static Future<Map<String, dynamic>> fetchLocations({int page = 1}) async {
    final response = await http.get(
        Uri.parse("$baseUrl/location?page=$page")
    );

    if (response.statusCode == 200){
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

  //location
  static Future<Location> fetchLocation(int id) async {
    final response = await http.get(
        Uri.parse("$baseUrl/location/$id")
    );

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return Location.fromJson(data);
    } else{
      throw Exception("Błąd pobierania lokalizacji id: $id");
    }
  }
}