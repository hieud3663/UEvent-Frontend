// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'token_response_dto.dart';

class TokenResponseDtoMapper extends ClassMapperBase<TokenResponseDto> {
  TokenResponseDtoMapper._();

  static TokenResponseDtoMapper? _instance;
  static TokenResponseDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TokenResponseDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TokenResponseDto';

  static String _$accessToken(TokenResponseDto v) => v.accessToken;
  static const Field<TokenResponseDto, String> _f$accessToken = Field(
    'accessToken',
    _$accessToken,
    key: r'access_token',
  );
  static String _$refreshToken(TokenResponseDto v) => v.refreshToken;
  static const Field<TokenResponseDto, String> _f$refreshToken = Field(
    'refreshToken',
    _$refreshToken,
    key: r'refresh_token',
  );
  static String? _$idToken(TokenResponseDto v) => v.idToken;
  static const Field<TokenResponseDto, String> _f$idToken = Field(
    'idToken',
    _$idToken,
    key: r'id_token',
    opt: true,
  );
  static int _$expiresIn(TokenResponseDto v) => v.expiresIn;
  static const Field<TokenResponseDto, int> _f$expiresIn = Field(
    'expiresIn',
    _$expiresIn,
    key: r'expires_in',
  );
  static String _$tokenType(TokenResponseDto v) => v.tokenType;
  static const Field<TokenResponseDto, String> _f$tokenType = Field(
    'tokenType',
    _$tokenType,
    key: r'token_type',
  );

  @override
  final MappableFields<TokenResponseDto> fields = const {
    #accessToken: _f$accessToken,
    #refreshToken: _f$refreshToken,
    #idToken: _f$idToken,
    #expiresIn: _f$expiresIn,
    #tokenType: _f$tokenType,
  };

  static TokenResponseDto _instantiate(DecodingData data) {
    return TokenResponseDto(
      accessToken: data.dec(_f$accessToken),
      refreshToken: data.dec(_f$refreshToken),
      idToken: data.dec(_f$idToken),
      expiresIn: data.dec(_f$expiresIn),
      tokenType: data.dec(_f$tokenType),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TokenResponseDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TokenResponseDto>(map);
  }

  static TokenResponseDto fromJson(String json) {
    return ensureInitialized().decodeJson<TokenResponseDto>(json);
  }
}

mixin TokenResponseDtoMappable {
  String toJson() {
    return TokenResponseDtoMapper.ensureInitialized()
        .encodeJson<TokenResponseDto>(this as TokenResponseDto);
  }

  Map<String, dynamic> toMap() {
    return TokenResponseDtoMapper.ensureInitialized()
        .encodeMap<TokenResponseDto>(this as TokenResponseDto);
  }

  TokenResponseDtoCopyWith<TokenResponseDto, TokenResponseDto, TokenResponseDto>
  get copyWith =>
      _TokenResponseDtoCopyWithImpl<TokenResponseDto, TokenResponseDto>(
        this as TokenResponseDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TokenResponseDtoMapper.ensureInitialized().stringifyValue(
      this as TokenResponseDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return TokenResponseDtoMapper.ensureInitialized().equalsValue(
      this as TokenResponseDto,
      other,
    );
  }

  @override
  int get hashCode {
    return TokenResponseDtoMapper.ensureInitialized().hashValue(
      this as TokenResponseDto,
    );
  }
}

extension TokenResponseDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TokenResponseDto, $Out> {
  TokenResponseDtoCopyWith<$R, TokenResponseDto, $Out>
  get $asTokenResponseDto =>
      $base.as((v, t, t2) => _TokenResponseDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TokenResponseDtoCopyWith<$R, $In extends TokenResponseDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    int? expiresIn,
    String? tokenType,
  });
  TokenResponseDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TokenResponseDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TokenResponseDto, $Out>
    implements TokenResponseDtoCopyWith<$R, TokenResponseDto, $Out> {
  _TokenResponseDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TokenResponseDto> $mapper =
      TokenResponseDtoMapper.ensureInitialized();
  @override
  $R call({
    String? accessToken,
    String? refreshToken,
    Object? idToken = $none,
    int? expiresIn,
    String? tokenType,
  }) => $apply(
    FieldCopyWithData({
      if (accessToken != null) #accessToken: accessToken,
      if (refreshToken != null) #refreshToken: refreshToken,
      if (idToken != $none) #idToken: idToken,
      if (expiresIn != null) #expiresIn: expiresIn,
      if (tokenType != null) #tokenType: tokenType,
    }),
  );
  @override
  TokenResponseDto $make(CopyWithData data) => TokenResponseDto(
    accessToken: data.get(#accessToken, or: $value.accessToken),
    refreshToken: data.get(#refreshToken, or: $value.refreshToken),
    idToken: data.get(#idToken, or: $value.idToken),
    expiresIn: data.get(#expiresIn, or: $value.expiresIn),
    tokenType: data.get(#tokenType, or: $value.tokenType),
  );

  @override
  TokenResponseDtoCopyWith<$R2, TokenResponseDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TokenResponseDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

