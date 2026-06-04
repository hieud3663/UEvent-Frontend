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
  static String? _$recipientId(NotificationDto v) => v.recipientId;
  static const Field<NotificationDto, String> _f$recipientId = Field(
    'recipientId',
    _$recipientId,
    key: r'recipient_id',
    opt: true,
  );
  static String? _$notificationId(NotificationDto v) => v.notificationId;
  static const Field<NotificationDto, String> _f$notificationId = Field(
    'notificationId',
    _$notificationId,
    key: r'notification_id',
    opt: true,
  );
  static String? _$eventId(NotificationDto v) => v.eventId;
  static const Field<NotificationDto, String> _f$eventId = Field(
    'eventId',
    _$eventId,
    key: r'event_id',
    opt: true,
  );
  static String? _$registrationId(NotificationDto v) => v.registrationId;
  static const Field<NotificationDto, String> _f$registrationId = Field(
    'registrationId',
    _$registrationId,
    key: r'registration_id',
    opt: true,
  );
  static String? _$ticketId(NotificationDto v) => v.ticketId;
  static const Field<NotificationDto, String> _f$ticketId = Field(
    'ticketId',
    _$ticketId,
    key: r'ticket_id',
    opt: true,
  );
  static String? _$questionId(NotificationDto v) => v.questionId;
  static const Field<NotificationDto, String> _f$questionId = Field(
    'questionId',
    _$questionId,
    key: r'question_id',
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
  static String? _$category(NotificationDto v) => v.category;
  static const Field<NotificationDto, String> _f$category = Field(
    'category',
    _$category,
    opt: true,
  );
  static String? _$target(NotificationDto v) => v.target;
  static const Field<NotificationDto, String> _f$target = Field(
    'target',
    _$target,
    opt: true,
  );
  static String? _$roleHint(NotificationDto v) => v.roleHint;
  static const Field<NotificationDto, String> _f$roleHint = Field(
    'roleHint',
    _$roleHint,
    key: r'role_hint',
    opt: true,
  );
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
  static DateTime? _$openedAt(NotificationDto v) => v.openedAt;
  static const Field<NotificationDto, DateTime> _f$openedAt = Field(
    'openedAt',
    _$openedAt,
    key: r'opened_at',
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
    #recipientId: _f$recipientId,
    #notificationId: _f$notificationId,
    #eventId: _f$eventId,
    #registrationId: _f$registrationId,
    #ticketId: _f$ticketId,
    #questionId: _f$questionId,
    #title: _f$title,
    #message: _f$message,
    #type: _f$type,
    #category: _f$category,
    #target: _f$target,
    #roleHint: _f$roleHint,
    #readAt: _f$readAt,
    #deliveredAt: _f$deliveredAt,
    #openedAt: _f$openedAt,
    #actionLabel: _f$actionLabel,
    #actionRoute: _f$actionRoute,
  };

  static NotificationDto _instantiate(DecodingData data) {
    return NotificationDto(
      id: data.dec(_f$id),
      recipientId: data.dec(_f$recipientId),
      notificationId: data.dec(_f$notificationId),
      eventId: data.dec(_f$eventId),
      registrationId: data.dec(_f$registrationId),
      ticketId: data.dec(_f$ticketId),
      questionId: data.dec(_f$questionId),
      title: data.dec(_f$title),
      message: data.dec(_f$message),
      type: data.dec(_f$type),
      category: data.dec(_f$category),
      target: data.dec(_f$target),
      roleHint: data.dec(_f$roleHint),
      readAt: data.dec(_f$readAt),
      deliveredAt: data.dec(_f$deliveredAt),
      openedAt: data.dec(_f$openedAt),
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
    String? recipientId,
    String? notificationId,
    String? eventId,
    String? registrationId,
    String? ticketId,
    String? questionId,
    String? title,
    String? message,
    String? type,
    String? category,
    String? target,
    String? roleHint,
    DateTime? readAt,
    DateTime? deliveredAt,
    DateTime? openedAt,
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
    Object? recipientId = $none,
    Object? notificationId = $none,
    Object? eventId = $none,
    Object? registrationId = $none,
    Object? ticketId = $none,
    Object? questionId = $none,
    String? title,
    String? message,
    String? type,
    Object? category = $none,
    Object? target = $none,
    Object? roleHint = $none,
    Object? readAt = $none,
    Object? deliveredAt = $none,
    Object? openedAt = $none,
    Object? actionLabel = $none,
    Object? actionRoute = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (recipientId != $none) #recipientId: recipientId,
      if (notificationId != $none) #notificationId: notificationId,
      if (eventId != $none) #eventId: eventId,
      if (registrationId != $none) #registrationId: registrationId,
      if (ticketId != $none) #ticketId: ticketId,
      if (questionId != $none) #questionId: questionId,
      if (title != null) #title: title,
      if (message != null) #message: message,
      if (type != null) #type: type,
      if (category != $none) #category: category,
      if (target != $none) #target: target,
      if (roleHint != $none) #roleHint: roleHint,
      if (readAt != $none) #readAt: readAt,
      if (deliveredAt != $none) #deliveredAt: deliveredAt,
      if (openedAt != $none) #openedAt: openedAt,
      if (actionLabel != $none) #actionLabel: actionLabel,
      if (actionRoute != $none) #actionRoute: actionRoute,
    }),
  );
  @override
  NotificationDto $make(CopyWithData data) => NotificationDto(
    id: data.get(#id, or: $value.id),
    recipientId: data.get(#recipientId, or: $value.recipientId),
    notificationId: data.get(#notificationId, or: $value.notificationId),
    eventId: data.get(#eventId, or: $value.eventId),
    registrationId: data.get(#registrationId, or: $value.registrationId),
    ticketId: data.get(#ticketId, or: $value.ticketId),
    questionId: data.get(#questionId, or: $value.questionId),
    title: data.get(#title, or: $value.title),
    message: data.get(#message, or: $value.message),
    type: data.get(#type, or: $value.type),
    category: data.get(#category, or: $value.category),
    target: data.get(#target, or: $value.target),
    roleHint: data.get(#roleHint, or: $value.roleHint),
    readAt: data.get(#readAt, or: $value.readAt),
    deliveredAt: data.get(#deliveredAt, or: $value.deliveredAt),
    openedAt: data.get(#openedAt, or: $value.openedAt),
    actionLabel: data.get(#actionLabel, or: $value.actionLabel),
    actionRoute: data.get(#actionRoute, or: $value.actionRoute),
  );

  @override
  NotificationDtoCopyWith<$R2, NotificationDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NotificationDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

