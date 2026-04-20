// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'notification_dto.dart';

class NotificationDtoMapper extends ClassMapperBase<NotificationDto> {
  NotificationDtoMapper._();

  static NotificationDtoMapper? _instance;
  static NotificationDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NotificationDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'NotificationDto';

  static String _$id(NotificationDto v) => v.id;
  static const Field<NotificationDto, String> _f$id = Field('id', _$id);
  static String? _$eventId(NotificationDto v) => v.eventId;
  static const Field<NotificationDto, String> _f$eventId = Field(
    'eventId',
    _$eventId,
    key: r'event_id',
    opt: true,
  );
  static String _$title(NotificationDto v) => v.title;
  static const Field<NotificationDto, String> _f$title = Field(
    'title',
    _$title,
  );
  static String _$message(NotificationDto v) => v.message;
  static const Field<NotificationDto, String> _f$message = Field(
    'message',
    _$message,
  );
  static String _$type(NotificationDto v) => v.type;
  static const Field<NotificationDto, String> _f$type = Field('type', _$type);
  static DateTime? _$readAt(NotificationDto v) => v.readAt;
  static const Field<NotificationDto, DateTime> _f$readAt = Field(
    'readAt',
    _$readAt,
    key: r'read_at',
    opt: true,
  );
  static DateTime? _$deliveredAt(NotificationDto v) => v.deliveredAt;
  static const Field<NotificationDto, DateTime> _f$deliveredAt = Field(
    'deliveredAt',
    _$deliveredAt,
    key: r'delivered_at',
    opt: true,
  );
  static String? _$actionLabel(NotificationDto v) => v.actionLabel;
  static const Field<NotificationDto, String> _f$actionLabel = Field(
    'actionLabel',
    _$actionLabel,
    key: r'action_label',
    opt: true,
  );
  static String? _$actionRoute(NotificationDto v) => v.actionRoute;
  static const Field<NotificationDto, String> _f$actionRoute = Field(
    'actionRoute',
    _$actionRoute,
    key: r'action_route',
    opt: true,
  );

  @override
  final MappableFields<NotificationDto> fields = const {
    #id: _f$id,
    #eventId: _f$eventId,
    #title: _f$title,
    #message: _f$message,
    #type: _f$type,
    #readAt: _f$readAt,
    #deliveredAt: _f$deliveredAt,
    #actionLabel: _f$actionLabel,
    #actionRoute: _f$actionRoute,
  };

  static NotificationDto _instantiate(DecodingData data) {
    return NotificationDto(
      id: data.dec(_f$id),
      eventId: data.dec(_f$eventId),
      title: data.dec(_f$title),
      message: data.dec(_f$message),
      type: data.dec(_f$type),
      readAt: data.dec(_f$readAt),
      deliveredAt: data.dec(_f$deliveredAt),
      actionLabel: data.dec(_f$actionLabel),
      actionRoute: data.dec(_f$actionRoute),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static NotificationDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NotificationDto>(map);
  }

  static NotificationDto fromJson(String json) {
    return ensureInitialized().decodeJson<NotificationDto>(json);
  }
}

mixin NotificationDtoMappable {
  String toJson() {
    return NotificationDtoMapper.ensureInitialized()
        .encodeJson<NotificationDto>(this as NotificationDto);
  }

  Map<String, dynamic> toMap() {
    return NotificationDtoMapper.ensureInitialized().encodeMap<NotificationDto>(
      this as NotificationDto,
    );
  }

  NotificationDtoCopyWith<NotificationDto, NotificationDto, NotificationDto>
  get copyWith =>
      _NotificationDtoCopyWithImpl<NotificationDto, NotificationDto>(
        this as NotificationDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return NotificationDtoMapper.ensureInitialized().stringifyValue(
      this as NotificationDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return NotificationDtoMapper.ensureInitialized().equalsValue(
      this as NotificationDto,
      other,
    );
  }

  @override
  int get hashCode {
    return NotificationDtoMapper.ensureInitialized().hashValue(
      this as NotificationDto,
    );
  }
}

extension NotificationDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NotificationDto, $Out> {
  NotificationDtoCopyWith<$R, NotificationDto, $Out> get $asNotificationDto =>
      $base.as((v, t, t2) => _NotificationDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NotificationDtoCopyWith<$R, $In extends NotificationDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? eventId,
    String? title,
    String? message,
    String? type,
    DateTime? readAt,
    DateTime? deliveredAt,
    String? actionLabel,
    String? actionRoute,
  });
  NotificationDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _NotificationDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NotificationDto, $Out>
    implements NotificationDtoCopyWith<$R, NotificationDto, $Out> {
  _NotificationDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NotificationDto> $mapper =
      NotificationDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    Object? eventId = $none,
    String? title,
    String? message,
    String? type,
    Object? readAt = $none,
    Object? deliveredAt = $none,
    Object? actionLabel = $none,
    Object? actionRoute = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (eventId != $none) #eventId: eventId,
      if (title != null) #title: title,
      if (message != null) #message: message,
      if (type != null) #type: type,
      if (readAt != $none) #readAt: readAt,
      if (deliveredAt != $none) #deliveredAt: deliveredAt,
      if (actionLabel != $none) #actionLabel: actionLabel,
      if (actionRoute != $none) #actionRoute: actionRoute,
    }),
  );
  @override
  NotificationDto $make(CopyWithData data) => NotificationDto(
    id: data.get(#id, or: $value.id),
    eventId: data.get(#eventId, or: $value.eventId),
    title: data.get(#title, or: $value.title),
    message: data.get(#message, or: $value.message),
    type: data.get(#type, or: $value.type),
    readAt: data.get(#readAt, or: $value.readAt),
    deliveredAt: data.get(#deliveredAt, or: $value.deliveredAt),
    actionLabel: data.get(#actionLabel, or: $value.actionLabel),
    actionRoute: data.get(#actionRoute, or: $value.actionRoute),
  );

  @override
  NotificationDtoCopyWith<$R2, NotificationDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NotificationDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

