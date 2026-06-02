import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logCharacterViewed(int id, String name) async {
    await _analytics.logEvent(
      name: 'character_viewed',
      parameters: {
        'character_id': id,
        'character_name': name,
      },
    );
  }

  static Future<void> logEpisodeViewed(int id, String name, String code) async {
    await _analytics.logEvent(
      name: 'episode_viewed',
      parameters: {
        'episode_id': id,
        'episode_name': name,
        'episode_code': code,
      },
    );
  }

  static Future<void> logLocationViewed(int id, String name) async {
    await _analytics.logEvent(
      name: 'location_viewed',
      parameters: {
        'location_id': id,
        'location_name': name,
      },
    );
  }

  static Future<void> logFavoriteAdded(int id, String name) async {
    await _analytics.logEvent(
      name: 'favorite_added',
      parameters: {
        'character_id': id,
        'character_name': name,
      },
    );
  }

  static Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }
}