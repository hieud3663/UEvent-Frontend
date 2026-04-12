class EnvConfig {
  /// Defines whether the app should use mock data models instead of making real API network requests.
  static const bool useMockData = true;

  /// The base URL for the UEvent API.
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1'; // Update to your local or prod environment

  /// Additional global constants can go here
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}
