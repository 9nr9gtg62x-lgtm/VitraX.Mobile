import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thin HTTP client for VitraX.API: handles the base URL per platform,
/// JWT bearer auth, and JSON (de)serialization for every endpoint the
/// mobile app talks to.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'vx_jwt_token';
  String? _token;

  /// Android emulator maps 10.0.2.2 -> host machine's localhost.
  /// iOS simulator / desktop can reach localhost directly.
  /// Override at build time with `--dart-define=VX_API_BASE_URL=...` (e.g. your machine's LAN IP, port 5186).
  static String get baseUrl {
    const override = String.fromEnvironment('VX_API_BASE_URL');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:5186';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5186';
    return 'http://localhost:5186';
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  bool get isAuthenticated => _token != null;

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception('اسم المستخدم أو كلمة المرور غير صحيحة');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveToken(body['token'] as String);
  }

  Future<void> register(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception('تعذر إنشاء الحساب، الاسم مستخدم بالفعل');
    }
  }

  Future<List<dynamic>> getList(String resource) async {
    final res = await http.get(Uri.parse('$baseUrl/api/$resource'), headers: _headers);
    _throwIfUnauthorized(res);
    if (res.statusCode != 200) throw Exception('تعذر تحميل البيانات ($resource)');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> create(String resource, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/$resource'),
      headers: _headers,
      body: jsonEncode(data),
    );
    _throwIfUnauthorized(res);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('تعذر الحفظ ($resource)');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> delete(String resource, int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/$resource/$id'), headers: _headers);
    _throwIfUnauthorized(res);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('تعذر الحذف ($resource/$id)');
    }
  }

  void _throwIfUnauthorized(http.Response res) {
    if (res.statusCode == 401) {
      _token = null;
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى');
    }
  }
}
