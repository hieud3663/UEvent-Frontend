class EnvConfig {
  /// Defines whether the app should use mock data models instead of making real API network requests.
  static const bool useMockData = false;

  /// The base URL for the UEvent API.
  static const String baseUrl =
      // 'http://10.0.2.2:8000/api/v1';
      'http://192.168.1.30:8000/api/v1';

  /// Additional global constants can go here
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  // ── Keycloak OIDC ──

  /// The Keycloak realm issuer URL. The discovery document lives at
  /// `$keycloakIssuer/.well-known/openid-configuration`.
  static const String keycloakIssuer =
      'https://auth.bientrandev.me/realms/uevent'; // Update to your Keycloak domain

  /// Public OIDC client — no client_secret in the mobile binary.
  static const String keycloakClientId = 'uevent-mobile';

  /// Custom-scheme redirect URI for the PKCE authorization code flow.
  static const String keycloakRedirectUri = 'app.uevent://oauth/callback';

  /// Post-logout redirect URI for the end-session endpoint.
  static const String keycloakPostLogoutRedirectUri =
      'app.uevent://oauth/logout';

  /// OIDC scopes. `offline_access` is required to receive a refresh token.
  static const List<String> keycloakScopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  /// Google Web Client ID for Google Sign-In and Token Exchange.
  static const String googleServerClientId =
      '228407044477-8t5bcmq669ns2n2a9iitnohd3lhs8oi3.apps.googleusercontent.com';
}
