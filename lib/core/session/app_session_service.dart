import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSessionService extends GetxService {
  AppSessionService(this._prefs);

  final SharedPreferences _prefs;

  static const _kApiToken = 'bhoomise_session_api_token';

  String? get apiToken => _prefs.getString(_kApiToken);

  Future<void> persistApiToken(String token) async {
    await _prefs.setString(_kApiToken, token);
  }

  Future<void> clearApiToken() async {
    await _prefs.remove(_kApiToken);
  }
}
