// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketDTO {

 String get ticketCode; String get qrPayload; DateTime get validFrom; DateTime get validTo; String get status;
/// Create a copy of TicketDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketDTOCopyWith<TicketDTO> get copyWith => _$TicketDTOCopyWithImpl<TicketDTO>(this as TicketDTO, _$identity);

  /// Serializes this TicketDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketDTO&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.qrPayload, qrPayload) || other.qrPayload == qrPayload)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validTo, validTo) || other.validTo == validTo)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketCode,qrPayload,validFrom,validTo,status);

@override
String toString() {
  return 'TicketDTO(ticketCode: $ticketCode, qrPayload: $qrPayload, validFrom: $validFrom, validTo: $validTo, status: $status)';
}


}

/// @nodoc
abstract mixin class $TicketDTOCopyWith<$Res>  {
  factory $TicketDTOCopyWith(TicketDTO value, $Res Function(TicketDTO) _then) = _$TicketDTOCopyWithImpl;
@useResult
$Res call({
 String ticketCode, String qrPayload, DateTime validFrom, DateTime validTo, String status
});




}
/// @nodoc
class _$TicketDTOCopyWithImpl<$Res>
    implements $TicketDTOCopyWith<$Res> {
  _$TicketDTOCopyWithImpl(this._self, this._then);

  final TicketDTO _self;
  final $Res Function(TicketDTO) _then;

/// Create a copy of TicketDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticketCode = null,Object? qrPayload = null,Object? validFrom = null,Object? validTo = null,Object? status = null,}) {
  return _then(_self.copyWith(
ticketCode: null == ticketCode ? _self.ticketCode : ticketCode // ignore: cast_nullable_to_non_nullable
as String,qrPayload: null == qrPayload ? _self.qrPayload : qrPayload // ignore: cast_nullable_to_non_nullable
as String,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validTo: null == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketDTO].
extension TicketDTOPatterns on TicketDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketDTO value)  $default,){
final _that = this;
switch (_that) {
case _TicketDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketDTO value)?  $default,){
final _that = this;
switch (_that) {
case _TicketDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ticketCode,  String qrPayload,  DateTime validFrom,  DateTime validTo,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketDTO() when $default != null:
return $default(_that.ticketCode,_that.qrPayload,_that.validFrom,_that.validTo,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ticketCode,  String qrPayload,  DateTime validFrom,  DateTime validTo,  String status)  $default,) {final _that = this;
switch (_that) {
case _TicketDTO():
return $default(_that.ticketCode,_that.qrPayload,_that.validFrom,_that.validTo,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ticketCode,  String qrPayload,  DateTime validFrom,  DateTime validTo,  String status)?  $default,) {final _that = this;
switch (_that) {
case _TicketDTO() when $default != null:
return $default(_that.ticketCode,_that.qrPayload,_that.validFrom,_that.validTo,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketDTO implements TicketDTO {
  const _TicketDTO({required this.ticketCode, required this.qrPayload, required this.validFrom, required this.validTo, required this.status});
  factory _TicketDTO.fromJson(Map<String, dynamic> json) => _$TicketDTOFromJson(json);

@override final  String ticketCode;
@override final  String qrPayload;
@override final  DateTime validFrom;
@override final  DateTime validTo;
@override final  String status;

/// Create a copy of TicketDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketDTOCopyWith<_TicketDTO> get copyWith => __$TicketDTOCopyWithImpl<_TicketDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketDTO&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.qrPayload, qrPayload) || other.qrPayload == qrPayload)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validTo, validTo) || other.validTo == validTo)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketCode,qrPayload,validFrom,validTo,status);

@override
String toString() {
  return 'TicketDTO(ticketCode: $ticketCode, qrPayload: $qrPayload, validFrom: $validFrom, validTo: $validTo, status: $status)';
}


}

/// @nodoc
abstract mixin class _$TicketDTOCopyWith<$Res> implements $TicketDTOCopyWith<$Res> {
  factory _$TicketDTOCopyWith(_TicketDTO value, $Res Function(_TicketDTO) _then) = __$TicketDTOCopyWithImpl;
@override @useResult
$Res call({
 String ticketCode, String qrPayload, DateTime validFrom, DateTime validTo, String status
});




}
/// @nodoc
class __$TicketDTOCopyWithImpl<$Res>
    implements _$TicketDTOCopyWith<$Res> {
  __$TicketDTOCopyWithImpl(this._self, this._then);

  final _TicketDTO _self;
  final $Res Function(_TicketDTO) _then;

/// Create a copy of TicketDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticketCode = null,Object? qrPayload = null,Object? validFrom = null,Object? validTo = null,Object? status = null,}) {
  return _then(_TicketDTO(
ticketCode: null == ticketCode ? _self.ticketCode : ticketCode // ignore: cast_nullable_to_non_nullable
as String,qrPayload: null == qrPayload ? _self.qrPayload : qrPayload // ignore: cast_nullable_to_non_nullable
as String,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validTo: null == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserRegistrationDTO {

 String get id; String get eventId; String get status; bool get answersLocked; DateTime get registeredAt;
/// Create a copy of UserRegistrationDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRegistrationDTOCopyWith<UserRegistrationDTO> get copyWith => _$UserRegistrationDTOCopyWithImpl<UserRegistrationDTO>(this as UserRegistrationDTO, _$identity);

  /// Serializes this UserRegistrationDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRegistrationDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.status, status) || other.status == status)&&(identical(other.answersLocked, answersLocked) || other.answersLocked == answersLocked)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,status,answersLocked,registeredAt);

@override
String toString() {
  return 'UserRegistrationDTO(id: $id, eventId: $eventId, status: $status, answersLocked: $answersLocked, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class $UserRegistrationDTOCopyWith<$Res>  {
  factory $UserRegistrationDTOCopyWith(UserRegistrationDTO value, $Res Function(UserRegistrationDTO) _then) = _$UserRegistrationDTOCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String status, bool answersLocked, DateTime registeredAt
});




}
/// @nodoc
class _$UserRegistrationDTOCopyWithImpl<$Res>
    implements $UserRegistrationDTOCopyWith<$Res> {
  _$UserRegistrationDTOCopyWithImpl(this._self, this._then);

  final UserRegistrationDTO _self;
  final $Res Function(UserRegistrationDTO) _then;

/// Create a copy of UserRegistrationDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? status = null,Object? answersLocked = null,Object? registeredAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,answersLocked: null == answersLocked ? _self.answersLocked : answersLocked // ignore: cast_nullable_to_non_nullable
as bool,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRegistrationDTO].
extension UserRegistrationDTOPatterns on UserRegistrationDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRegistrationDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRegistrationDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRegistrationDTO value)  $default,){
final _that = this;
switch (_that) {
case _UserRegistrationDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRegistrationDTO value)?  $default,){
final _that = this;
switch (_that) {
case _UserRegistrationDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String status,  bool answersLocked,  DateTime registeredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRegistrationDTO() when $default != null:
return $default(_that.id,_that.eventId,_that.status,_that.answersLocked,_that.registeredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String status,  bool answersLocked,  DateTime registeredAt)  $default,) {final _that = this;
switch (_that) {
case _UserRegistrationDTO():
return $default(_that.id,_that.eventId,_that.status,_that.answersLocked,_that.registeredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String status,  bool answersLocked,  DateTime registeredAt)?  $default,) {final _that = this;
switch (_that) {
case _UserRegistrationDTO() when $default != null:
return $default(_that.id,_that.eventId,_that.status,_that.answersLocked,_that.registeredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRegistrationDTO implements UserRegistrationDTO {
  const _UserRegistrationDTO({required this.id, required this.eventId, required this.status, required this.answersLocked, required this.registeredAt});
  factory _UserRegistrationDTO.fromJson(Map<String, dynamic> json) => _$UserRegistrationDTOFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String status;
@override final  bool answersLocked;
@override final  DateTime registeredAt;

/// Create a copy of UserRegistrationDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRegistrationDTOCopyWith<_UserRegistrationDTO> get copyWith => __$UserRegistrationDTOCopyWithImpl<_UserRegistrationDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRegistrationDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRegistrationDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.status, status) || other.status == status)&&(identical(other.answersLocked, answersLocked) || other.answersLocked == answersLocked)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,status,answersLocked,registeredAt);

@override
String toString() {
  return 'UserRegistrationDTO(id: $id, eventId: $eventId, status: $status, answersLocked: $answersLocked, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class _$UserRegistrationDTOCopyWith<$Res> implements $UserRegistrationDTOCopyWith<$Res> {
  factory _$UserRegistrationDTOCopyWith(_UserRegistrationDTO value, $Res Function(_UserRegistrationDTO) _then) = __$UserRegistrationDTOCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String status, bool answersLocked, DateTime registeredAt
});




}
/// @nodoc
class __$UserRegistrationDTOCopyWithImpl<$Res>
    implements _$UserRegistrationDTOCopyWith<$Res> {
  __$UserRegistrationDTOCopyWithImpl(this._self, this._then);

  final _UserRegistrationDTO _self;
  final $Res Function(_UserRegistrationDTO) _then;

/// Create a copy of UserRegistrationDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? status = null,Object? answersLocked = null,Object? registeredAt = null,}) {
  return _then(_UserRegistrationDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,answersLocked: null == answersLocked ? _self.answersLocked : answersLocked // ignore: cast_nullable_to_non_nullable
as bool,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$RegistrationFormFieldDTO {

 String get fieldKey; String get label; String get fieldType; bool get isRequired; List<String>? get optionsJson;
/// Create a copy of RegistrationFormFieldDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationFormFieldDTOCopyWith<RegistrationFormFieldDTO> get copyWith => _$RegistrationFormFieldDTOCopyWithImpl<RegistrationFormFieldDTO>(this as RegistrationFormFieldDTO, _$identity);

  /// Serializes this RegistrationFormFieldDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationFormFieldDTO&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.label, label) || other.label == label)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other.optionsJson, optionsJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fieldKey,label,fieldType,isRequired,const DeepCollectionEquality().hash(optionsJson));

@override
String toString() {
  return 'RegistrationFormFieldDTO(fieldKey: $fieldKey, label: $label, fieldType: $fieldType, isRequired: $isRequired, optionsJson: $optionsJson)';
}


}

/// @nodoc
abstract mixin class $RegistrationFormFieldDTOCopyWith<$Res>  {
  factory $RegistrationFormFieldDTOCopyWith(RegistrationFormFieldDTO value, $Res Function(RegistrationFormFieldDTO) _then) = _$RegistrationFormFieldDTOCopyWithImpl;
@useResult
$Res call({
 String fieldKey, String label, String fieldType, bool isRequired, List<String>? optionsJson
});




}
/// @nodoc
class _$RegistrationFormFieldDTOCopyWithImpl<$Res>
    implements $RegistrationFormFieldDTOCopyWith<$Res> {
  _$RegistrationFormFieldDTOCopyWithImpl(this._self, this._then);

  final RegistrationFormFieldDTO _self;
  final $Res Function(RegistrationFormFieldDTO) _then;

/// Create a copy of RegistrationFormFieldDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fieldKey = null,Object? label = null,Object? fieldType = null,Object? isRequired = null,Object? optionsJson = freezed,}) {
  return _then(_self.copyWith(
fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,fieldType: null == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as String,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,optionsJson: freezed == optionsJson ? _self.optionsJson : optionsJson // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistrationFormFieldDTO].
extension RegistrationFormFieldDTOPatterns on RegistrationFormFieldDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationFormFieldDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationFormFieldDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationFormFieldDTO value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationFormFieldDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationFormFieldDTO value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationFormFieldDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fieldKey,  String label,  String fieldType,  bool isRequired,  List<String>? optionsJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationFormFieldDTO() when $default != null:
return $default(_that.fieldKey,_that.label,_that.fieldType,_that.isRequired,_that.optionsJson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fieldKey,  String label,  String fieldType,  bool isRequired,  List<String>? optionsJson)  $default,) {final _that = this;
switch (_that) {
case _RegistrationFormFieldDTO():
return $default(_that.fieldKey,_that.label,_that.fieldType,_that.isRequired,_that.optionsJson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fieldKey,  String label,  String fieldType,  bool isRequired,  List<String>? optionsJson)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationFormFieldDTO() when $default != null:
return $default(_that.fieldKey,_that.label,_that.fieldType,_that.isRequired,_that.optionsJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistrationFormFieldDTO implements RegistrationFormFieldDTO {
  const _RegistrationFormFieldDTO({required this.fieldKey, required this.label, required this.fieldType, required this.isRequired, final  List<String>? optionsJson}): _optionsJson = optionsJson;
  factory _RegistrationFormFieldDTO.fromJson(Map<String, dynamic> json) => _$RegistrationFormFieldDTOFromJson(json);

@override final  String fieldKey;
@override final  String label;
@override final  String fieldType;
@override final  bool isRequired;
 final  List<String>? _optionsJson;
@override List<String>? get optionsJson {
  final value = _optionsJson;
  if (value == null) return null;
  if (_optionsJson is EqualUnmodifiableListView) return _optionsJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RegistrationFormFieldDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationFormFieldDTOCopyWith<_RegistrationFormFieldDTO> get copyWith => __$RegistrationFormFieldDTOCopyWithImpl<_RegistrationFormFieldDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrationFormFieldDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationFormFieldDTO&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.label, label) || other.label == label)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other._optionsJson, _optionsJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fieldKey,label,fieldType,isRequired,const DeepCollectionEquality().hash(_optionsJson));

@override
String toString() {
  return 'RegistrationFormFieldDTO(fieldKey: $fieldKey, label: $label, fieldType: $fieldType, isRequired: $isRequired, optionsJson: $optionsJson)';
}


}

/// @nodoc
abstract mixin class _$RegistrationFormFieldDTOCopyWith<$Res> implements $RegistrationFormFieldDTOCopyWith<$Res> {
  factory _$RegistrationFormFieldDTOCopyWith(_RegistrationFormFieldDTO value, $Res Function(_RegistrationFormFieldDTO) _then) = __$RegistrationFormFieldDTOCopyWithImpl;
@override @useResult
$Res call({
 String fieldKey, String label, String fieldType, bool isRequired, List<String>? optionsJson
});




}
/// @nodoc
class __$RegistrationFormFieldDTOCopyWithImpl<$Res>
    implements _$RegistrationFormFieldDTOCopyWith<$Res> {
  __$RegistrationFormFieldDTOCopyWithImpl(this._self, this._then);

  final _RegistrationFormFieldDTO _self;
  final $Res Function(_RegistrationFormFieldDTO) _then;

/// Create a copy of RegistrationFormFieldDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fieldKey = null,Object? label = null,Object? fieldType = null,Object? isRequired = null,Object? optionsJson = freezed,}) {
  return _then(_RegistrationFormFieldDTO(
fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,fieldType: null == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as String,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,optionsJson: freezed == optionsJson ? _self._optionsJson : optionsJson // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
