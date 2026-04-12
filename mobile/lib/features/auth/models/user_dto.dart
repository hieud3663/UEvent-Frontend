import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDTO with _$UserDTO {
  const factory UserDTO({
    required String id,
    required String fullName,
    required String email,
    required String accountStatus,
    required String primaryRole,
    String? phoneNumber,
    String? studentCode,
    String? faculty,
    String? className,
    String? avatarUrl,
  }) = _UserDTO;

  factory UserDTO.fromJson(Map<String, dynamic> json) =>
      _$UserDTOFromJson(json);
}

@freezed
class AuthResponseDTO with _$AuthResponseDTO {
  const factory AuthResponseDTO({
    required String accessToken,
    required int expiresIn,
    required UserDTO user,
  }) = _AuthResponseDTO;

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDTOFromJson(json);
}
