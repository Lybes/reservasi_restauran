import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? role;
  const AuthResult(this.success, this.message, {this.role});
}

class ApiService {
  // Web / Windows / macOS / Linux : http://localhost:3000
  // Emulator Android              : http://10.0.2.2:3000
  // HP fisik                      : ganti ke http://IP_LAPTOP:3000
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  static const _headers = {'Content-Type': 'application/json'};

  // ---------- AUTH ----------
  static Future<AuthResult> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _headers,
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final role = (body['role'] ?? 'pelanggan').toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', body['id'] as int);
        await prefs.setString('user_nama', body['nama'] as String);
        await prefs.setString('user_email', body['email'] as String);
        await prefs.setString('user_role', role);
        return AuthResult(true, 'Login berhasil.', role: role);
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
    String password, {
    String role = 'pelanggan',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _headers,
            body: jsonEncode({
              'nama': nama.trim(),
              'email': email.trim(),
              'password': password,
              'role': role,
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

  static Future<String?> currentUserNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_nama');
  }

  static Future<String?> currentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<String?> currentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> isAdmin() async {
    final role = await currentUserRole();
    return role == 'admin';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ---------- STATS (ADMIN) ----------
  static Future<Map<String, dynamic>?> fetchAdminStats() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/admin/stats'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('FETCH STATS ERROR: $e');
    }
    return null;
  }

  // ---------- RESERVATIONS ----------
  static Future<List<Map<String, dynamic>>> fetchReservations({
    int? userId,
    String? status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/reservations').replace(
        queryParameters: {
          if (userId != null) 'user_id': userId.toString(),
          if (status != null && status != 'Semua') 'status': status,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('FETCH RESERVATIONS ERROR: $e');
    }
    return [];
  }

  static Future<bool> createReservation({
    int? userId,
    required String customerName,
    required String roomName,
    required String tanggal,
    required String waktu,
    required String jumlahOrang,
    String catatan = '',
    int totalHarga = 0,
    List<Map<String, dynamic>> items = const [],
  }) async {
    try {
      final uid = userId ?? await currentUserId();
      // Pisahkan waktu jika berformat "18:00 - 20:00" atau "18:00"
      String jamMulai = waktu.trim();
      String jamSelesai = '';
      if (jamMulai.contains('-')) {
        final parts = jamMulai.split('-');
        jamMulai = parts[0].trim();
        jamSelesai = parts[1].trim();
      }

      final res = await http
          .post(
            Uri.parse('$baseUrl/reservations'),
            headers: _headers,
            body: jsonEncode({
              'user_id': uid,
              'ruangan_nama': roomName,
              'customer_name': customerName,
              'tanggal': tanggal,
              'jam_mulai': jamMulai,
              'jam_selesai': jamSelesai.isNotEmpty ? jamSelesai : null,
              'jumlah_orang': jumlahOrang,
              'catatan': catatan,
              'total_harga': totalHarga,
              'items': items,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return res.statusCode == 201;
    } catch (e) {
      debugPrint('CREATE RESERVATION ERROR: $e');
      return false;
    }
  }

  static Future<bool> updateReservationStatus(int id, String status) async {
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl/reservations/$id/status'),
            headers: _headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('UPDATE STATUS ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteReservation(int id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/reservations/$id'))
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('DELETE RESERVATION ERROR: $e');
      return false;
    }
  }

  // ---------- ROOMS ----------
  static Future<List<Map<String, dynamic>>> fetchRooms() async {
    try {
      final res =
          await http.get(Uri.parse('$baseUrl/rooms')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('FETCH ROOMS ERROR: $e');
    }
    return [];
  }

  static Future<bool> addRoom({
    required String nama,
    required int kapasitas,
    required int hargaPerJam,
    required String deskripsi,
    String? gambar,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/rooms'),
            headers: _headers,
            body: jsonEncode({
              'nama_ruangan': nama,
              'kapasitas': kapasitas,
              'harga_per_jam': hargaPerJam,
              'deskripsi': deskripsi,
              'gambar': gambar,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 201;
    } catch (e) {
      debugPrint('ADD ROOM ERROR: $e');
      return false;
    }
  }

  static Future<bool> updateRoom({
    required int id,
    required String nama,
    required int kapasitas,
    required int hargaPerJam,
    required String deskripsi,
    String? gambar,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl/rooms/$id'),
            headers: _headers,
            body: jsonEncode({
              'nama_ruangan': nama,
              'kapasitas': kapasitas,
              'harga_per_jam': hargaPerJam,
              'deskripsi': deskripsi,
              'gambar': gambar,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('UPDATE ROOM ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteRoom(int id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/rooms/$id'))
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('DELETE ROOM ERROR: $e');
      return false;
    }
  }

  // ---------- MENU ----------
  static Future<List<Map<String, dynamic>>> fetchMenu({String? kategori}) async {
    try {
      final uri = Uri.parse('$baseUrl/menu').replace(
        queryParameters: {
          if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('FETCH MENU ERROR: $e');
    }
    return [];
  }

  static Future<bool> addMenu({
    required String nama,
    required String kategori,
    required int harga,
    String? gambar,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/menu'),
            headers: _headers,
            body: jsonEncode({
              'nama': nama,
              'kategori': kategori,
              'harga': harga,
              'gambar': gambar,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 201;
    } catch (e) {
      debugPrint('ADD MENU ERROR: $e');
      return false;
    }
  }

  static Future<bool> updateMenu({
    required int id,
    required String nama,
    required String kategori,
    required int harga,
    String? gambar,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl/menu/$id'),
            headers: _headers,
            body: jsonEncode({
              'nama': nama,
              'kategori': kategori,
              'harga': harga,
              'gambar': gambar,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('UPDATE MENU ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteMenu(int id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/menu/$id'))
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('DELETE MENU ERROR: $e');
      return false;
    }
  }
}
