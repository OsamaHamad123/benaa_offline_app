import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens.g.dart';

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String? userId;
  final String? username;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.username,
    required this.expiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && accessToken.isNotEmpty;

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? username,
    DateTime? expiresAt,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn; // seconds

  @JsonKey(name: 'user_id')
  final String? userId;

  final String? username;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.userId,
    this.username,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  AuthTokens toAuthTokens() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      username: username,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }
}
