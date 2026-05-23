import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_registration_model.dart';
import 'package:frontend/features/events/models/event_room_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';

final eventMutationControllerProvider =
    AsyncNotifierProvider<EventMutationController, void>(
      EventMutationController.new,
    );

final eventRegistrationControllerProvider =
    AsyncNotifierProvider<EventRegistrationController, void>(
      EventRegistrationController.new,
    );

final eventEngagementControllerProvider =
    AsyncNotifierProvider<EventEngagementController, void>(
      EventEngagementController.new,
    );

class EventMutationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createOrganizerEventWithCover({
    required String title,
    required String description,
    required EventCategoryModel category,
    required EventRoomModel room,
    required File coverImage,
    required int maxCapacity,
    required DateTime startAt,
    required DateTime endAt,
    required bool isPublic,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final service = ref.read(eventServiceProvider);
      final registrationOpenAt = DateTime.now();
      final registrationCloseAt = startAt.subtract(const Duration(hours: 1));
      final cancellationDeadlineAt = startAt.subtract(const Duration(hours: 3));

      final createdEvent = await service.createOrganizerEvent({
        'title': title,
        'category': category.id,
        'room': room.id,
        'description': description,
        'visibility': isPublic ? 'public' : 'private',
        'registration_open_at': _toApiDate(registrationOpenAt),
        'registration_close_at': _toApiDate(
          registrationCloseAt.isAfter(registrationOpenAt)
              ? registrationCloseAt
              : registrationOpenAt,
        ),
        'cancellation_deadline_at': _toApiDate(
          cancellationDeadlineAt.isAfter(registrationOpenAt)
              ? cancellationDeadlineAt
              : registrationOpenAt,
        ),
        'start_at': _toApiDate(startAt),
        'end_at': _toApiDate(endAt),
        'max_capacity': maxCapacity,
        'location_snapshot': room.displayName,
        'cover_image_key': '',
        'deep_link': '',
        'status': 'draft',
      });

      final contentType = _contentTypeForPath(coverImage.path);
      final fileName =
          '${createdEvent.id}.${_extensionForContentType(contentType)}';
      final uploadTarget = await service.getEventCoverPresignedUrl(
        fileName: fileName,
        contentType: contentType,
      );

      if (uploadTarget.presignedUrl.isEmpty) {
        throw const EventMutationException(
          'Server không trả presigned URL để upload ảnh.',
        );
      }

      await service.uploadEventCoverImage(
        imageFile: coverImage,
        presignedUrl: uploadTarget.presignedUrl,
        contentType: contentType,
      );

      if (uploadTarget.objectKey.isEmpty) {
        throw const EventMutationException(
          'Server không trả object key của ảnh bìa.',
        );
      }

      await service.updateOrganizerEventCover(
        eventId: createdEvent.id,
        coverImageKey: uploadTarget.objectKey,
      );

      ref.invalidate(organizerEventsProvider);
      ref.invalidate(organizerEventsPagerProvider);
    });

    state = result;
    return result.hasValue;
  }

  Future<bool> updateOrganizerEvent({
    required String eventId,
    required String title,
    required String description,
    required EventCategoryModel? category,
    required EventRoomModel? room,
    required File? coverImage,
    required int maxCapacity,
    required DateTime startAt,
    required DateTime endAt,
    required bool isPublic,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final service = ref.read(eventServiceProvider);
      final payload = <String, dynamic>{
        'title': title,
        'description': description,
        'visibility': isPublic ? 'public' : 'private',
        'start_at': _toApiDate(startAt),
        'end_at': _toApiDate(endAt),
        'max_capacity': maxCapacity,
      };

      if (category != null) {
        payload['category'] = category.id.isNotEmpty
            ? category.id
            : category.name;
      }

      if (room != null) {
        payload['room'] = room.id;
        payload['location_snapshot'] = room.displayName;
      }

      await service.updateOrganizerEvent(eventId: eventId, payload: payload);

      if (coverImage != null) {
        final contentType = _contentTypeForPath(coverImage.path);
        final fileName = '$eventId.${_extensionForContentType(contentType)}';
        final uploadTarget = await service.getEventCoverPresignedUrl(
          fileName: fileName,
          contentType: contentType,
        );

        if (uploadTarget.presignedUrl.isEmpty) {
          throw const EventMutationException(
            'Server không trả presigned URL để upload ảnh.',
          );
        }

        await service.uploadEventCoverImage(
          imageFile: coverImage,
          presignedUrl: uploadTarget.presignedUrl,
          contentType: contentType,
        );

        if (uploadTarget.objectKey.isEmpty) {
          throw const EventMutationException(
            'Server không trả object key của ảnh bìa.',
          );
        }

        await service.updateOrganizerEventCover(
          eventId: eventId,
          coverImageKey: uploadTarget.objectKey,
        );
      }

      ref.invalidate(eventDetailProvider(eventId));
      ref.invalidate(organizerEventDetailProvider(eventId));
      ref.invalidate(organizerEventsProvider);
      ref.invalidate(organizerEventsPagerProvider);
      ref.invalidate(discoveryEventsProvider);
      ref.invalidate(discoverySearchEventsProvider);
    });

    state = result;
    return result.hasValue;
  }

  String _toApiDate(DateTime date) => date.toUtc().toIso8601String();

  String _contentTypeForPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  String _extensionForContentType(String contentType) {
    return switch (contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' => 'heic',
      'image/heif' => 'heif',
      _ => 'jpg',
    };
  }
}

class EventMutationException implements Exception {
  final String message;

  const EventMutationException(this.message);

  @override
  String toString() => message;
}

class EventRegistrationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<EventRegistrationModel?> registerEvent({
    required String eventId,
    List<EventRegistrationAnswerModel> answers = const [],
  }) async {
    state = const AsyncLoading();

    EventRegistrationModel? registration;
    final result = await AsyncValue.guard(() async {
      registration = await ref
          .read(eventServiceProvider)
          .registerEvent(eventId: eventId, answers: answers);

      ref.invalidate(eventDetailProvider(eventId));
      ref.invalidate(myEventsProvider);
    });

    state = result;
    return result.hasValue ? registration : null;
  }

  Future<bool> promoteRegistrationToCohost({
    required String eventId,
    required String registrationId,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(eventServiceProvider)
          .promoteRegistrationToCohost(
            eventId: eventId,
            registrationId: registrationId,
          );

      ref.invalidate(organizerEventDetailProvider(eventId));
      ref.invalidate(eventRegistrationsProvider(eventId));
      ref.invalidate(organizerEventsProvider);
      ref.invalidate(organizerEventsPagerProvider);
    });

    state = result;
    return result.hasValue;
  }
}

class EventEngagementController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createQuestion({
    required String eventId,
    required String questionText,
    required bool isAnonymous,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(eventServiceProvider)
          .createEventQuestion(
            eventId: eventId,
            questionText: questionText,
            isAnonymous: isAnonymous,
          );

      ref.invalidate(publicEventQuestionsProvider(eventId));
      ref.invalidate(organizerEventQuestionsProvider(eventId));
    });

    state = result;
    return result.hasValue;
  }
}

String eventMutationErrorMessage(Object error) {
  if (error is EventMutationException) {
    return error.message;
  }

  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data?.toString();
    if (statusCode != null && error.requestOptions.uri.host.contains('s3')) {
      debugPrint('S3 upload failed [$statusCode]: $responseData');
      return 'Tạo event thành công nhưng upload ảnh lên S3 thất bại ($statusCode).';
    }

    debugPrint('Create event failed: ${error.message} $responseData');
  }

  return 'Không tạo được sự kiện. Vui lòng thử lại.';
}
