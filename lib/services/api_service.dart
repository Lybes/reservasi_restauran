import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String message;
  const AuthResult(this.success, this.message);
}

class ApiService {
  // Web / Windows desktop : http://localhost:3000
  // Emulator Android      : http://10.0.2.2:3000
  // HP fisik (satu WiFi)  : ganti manual ke http://IP_LAPTOP:3000
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  static const _headers = {'Content-Type': 'application/json'};

  static Future<AuthResult> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', body['id'] as int);
        await prefs.setString('user_nama', body['nama'] as String);
        await prefs.setString('user_email', body['email'] as String);
        return const AuthResult(true, 'Login berhasil.');
      }
      return AuthResult(false, (body['message'] ?? 'Login gagal.').toString());
    } on SocketException {
      return const AuthResult(false, 'Tidak bisa terhubung ke server.');
    } on http.ClientException {
      return const AuthResult(false, 'Tidak bisa terhubung ke server.');
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      return const AuthResult(false, 'Terjadi kesalahan. Coba lagi.');
    }
  }

  static Future<AuthResult> register(
    String nama,
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _headers,
            body: jsonEncode({
              'nama': nama,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        return const AuthResult(true, 'Registrasi berhasil. Silakan masuk.');
      }
      return AuthResult(
          false, (body['message'] ?? 'Registrasi gagal.').toString());
    } on SocketException {
      return const AuthResult(false, 'Tidak bisa terhubung ke server.');
    } on http.ClientException {
      return const AuthResult(false, 'Tidak bisa terhubung ke server.');
    } catch (e) {
      debugPrint('REGISTER ERROR: $e');
      return const AuthResult(false, 'Terjadi kesalahan. Coba lagi.');
    }
  }

  static Future<int?> currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}