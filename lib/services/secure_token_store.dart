import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStore {
  static const _key = 'netsuite_access_token';
  static const _accountKey = 'netsuite_account_id';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {
      // On macOS debug without proper keychain entitlement, avoid crashing.
    }
  }

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAccountId(String accountId) async {
    try {
      await _storage.write(key: _accountKey, value: accountId);
    } catch (_) {}
  }

  Future<String?> readAccountId() async {
    try {
      return await _storage.read(key: _accountKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
      await _storage.delete(key: _accountKey);
    } catch (_) {
      // Ignore keychain entitlement issues in local dev.
    }
  }
}
