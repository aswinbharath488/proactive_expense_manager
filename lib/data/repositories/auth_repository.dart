import '../../core/services/preferences_service.dart';
import '../api/api_client.dart';
import '../models/auth_responses.dart';

class AuthRepository {
  AuthRepository(this._api, this._prefs);

  final ApiClient _api;
  final PreferencesService _prefs;

  Future<SendOtpResponse> sendOtp(String phoneE164) async {
    final map = await _api.postJson(
      '/auth/send-otp/',
      body: {'phone': phoneE164},
    );
    return SendOtpResponse.fromJson(map);
  }

  Future<CreateAccountResponse> createAccount({
    required String phoneE164,
    required String nickname,
  }) async {
    final map = await _api.postJson(
      '/auth/create-account/',
      body: {'phone': phoneE164, 'nickname': nickname},
    );
    return CreateAccountResponse.fromJson(map);
  }

  Future<void> persistSession({
    required String token,
    required String nickname,
    required String phone,
  }) async {
    _api.bearerToken = token;
    await _prefs.setAuthToken(token);
    await _prefs.setNickname(nickname);
    await _prefs.setPhone(phone);
  }

  void applyTokenFromPrefs() {
    final t = _prefs.authToken;
    if (t != null && t.isNotEmpty) {
      _api.bearerToken = t;
    }
  }

  Future<void> logout() async {
    _api.bearerToken = null;
    await _prefs.clearSession();
  }
}
