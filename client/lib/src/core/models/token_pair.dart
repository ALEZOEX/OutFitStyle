/// Модель пары токенов (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
class TokenPair {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String,
      refreshToken: json['refresh_token'] as String? ?? json['refreshToken'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  static String _maskToken(String token) {
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  @override
  String toString() =>
      'TokenPair(accessToken: ${_maskToken(accessToken)}, refreshToken: ${_maskToken(refreshToken)}, expiresAt: $expiresAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenPair &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode ^ expiresAt.hashCode;
}
