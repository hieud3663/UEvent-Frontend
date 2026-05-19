// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpTokenDto _$OtpTokenDtoFromJson(Map<String, dynamic> json) => OtpTokenDto(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  tokenType: json['token_type'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
  refreshExpiresIn: (json['refresh_expires_in'] as num).toInt(),
);

Map<String, dynamic> _$OtpTokenDtoToJson(OtpTokenDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'refresh_expires_in': instance.refreshExpiresIn,
    };
