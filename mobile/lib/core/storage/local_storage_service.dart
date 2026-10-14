import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Kiểm tra có token hợp lệ không
  bool hasToken() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Lấy access token
  String? getAccessToken() {
    return _prefs.getString(_keyAccessToken);
  }

  /// Lưu thông tin phiên đăng nhập
  Future<bool> saveAuthSession({
    required String token,
    required String userId,
    required String name,
    required String email,
  }) async {
    final s1 = await _prefs.setString(_keyAccessToken, token);
    final s2 = await _prefs.setString(_keyUserId, userId);
    final s3 = await _prefs.setString(_keyUserName, name);
    final s4 = await _prefs.setString(_keyUserEmail, email);
    return s1 && s2 && s3 && s4;
  }

  /// Lấy thông tin người dùng đã lưu
  Map<String, String>? getSavedUser() {
    final token = getAccessToken();
    if (token == null || token.isEmpty) return null;

    return {
      'id': _prefs.getString(_keyUserId) ?? '',
      'name': _prefs.getString(_keyUserName) ?? '',
      'email': _prefs.getString(_keyUserEmail) ?? '',
    };
  }

  /// Xóa sạch thông tin phiên đăng nhập khi đăng xuất
  Future<void> clearAuthSession() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
  }
}
