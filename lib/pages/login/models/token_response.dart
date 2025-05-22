class TokenResponse {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final int refreshExpiresIn;
  final String tokenType;
  final String sessionState;
  final List<String> scope;

  TokenResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.tokenType,
    required this.sessionState,
    required this.scope,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
      refreshExpiresIn: json['refresh_expires_in'],
      tokenType: json['token_type'],
      sessionState: json['session_state'],
      scope: (json['scope'] as String?)?.split(' ') ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'refresh_expires_in': refreshExpiresIn,
      'token_type': tokenType,
      'session_state': sessionState,
      'scope': scope.join(' '),
    };
  }
}
