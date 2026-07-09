import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';

class SearchRecentStore {
  static const _usersKey = 'search_recent_users';
  static const maxUsers = 15;

  Future<List<SearchRecentUser>> getRecentUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SearchRecentUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentUsers(List<SearchRecentUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  Future<void> addRecentUser(SearchRecentUser user) async {
    final current = await getRecentUsers();
    final filtered = current.where((u) => u.userId != user.userId).toList();
    filtered.insert(0, user);
    await saveRecentUsers(filtered.take(maxUsers).toList());
  }

  Future<void> addRecentFromResult(UserSearchResult result) {
    return addRecentUser(
      SearchRecentUser(
        userId: result.userId,
        fullName: result.fullName,
        avatarUrl: result.avatarUrl,
        visitedAt: DateTime.now(),
        presenceLabel: result.presenceLabel,
      ),
    );
  }

  Future<void> removeRecentUser(String userId) async {
    final current = await getRecentUsers();
    current.removeWhere((u) => u.userId == userId);
    await saveRecentUsers(current);
  }

  Future<void> clearRecentUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
  }

  Future<void> clearAll() => clearRecentUsers();

  Future<void> seedDefaultsIfEmpty(List<SearchRecentUser> defaults) async {
    final current = await getRecentUsers();
    if (current.isNotEmpty) return;
    await saveRecentUsers(defaults.take(maxUsers).toList());
  }
}
