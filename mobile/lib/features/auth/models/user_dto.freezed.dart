// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDTO {

 String get id; String get fullName; String get email; String get accountStatus; String get primaryRole; String? get phoneNumber; String? get studentCode; String? get faculty; String? get className; String? get avatarUrl;
/// Create a copy of UserDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDTOCopyWith<UserDTO> get copyWith => _$UserDTOCopyWithImpl<UserDTO>(this as UserDTO, _$identity);

  /// Serializes this UserDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.primaryRole, primaryRole) || other.primaryRole == primaryRole)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.studentCode, studentCode) || other.studentCode == studentCode)&&(identical(other.faculty, faculty) || other.faculty == faculty)&&(identical(other.className, className) || other.className == className)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,accountStatus,primaryRole,phoneNumber,studentCode,faculty,className,avatarUrl);

@override
String toString() {
  return 'UserDTO(id: $id, fullName: $fullName, email: $email, accountStatus: $accountStatus, primaryRole: $primaryRole, phoneNumber: $phoneNumber, studentCode: $studentCode, faculty: $faculty, className: $className, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $UserDTOCopyWith<$Res>  {
  factory $UserDTOCopyWith(UserDTO value, $Res Function(UserDTO) _then) = _$UserDTOCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String email, String accountStatus, String primaryRole, String? phoneNumber, String? studentCode, String? faculty, String? className, String? avatarUrl
});




}
/// @nodoc
class _$UserDTOCopyWithImpl<$Res>
    implements $UserDTOCopyWith<$Res> {
  _$UserDTOCopyWithImpl(this._self, this._then);

  final UserDTO _self;
  final $Res Function(UserDTO) _then;

/// Create a copy of UserDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? accountStatus = null,Object? primaryRole = null,Object? phoneNumber = freezed,Object? studentCode = freezed,Object? faculty = freezed,Object? className = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,accountStatus: null == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as String,primaryRole: null == primaryRole ? _self.primaryRole : primaryRole // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,studentCode: freezed == studentCode ? _self.studentCode : studentCode // ignore: cast_nullable_to_non_nullable
as String?,faculty: freezed == faculty ? _self.faculty : faculty // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDTO].
extension UserDTOPatterns on UserDTO {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDTO() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDTO value)  $default,){
final _that = this;
switch (_that) {
case _UserDTO():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDTO value)?  $default,){
final _that = this;
switch (_that) {
case _UserDTO() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String email,  String accountStatus,  String primaryRole,  String? phoneNumber,  String? studentCode,  String? faculty,  String? className,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDTO() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.accountStatus,_that.primaryRole,_that.phoneNumber,_that.studentCode,_that.faculty,_that.className,_that.avatarUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String email,  String accountStatus,  String primaryRole,  String? phoneNumber,  String? studentCode,  String? faculty,  String? className,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _UserDTO():
return $default(_that.id,_that.fullName,_that.email,_that.accountStatus,_that.primaryRole,_that.phoneNumber,_that.studentCode,_that.faculty,_that.className,_that.avatarUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String email,  String accountStatus,  String primaryRole,  String? phoneNumber,  String? studentCode,  String? faculty,  String? className,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _UserDTO() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.accountStatus,_that.primaryRole,_that.phoneNumber,_that.studentCode,_that.faculty,_that.className,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDTO implements UserDTO {
  const _UserDTO({required this.id, required this.fullName, required this.email, required this.accountStatus, required this.primaryRole, this.phoneNumber, this.studentCode, this.faculty, this.className, this.avatarUrl});
  factory _UserDTO.fromJson(Map<String, dynamic> json) => _$UserDTOFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String email;
@override final  String accountStatus;
@override final  String primaryRole;
@override final  String? phoneNumber;
@override final  String? studentCode;
@override final  String? faculty;
@override final  String? className;
@override final  String? avatarUrl;

/// Create a copy of UserDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDTOCopyWith<_UserDTO> get copyWith => __$UserDTOCopyWithImpl<_UserDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.primaryRole, primaryRole) || other.primaryRole == primaryRole)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.studentCode, studentCode) || other.studentCode == studentCode)&&(identical(other.faculty, faculty) || other.faculty == faculty)&&(identical(other.className, className) || other.className == className)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,accountStatus,primaryRole,phoneNumber,studentCode,faculty,className,avatarUrl);

@override
String toString() {
  return 'UserDTO(id: $id, fullName: $fullName, email: $email, accountStatus: $accountStatus, primaryRole: $primaryRole, phoneNumber: $phoneNumber, studentCode: $studentCode, faculty: $faculty, className: $className, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$UserDTOCopyWith<$Res> implements $UserDTOCopyWith<$Res> {
  factory _$UserDTOCopyWith(_UserDTO value, $Res Function(_UserDTO) _then) = __$UserDTOCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String email, String accountStatus, String primaryRole, String? phoneNumber, String? studentCode, String? faculty, String? className, String? avatarUrl
});




}
/// @nodoc
class __$UserDTOCopyWithImpl<$Res>
    implements _$UserDTOCopyWith<$Res> {
  __$UserDTOCopyWithImpl(this._self, this._then);

  final _UserDTO _self;
  final $Res Function(_UserDTO) _then;

/// Create a copy of UserDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? accountStatus = null,Object? primaryRole = null,Object? phoneNumber = freezed,Object? studentCode = freezed,Object? faculty = freezed,Object? className = freezed,Object? avatarUrl = freezed,}) {
  return _then(_UserDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,accountStatus: null == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as String,primaryRole: null == primaryRole ? _self.primaryRole : primaryRole // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,studentCode: freezed == studentCode ? _self.studentCode : studentCode // ignore: cast_nullable_to_non_nullable
as String?,faculty: freezed == faculty ? _self.faculty : faculty // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AuthResponseDTO {

 String get accessToken; int get expiresIn; UserDTO get user;
/// Create a copy of AuthResponseDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseDTOCopyWith<AuthResponseDTO> get copyWith => _$AuthResponseDTOCopyWithImpl<AuthResponseDTO>(this as AuthResponseDTO, _$identity);

  /// Serializes this AuthResponseDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponseDTO&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,expiresIn,user);

@override
String toString() {
  return 'AuthResponseDTO(accessToken: $accessToken, expiresIn: $expiresIn, user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthResponseDTOCopyWith<$Res>  {
  factory $AuthResponseDTOCopyWith(AuthResponseDTO value, $Res Function(AuthResponseDTO) _then) = _$AuthResponseDTOCopyWithImpl;
@useResult
$Res call({
 String accessToken, int expiresIn, UserDTO user
});


$UserDTOCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthResponseDTOCopyWithImpl<$Res>
    implements $AuthResponseDTOCopyWith<$Res> {
  _$AuthResponseDTOCopyWithImpl(this._self, this._then);

  final AuthResponseDTO _self;
  final $Res Function(AuthResponseDTO) _then;

/// Create a copy of AuthResponseDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? expiresIn = null,Object? user = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDTO,
  ));
}
/// Create a copy of AuthResponseDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDTOCopyWith<$Res> get user {
  
  return $UserDTOCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthResponseDTO].
extension AuthResponseDTOPatterns on AuthResponseDTO {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponseDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponseDTO() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponseDTO value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponseDTO():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponseDTO value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponseDTO() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  int expiresIn,  UserDTO user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponseDTO() when $default != null:
return $default(_that.accessToken,_that.expiresIn,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  int expiresIn,  UserDTO user)  $default,) {final _that = this;
switch (_that) {
case _AuthResponseDTO():
return $default(_that.accessToken,_that.expiresIn,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  int expiresIn,  UserDTO user)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponseDTO() when $default != null:
return $default(_that.accessToken,_that.expiresIn,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResponseDTO implements AuthResponseDTO {
  const _AuthResponseDTO({required this.accessToken, required this.expiresIn, required this.user});
  factory _AuthResponseDTO.fromJson(Map<String, dynamic> json) => _$AuthResponseDTOFromJson(json);

@override final  String accessToken;
@override final  int expiresIn;
@override final  UserDTO user;

/// Create a copy of AuthResponseDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseDTOCopyWith<_AuthResponseDTO> get copyWith => __$AuthResponseDTOCopyWithImpl<_AuthResponseDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponseDTO&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,expiresIn,user);

@override
String toString() {
  return 'AuthResponseDTO(accessToken: $accessToken, expiresIn: $expiresIn, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthResponseDTOCopyWith<$Res> implements $AuthResponseDTOCopyWith<$Res> {
  factory _$AuthResponseDTOCopyWith(_AuthResponseDTO value, $Res Function(_AuthResponseDTO) _then) = __$AuthResponseDTOCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, int expiresIn, UserDTO user
});


@override $UserDTOCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthResponseDTOCopyWithImpl<$Res>
    implements _$AuthResponseDTOCopyWith<$Res> {
  __$AuthResponseDTOCopyWithImpl(this._self, this._then);

  final _AuthResponseDTO _self;
  final $Res Function(_AuthResponseDTO) _then;

/// Create a copy of AuthResponseDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? expiresIn = null,Object? user = null,}) {
  return _then(_AuthResponseDTO(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDTO,
  ));
}

/// Create a copy of AuthResponseDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDTOCopyWith<$Res> get user {
  
  return $UserDTOCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
