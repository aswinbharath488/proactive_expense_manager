import 'package:shared_preferences/shared_preferences.dart';

import '../constants/prefs_keys.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final p = await SharedPreferences.getInstance();
    return PreferencesService(p);
  }

  bool get onboardingComplete =>
      _prefs.getBool(PrefsKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool v) =>
      _prefs.setBool(PrefsKeys.onboardingComplete, v);

  String? get authToken => _prefs.getString(PrefsKeys.authToken);

  Future<void> setAuthToken(String? v) async {
    if (v == null) {
      await _prefs.remove(PrefsKeys.authToken);
    } else {
      await _prefs.setString(PrefsKeys.authToken, v);
    }
  }

  String? get nickname => _prefs.getString(PrefsKeys.nickname);

  Future<void> setNickname(String? v) async {
    if (v == null) {
      await _prefs.remove(PrefsKeys.nickname);
    } else {
      await _prefs.setString(PrefsKeys.nickname, v);
    }
  }

  String? get phone => _prefs.getString(PrefsKeys.phone);

  Future<void> setPhone(String? v) async {
    if (v == null) {
      await _prefs.remove(PrefsKeys.phone);
    } else {
      await _prefs.setString(PrefsKeys.phone, v);
    }
  }

  double get monthlyExpenseLimit =>
      _prefs.getDouble(PrefsKeys.monthlyExpenseLimit) ?? 1000;

  Future<void> setMonthlyExpenseLimit(double v) =>
      _prefs.setDouble(PrefsKeys.monthlyExpenseLimit, v);

  Future<void> clearSession() async {
    await _prefs.remove(PrefsKeys.authToken);
    await _prefs.remove(PrefsKeys.nickname);
    await _prefs.remove(PrefsKeys.phone);
  }
}
