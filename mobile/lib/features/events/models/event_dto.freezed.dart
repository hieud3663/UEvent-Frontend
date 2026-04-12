// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryDTO {

 String get id; String get name; String get slug; String? get icon; String? get color;
/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryDTOCopyWith<CategoryDTO> get copyWith => _$CategoryDTOCopyWithImpl<CategoryDTO>(this as CategoryDTO, _$identity);

  /// Serializes this CategoryDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,icon,color);

@override
String toString() {
  return 'CategoryDTO(id: $id, name: $name, slug: $slug, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $CategoryDTOCopyWith<$Res>  {
  factory $CategoryDTOCopyWith(CategoryDTO value, $Res Function(CategoryDTO) _then) = _$CategoryDTOCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String? icon, String? color
});




}
/// @nodoc
class _$CategoryDTOCopyWithImpl<$Res>
    implements $CategoryDTOCopyWith<$Res> {
  _$CategoryDTOCopyWithImpl(this._self, this._then);

  final CategoryDTO _self;
  final $Res Function(CategoryDTO) _then;

/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryDTO].
extension CategoryDTOPatterns on CategoryDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryDTO value)  $default,){
final _that = this;
switch (_that) {
case _CategoryDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryDTO value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryDTO() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CategoryDTO():
return $default(_that.id,_that.name,_that.slug,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CategoryDTO() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryDTO implements CategoryDTO {
  const _CategoryDTO({required this.id, required this.name, required this.slug, this.icon, this.color});
  factory _CategoryDTO.fromJson(Map<String, dynamic> json) => _$CategoryDTOFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String? icon;
@override final  String? color;

/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryDTOCopyWith<_CategoryDTO> get copyWith => __$CategoryDTOCopyWithImpl<_CategoryDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,icon,color);

@override
String toString() {
  return 'CategoryDTO(id: $id, name: $name, slug: $slug, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CategoryDTOCopyWith<$Res> implements $CategoryDTOCopyWith<$Res> {
  factory _$CategoryDTOCopyWith(_CategoryDTO value, $Res Function(_CategoryDTO) _then) = __$CategoryDTOCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String? icon, String? color
});




}
/// @nodoc
class __$CategoryDTOCopyWithImpl<$Res>
    implements _$CategoryDTOCopyWith<$Res> {
  __$CategoryDTOCopyWithImpl(this._self, this._then);

  final _CategoryDTO _self;
  final $Res Function(_CategoryDTO) _then;

/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_CategoryDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LocationDTO {

 String get id; String get type;// 'room', 'building', 'campus', or 'string' for location_snapshot
 String get name; String? get address; int? get capacity;
/// Create a copy of LocationDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationDTOCopyWith<LocationDTO> get copyWith => _$LocationDTOCopyWithImpl<LocationDTO>(this as LocationDTO, _$identity);

  /// Serializes this LocationDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,address,capacity);

@override
String toString() {
  return 'LocationDTO(id: $id, type: $type, name: $name, address: $address, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class $LocationDTOCopyWith<$Res>  {
  factory $LocationDTOCopyWith(LocationDTO value, $Res Function(LocationDTO) _then) = _$LocationDTOCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, String? address, int? capacity
});




}
/// @nodoc
class _$LocationDTOCopyWithImpl<$Res>
    implements $LocationDTOCopyWith<$Res> {
  _$LocationDTOCopyWithImpl(this._self, this._then);

  final LocationDTO _self;
  final $Res Function(LocationDTO) _then;

/// Create a copy of LocationDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? address = freezed,Object? capacity = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationDTO].
extension LocationDTOPatterns on LocationDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationDTO value)  $default,){
final _that = this;
switch (_that) {
case _LocationDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationDTO value)?  $default,){
final _that = this;
switch (_that) {
case _LocationDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String? address,  int? capacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationDTO() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.address,_that.capacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String? address,  int? capacity)  $default,) {final _that = this;
switch (_that) {
case _LocationDTO():
return $default(_that.id,_that.type,_that.name,_that.address,_that.capacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  String? address,  int? capacity)?  $default,) {final _that = this;
switch (_that) {
case _LocationDTO() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.address,_that.capacity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationDTO implements LocationDTO {
  const _LocationDTO({required this.id, required this.type, required this.name, this.address, this.capacity});
  factory _LocationDTO.fromJson(Map<String, dynamic> json) => _$LocationDTOFromJson(json);

@override final  String id;
@override final  String type;
// 'room', 'building', 'campus', or 'string' for location_snapshot
@override final  String name;
@override final  String? address;
@override final  int? capacity;

/// Create a copy of LocationDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationDTOCopyWith<_LocationDTO> get copyWith => __$LocationDTOCopyWithImpl<_LocationDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,address,capacity);

@override
String toString() {
  return 'LocationDTO(id: $id, type: $type, name: $name, address: $address, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class _$LocationDTOCopyWith<$Res> implements $LocationDTOCopyWith<$Res> {
  factory _$LocationDTOCopyWith(_LocationDTO value, $Res Function(_LocationDTO) _then) = __$LocationDTOCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, String? address, int? capacity
});




}
/// @nodoc
class __$LocationDTOCopyWithImpl<$Res>
    implements _$LocationDTOCopyWith<$Res> {
  __$LocationDTOCopyWithImpl(this._self, this._then);

  final _LocationDTO _self;
  final $Res Function(_LocationDTO) _then;

/// Create a copy of LocationDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? address = freezed,Object? capacity = freezed,}) {
  return _then(_LocationDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$EventDTO {

 String get id; String get title; String get slug; String get description; String get status; CategoryDTO get category; DateTime get startAt; DateTime get endAt; LocationDTO? get location; String? get locationSnapshot; int? get maxCapacity; String? get coverImageUrl; DateTime? get registrationOpenAt; DateTime? get registrationCloseAt; DateTime? get cancellationDeadlineAt; String? get deepLink;
/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDTOCopyWith<EventDTO> get copyWith => _$EventDTOCopyWithImpl<EventDTO>(this as EventDTO, _$identity);

  /// Serializes this EventDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationSnapshot, locationSnapshot) || other.locationSnapshot == locationSnapshot)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.registrationOpenAt, registrationOpenAt) || other.registrationOpenAt == registrationOpenAt)&&(identical(other.registrationCloseAt, registrationCloseAt) || other.registrationCloseAt == registrationCloseAt)&&(identical(other.cancellationDeadlineAt, cancellationDeadlineAt) || other.cancellationDeadlineAt == cancellationDeadlineAt)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,description,status,category,startAt,endAt,location,locationSnapshot,maxCapacity,coverImageUrl,registrationOpenAt,registrationCloseAt,cancellationDeadlineAt,deepLink);

@override
String toString() {
  return 'EventDTO(id: $id, title: $title, slug: $slug, description: $description, status: $status, category: $category, startAt: $startAt, endAt: $endAt, location: $location, locationSnapshot: $locationSnapshot, maxCapacity: $maxCapacity, coverImageUrl: $coverImageUrl, registrationOpenAt: $registrationOpenAt, registrationCloseAt: $registrationCloseAt, cancellationDeadlineAt: $cancellationDeadlineAt, deepLink: $deepLink)';
}


}

/// @nodoc
abstract mixin class $EventDTOCopyWith<$Res>  {
  factory $EventDTOCopyWith(EventDTO value, $Res Function(EventDTO) _then) = _$EventDTOCopyWithImpl;
@useResult
$Res call({
 String id, String title, String slug, String description, String status, CategoryDTO category, DateTime startAt, DateTime endAt, LocationDTO? location, String? locationSnapshot, int? maxCapacity, String? coverImageUrl, DateTime? registrationOpenAt, DateTime? registrationCloseAt, DateTime? cancellationDeadlineAt, String? deepLink
});


$CategoryDTOCopyWith<$Res> get category;$LocationDTOCopyWith<$Res>? get location;

}
/// @nodoc
class _$EventDTOCopyWithImpl<$Res>
    implements $EventDTOCopyWith<$Res> {
  _$EventDTOCopyWithImpl(this._self, this._then);

  final EventDTO _self;
  final $Res Function(EventDTO) _then;

/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? description = null,Object? status = null,Object? category = null,Object? startAt = null,Object? endAt = null,Object? location = freezed,Object? locationSnapshot = freezed,Object? maxCapacity = freezed,Object? coverImageUrl = freezed,Object? registrationOpenAt = freezed,Object? registrationCloseAt = freezed,Object? cancellationDeadlineAt = freezed,Object? deepLink = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryDTO,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationDTO?,locationSnapshot: freezed == locationSnapshot ? _self.locationSnapshot : locationSnapshot // ignore: cast_nullable_to_non_nullable
as String?,maxCapacity: freezed == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,registrationOpenAt: freezed == registrationOpenAt ? _self.registrationOpenAt : registrationOpenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationCloseAt: freezed == registrationCloseAt ? _self.registrationCloseAt : registrationCloseAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationDeadlineAt: freezed == cancellationDeadlineAt ? _self.cancellationDeadlineAt : cancellationDeadlineAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryDTOCopyWith<$Res> get category {
  
  return $CategoryDTOCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationDTOCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationDTOCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventDTO].
extension EventDTOPatterns on EventDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDTO value)  $default,){
final _that = this;
switch (_that) {
case _EventDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDTO value)?  $default,){
final _that = this;
switch (_that) {
case _EventDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String description,  String status,  CategoryDTO category,  DateTime startAt,  DateTime endAt,  LocationDTO? location,  String? locationSnapshot,  int? maxCapacity,  String? coverImageUrl,  DateTime? registrationOpenAt,  DateTime? registrationCloseAt,  DateTime? cancellationDeadlineAt,  String? deepLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDTO() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.description,_that.status,_that.category,_that.startAt,_that.endAt,_that.location,_that.locationSnapshot,_that.maxCapacity,_that.coverImageUrl,_that.registrationOpenAt,_that.registrationCloseAt,_that.cancellationDeadlineAt,_that.deepLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String description,  String status,  CategoryDTO category,  DateTime startAt,  DateTime endAt,  LocationDTO? location,  String? locationSnapshot,  int? maxCapacity,  String? coverImageUrl,  DateTime? registrationOpenAt,  DateTime? registrationCloseAt,  DateTime? cancellationDeadlineAt,  String? deepLink)  $default,) {final _that = this;
switch (_that) {
case _EventDTO():
return $default(_that.id,_that.title,_that.slug,_that.description,_that.status,_that.category,_that.startAt,_that.endAt,_that.location,_that.locationSnapshot,_that.maxCapacity,_that.coverImageUrl,_that.registrationOpenAt,_that.registrationCloseAt,_that.cancellationDeadlineAt,_that.deepLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String slug,  String description,  String status,  CategoryDTO category,  DateTime startAt,  DateTime endAt,  LocationDTO? location,  String? locationSnapshot,  int? maxCapacity,  String? coverImageUrl,  DateTime? registrationOpenAt,  DateTime? registrationCloseAt,  DateTime? cancellationDeadlineAt,  String? deepLink)?  $default,) {final _that = this;
switch (_that) {
case _EventDTO() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.description,_that.status,_that.category,_that.startAt,_that.endAt,_that.location,_that.locationSnapshot,_that.maxCapacity,_that.coverImageUrl,_that.registrationOpenAt,_that.registrationCloseAt,_that.cancellationDeadlineAt,_that.deepLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventDTO implements EventDTO {
  const _EventDTO({required this.id, required this.title, required this.slug, required this.description, required this.status, required this.category, required this.startAt, required this.endAt, this.location, this.locationSnapshot, this.maxCapacity, this.coverImageUrl, this.registrationOpenAt, this.registrationCloseAt, this.cancellationDeadlineAt, this.deepLink});
  factory _EventDTO.fromJson(Map<String, dynamic> json) => _$EventDTOFromJson(json);

@override final  String id;
@override final  String title;
@override final  String slug;
@override final  String description;
@override final  String status;
@override final  CategoryDTO category;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  LocationDTO? location;
@override final  String? locationSnapshot;
@override final  int? maxCapacity;
@override final  String? coverImageUrl;
@override final  DateTime? registrationOpenAt;
@override final  DateTime? registrationCloseAt;
@override final  DateTime? cancellationDeadlineAt;
@override final  String? deepLink;

/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDTOCopyWith<_EventDTO> get copyWith => __$EventDTOCopyWithImpl<_EventDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationSnapshot, locationSnapshot) || other.locationSnapshot == locationSnapshot)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.registrationOpenAt, registrationOpenAt) || other.registrationOpenAt == registrationOpenAt)&&(identical(other.registrationCloseAt, registrationCloseAt) || other.registrationCloseAt == registrationCloseAt)&&(identical(other.cancellationDeadlineAt, cancellationDeadlineAt) || other.cancellationDeadlineAt == cancellationDeadlineAt)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,description,status,category,startAt,endAt,location,locationSnapshot,maxCapacity,coverImageUrl,registrationOpenAt,registrationCloseAt,cancellationDeadlineAt,deepLink);

@override
String toString() {
  return 'EventDTO(id: $id, title: $title, slug: $slug, description: $description, status: $status, category: $category, startAt: $startAt, endAt: $endAt, location: $location, locationSnapshot: $locationSnapshot, maxCapacity: $maxCapacity, coverImageUrl: $coverImageUrl, registrationOpenAt: $registrationOpenAt, registrationCloseAt: $registrationCloseAt, cancellationDeadlineAt: $cancellationDeadlineAt, deepLink: $deepLink)';
}


}

/// @nodoc
abstract mixin class _$EventDTOCopyWith<$Res> implements $EventDTOCopyWith<$Res> {
  factory _$EventDTOCopyWith(_EventDTO value, $Res Function(_EventDTO) _then) = __$EventDTOCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String slug, String description, String status, CategoryDTO category, DateTime startAt, DateTime endAt, LocationDTO? location, String? locationSnapshot, int? maxCapacity, String? coverImageUrl, DateTime? registrationOpenAt, DateTime? registrationCloseAt, DateTime? cancellationDeadlineAt, String? deepLink
});


@override $CategoryDTOCopyWith<$Res> get category;@override $LocationDTOCopyWith<$Res>? get location;

}
/// @nodoc
class __$EventDTOCopyWithImpl<$Res>
    implements _$EventDTOCopyWith<$Res> {
  __$EventDTOCopyWithImpl(this._self, this._then);

  final _EventDTO _self;
  final $Res Function(_EventDTO) _then;

/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? description = null,Object? status = null,Object? category = null,Object? startAt = null,Object? endAt = null,Object? location = freezed,Object? locationSnapshot = freezed,Object? maxCapacity = freezed,Object? coverImageUrl = freezed,Object? registrationOpenAt = freezed,Object? registrationCloseAt = freezed,Object? cancellationDeadlineAt = freezed,Object? deepLink = freezed,}) {
  return _then(_EventDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryDTO,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationDTO?,locationSnapshot: freezed == locationSnapshot ? _self.locationSnapshot : locationSnapshot // ignore: cast_nullable_to_non_nullable
as String?,maxCapacity: freezed == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,registrationOpenAt: freezed == registrationOpenAt ? _self.registrationOpenAt : registrationOpenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,registrationCloseAt: freezed == registrationCloseAt ? _self.registrationCloseAt : registrationCloseAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationDeadlineAt: freezed == cancellationDeadlineAt ? _self.cancellationDeadlineAt : cancellationDeadlineAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryDTOCopyWith<$Res> get category {
  
  return $CategoryDTOCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of EventDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationDTOCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationDTOCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
