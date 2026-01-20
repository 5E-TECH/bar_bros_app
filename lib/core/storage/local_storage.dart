import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';


abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> saveVerificationToken(String token);
  Future<String?> getVerificationToken();
  Future<void> clearVerificationToken();
  Future<void> clearTokens();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUserFullName(String fullName);
  Future<String?> getUserFullName();
}
@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;

  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _verificationTokenKey = "verification_token";
  static const String _userIdKey = "user_id";
  static const String _userFullNameKey = "user_full_name";

  LocalStorageImpl(this._prefs);


  @override
  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_verificationTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  @override
  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_accessTokenKey, token);
  }

  @override
  Future<void> saveVerificationToken(String token) async {
    await _prefs.setString(_verificationTokenKey, token);
  }

  @override
  Future<String?> getVerificationToken() async {
    return _prefs.getString(_verificationTokenKey);
  }

  @override
  Future<void> clearVerificationToken() async {
    await _prefs.remove(_verificationTokenKey);
  }

  @override
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  @override
  Future<void> saveUserFullName(String fullName) async {
    await _prefs.setString(_userFullNameKey, fullName);
  }

  @override
  Future<String?> getUserFullName() async {
    return _prefs.getString(_userFullNameKey);
  }

}
@module
abstract class StorageModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
