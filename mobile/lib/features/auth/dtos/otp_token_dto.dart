// File: lib/features/auth/dtos/otp_token_dto.dart

import 'package:json_annotation/json_annotation.dart';

part 'otp_token_dto.g.dart';

/// DTO khớp với response của `POST /api/v1/auth/otp/verify/`
/// (nằm trong envelope `data`).
@JsonSerializable(fieldRename: FieldRename.snake)
class OtpTokenDto {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final int refreshExpiresIn;

  const OtpTokenDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  factory OtpTokenDto.fromJson(Map<String, dynamic> json) =>
      _$OtpTokenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OtpTokenDtoToJson(this);
}
