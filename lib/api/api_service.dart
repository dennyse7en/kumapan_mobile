// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kumapan_mobile/models/credit_application.dart';
import 'package:kumapan_mobile/models/credit_application_detail.dart';
import 'dart:io';
import 'dart:async';

class ApiService {
  // Ganti dengan IP address lokal Anda jika menguji di perangkat fisik,
  // atau biarkan jika menggunakan emulator Android.
  final String _baseUrl = "http://192.168.43.105:8000/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Jika berhasil, simpan token
        String token = responseData['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return {
          'success': true,
          'message': 'Login berhasil!',
          'user': responseData['user'],
        };
      } else {
        // Jika gagal (misal: password salah)
        return {
          'success': false,
          'message': responseData['message'] ?? 'Kredensial tidak cocok.',
        };
      }
    } on TimeoutException {
      // Tangani error timeout secara spesifik
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<List<CreditApplication>> getCreditApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/credit-applications'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CreditApplication.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data pengajuan');
    }
  }

  Future<CreditApplicationDetail> getCreditApplicationDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/credit-applications/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return CreditApplicationDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat detail pengajuan');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      // Jika tidak ada token, anggap sudah logout
      return;
    }

    try {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } finally {
      // Apapun yang terjadi (berhasil atau gagal), hapus token dari perangkat
      await prefs.remove('auth_token');
    }
  }

  Future<Map<String, dynamic>> createCreditApplication(
    Map<String, String> data,
    File ktpImage,
    File businessPhotoImage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/credit-applications'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Tambahkan data teks
    request.fields.addAll(data);

    // Tambahkan file gambar
    request.files
        .add(await http.MultipartFile.fromPath('ktp_path', ktpImage.path));
    request.files.add(await http.MultipartFile.fromPath(
        'business_photo_path', businessPhotoImage.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Pengajuan berhasil dibuat!'};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal membuat pengajuan.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }
}
