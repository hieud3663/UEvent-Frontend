// File: lib/features/auth/dtos/token_response_dto.dart

import 'package:dart_mappable/dart_mappable.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';

part 'token_response_dto.mapper.dart';

/// DTO mirroring the Keycloak OIDC token endpoint response.
///
/// Used only inside [AuthService] to parse the raw response from
/// `flutter_appauth`. Never exposed to Controller or UI layers.
@MappableClass()
class TokenResponseDto with TokenResponseDtoMappable {
  @MappableField(key: 'access_token')
  final String accessToken;

  @MappableField(key: 'refresh_token')
  final String refreshToken;

  @MappableField(key: 'id_token')
  final String? idToken;

  /// Token lifetime in seconds (e.g. 300 for Keycloak's default 5 min).
  @MappableField(key: 'expires_in')
  final int expiresIn;

  @MappableField(key: 'token_type')
  final String tokenType;

  const TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    this.idToken,
    required this.expiresIn,
    required this.tokenType,
  });
}

/// Extension to convert DTO → business model.
extension TokenResponseDtoMapping on TokenResponseDto {
  /// Converts to [AuthSessionModel] by computing the absolute expiry time.
  AuthSessionModel toModel(AuthMethod method) {
    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      method: method,
    );
  }
}
