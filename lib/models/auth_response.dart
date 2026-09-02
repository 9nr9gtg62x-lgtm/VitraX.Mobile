/// Response body of POST /api/Auth/login: { "token": "...", "username": "...", "role": "..." }.
/// Keys are read as camelCase to match the API's JSON casing exactly.
class AuthResponse {
  final String token;
  final String username;
  final String role;

  AuthResponse({
    required this.token,
    required this.username,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );
}
