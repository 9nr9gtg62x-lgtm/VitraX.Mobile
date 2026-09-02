import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io' show Platform, SocketException, HandshakeException;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

/// Thin HTTP client for VitraX.API: handles the base URL per platform,
/// JWT bearer auth, and JSON (de)serialization for every endpoint the
/// mobile app talks to.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'vx_jwt_token';
  String? _token;
  String? _username;
  String? _role;

  String? get username => _username;
  String? get role => _role;

  /// Android emulator maps 10.0.2.2 -> host machine's localhost.
  /// iOS simulator / desktop can reach localhost directly.
  /// The ASP.NET Core dev server's HTTPS profile listens on 7272 with a
  /// self-signed cert; see main.dart for the debug-only cert bypass.
  /// NOTE: the cert bypass in main.dart only works for native platforms.
  /// On Flutter Web, the browser (not Dart) does the TLS handshake, so a
  /// self-signed cert on port 7272 will still be rejected there unless you
  /// manually trust it in the browser first (open the API's https URL once
  /// and click through the "not secure" warning), or run the API's HTTP
  /// profile instead for web development.
  /// Override at build time with `--dart-define=VX_API_BASE_URL=...` (e.g. your machine's LAN IP, port 7272).
  static String get baseUrl {
    const override = String.fromEnvironment('VX_API_BASE_URL');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:5186';
    if (!kIsWeb && Platform.isAndroid) return 'https://10.0.2.2:7272';
    return 'https://localhost:7272';
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
    _username = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/api/Auth/login');
    final reqBody = jsonEncode({'username': username, 'password': password});
    // TEMP DEBUG (remove once login is confirmed working): shows exactly
    // what URL/body left the device and what came back, in the console/logcat.
    if (kDebugMode) debugPrint('[ApiClient] LOGIN -> $uri body=$reqBody');
    final res = await _send(
      'POST',
      '/api/Auth/login',
      () => http.post(uri, headers: {'Content-Type': 'application/json'}, body: reqBody),
    );
    if (kDebugMode) {
      debugPrint('[ApiClient] LOGIN <- ${res.statusCode} body=${res.body}');
    }
    if (res.statusCode != 200) {
      // TEMP DEBUG: surface the real status/body while diagnosing; revert to
      // the plain generic message below once login works end-to-end.
      if (kDebugMode) {
        throw Exception('فشل تسجيل الدخول [${res.statusCode}]: ${res.body}');
      }
      throw Exception('اسم المستخدم أو كلمة المرور غير صحيحة');
    }

    // Guard against a malformed/empty body instead of letting a cast throw.
    Object? decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      throw Exception('استجابة غير صالحة من الخادم');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('استجابة غير متوقعة من الخادم');
    }

    final auth = AuthResponse.fromJson(decoded);
    if (auth.token.isEmpty) {
      throw Exception('لم يتم استلام رمز الدخول (token) من الخادم');
    }
    await _saveToken(auth.token);
    _username = auth.username;
    _role = auth.role;
  }

  Future<void> register(String username, String password) async {
    final res = await _send(
      'POST',
      '/api/Auth/register',
      () => http.post(
        Uri.parse('$baseUrl/api/Auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('تعذر إنشاء الحساب، الاسم مستخدم بالفعل');
    }
  }

  Future<List<dynamic>> getList(String resource) async {
    final res = await _send(
      'GET',
      '/api/$resource',
      () => http.get(Uri.parse('$baseUrl/api/$resource'), headers: _headers),
    );
    _throwIfUnauthorized(res);
    if (res.statusCode != 200) throw Exception('تعذر تحميل البيانات ($resource)');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> create(String resource, Map<String, dynamic> data) async {
    final res = await _send(
      'POST',
      '/api/$resource',
      () => http.post(
        Uri.parse('$baseUrl/api/$resource'),
        headers: _headers,
        body: jsonEncode(data),
      ),
    );
    _throwIfUnauthorized(res);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('تعذر الحفظ ($resource)');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> delete(String resource, int id) async {
    final res = await _send(
      'DELETE',
      '/api/$resource/$id',
      () => http.delete(Uri.parse('$baseUrl/api/$resource/$id'), headers: _headers),
    );
    _throwIfUnauthorized(res);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('تعذر الحذف ($resource/$id)');
    }
  }

  /// Runs an HTTP call, logging the outcome (or the connection failure) to
  /// the console so a broken emulator->host connection is visible immediately.
  /// TEMP DEBUG: classifies the common local-dev failure modes (no route to
  /// host, TLS handshake rejected, server too slow, bad JSON) so they show up
  /// as a distinct, readable message instead of a generic one.
  Future<http.Response> _send(
    String method,
    String path,
    Future<http.Response> Function() call,
  ) async {
    try {
      final res = await call().timeout(const Duration(seconds: 10));
      if (res.statusCode >= 400) {
        debugPrint('[ApiClient] $method $baseUrl$path -> ${res.statusCode}: ${res.body}');
      }
      return res;
    } on SocketException catch (e) {
      debugPrint('[ApiClient] $method $baseUrl$path SocketException: $e');
      if (kDebugMode) {
        throw Exception('تعذر الوصول إلى الخادم (SocketException): ${e.message}');
      }
      rethrow;
    } on HandshakeException catch (e) {
      debugPrint('[ApiClient] $method $baseUrl$path HandshakeException: $e');
      if (kDebugMode) {
        throw Exception('فشل التحقق من شهادة SSL (HandshakeException): $e');
      }
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[ApiClient] $method $baseUrl$path TimeoutException: $e');
      if (kDebugMode) {
        throw Exception('انتهت مهلة الاتصال بالخادم (TimeoutException)');
      }
      rethrow;
    } on FormatException catch (e) {
      debugPrint('[ApiClient] $method $baseUrl$path FormatException: $e');
      if (kDebugMode) {
        throw Exception('استجابة غير صالحة من الخادم (FormatException): $e');
      }
      rethrow;
    } catch (e) {
      debugPrint('[ApiClient] $method $baseUrl$path failed: $e');
      rethrow;
    }
  }

  void _throwIfUnauthorized(http.Response res) {
    if (res.statusCode == 401) {
      _token = null;
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى');
    }
  }
}
