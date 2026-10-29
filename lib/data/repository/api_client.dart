// ============================================================
//  API CLIENT — Saari HTTP calls yahan se jaati hain
//
//  Features:
//   • Automatically JWT token attach karta hai (Authorization header)
//   • JSON parse karta hai
//   • Errors ek jagah handle karta hai
//
//  Screens ko seedha use karne ki zaroorat nahi — AppRepository
//  ke through data aata hai.
// ============================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';

/// HTTP request fail hone pe yeh exception throw hoti hai
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();

  // Secure storage for encrypted JWT persistence (Android Keystore / iOS Keychain)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );
  static const String _kToken = 'jwt_token';

  // ============================================================
  //  TOKEN MANAGEMENT
  // ============================================================

  /// Login ke baad JWT token securely save karo
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _kToken, value: token);
  }

  /// Abhi ka saved token secure storage se padhna
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _kToken);
  }

  /// Logout pe token hata do
  static Future<void> clearToken() async {
    await _secureStorage.delete(key: _kToken);
  }

  // ============================================================
  //  HTTP HELPERS
  // ============================================================

  /// Standard headers (JSON + optional JWT)
  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Response body parse karo + error check karo
  Map<String, dynamic> _parse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(response.statusCode, 'Server se invalid response aaya.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = (body['message'] as String?) ??
        (body['error'] as String?) ??
        'Request fail ho gayi (${response.statusCode})';
    throw ApiException(response.statusCode, message);
  }

  /// GET request — auth=true matlab JWT header lagega
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/$path')
        .replace(queryParameters: query);
    try {
      final response = await _client
          .get(uri, headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 15));
      return _parse(response);
    } on SocketException {
      throw ApiException(0, 'Server se connect nahi ho paya. PC ka IP aur server check karein.');
    } on TimeoutException {
      throw ApiException(0, 'Server ka response nahi mila. PHP server aur port 8000 firewall check karein.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'Network error: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/$path');
    try {
      final response = await _client
          .post(uri,
              headers: await _headers(auth: auth),
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      return _parse(response);
    } on SocketException {
      throw ApiException(0, 'Server se connect nahi ho paya. PC ka IP aur server check karein.');
    } on TimeoutException {
      throw ApiException(0, 'Server ka response nahi mila. PHP server aur port 8000 firewall check karein.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'Network error: $e');
    }
  }
}
