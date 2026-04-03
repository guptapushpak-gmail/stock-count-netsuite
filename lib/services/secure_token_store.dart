import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists auth credentials to a local file in the app's support directory.
/// Uses flutter_secure_storage as primary, falls back to file storage so tokens
/// are always reliably persisted on macOS debug builds where the keychain may
/// be unavailable.
class SecureTokenStore {
  static const _fileName = '.auth_store';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<Map<String, String>> _readAll() async {
    try {
      final f = await _file();
      if (!await f.exists()) return {};
      final raw = await f.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  Future<void> _writeAll(Map<String, String> data) async {
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> saveToken(String token) async {
    final data = await _readAll();
    data['token'] = token;
    await _writeAll(data);
  }

  Future<String?> readToken() async {
    final data = await _readAll();
    final v = data['token'];
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> saveAccountId(String accountId) async {
    final data = await _readAll();
    data['accountId'] = accountId;
    await _writeAll(data);
  }

  Future<String?> readAccountId() async {
    final data = await _readAll();
    final v = data['accountId'];
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> clear() async {
    try {
      final f = await _file();
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
