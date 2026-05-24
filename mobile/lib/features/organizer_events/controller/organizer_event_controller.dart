import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_room_model.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';

final organizerEventMutationControllerProvider =
    AsyncNotifierProvider<OrganizerEventMutationController, void>(
      OrganizerEventMutationController.new,
    );

final organizerEventRegistrationControllerProvider =
    AsyncNotifierProvider<OrganizerEventRegistrationController, void>(
      OrganizerEventRegistrationController.new,
    );

class OrganizerEventMutationController extends AsyncNotifier<void> {
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
    required bool activateImmediately,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(organizerEventRepositoryProvider);
      final registrationOpenAt = DateTime.now();
      final registrationCloseAt = startAt.subtract(const Duration(hours: 1));
      final cancellationDeadlineAt = startAt.subtract(const Duration(hours: 3));

      final createdEvent = await repository.createOrganizerEvent({
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
        'status': activateImmediately ? 'active' : 'draft',
      });

      final contentType = _contentTypeForPath(coverImage.path);
      final fileName =
          '${createdEvent.id}.${_extensionForContentType(contentType)}';
      final uploadTarget = await repository.getEventCoverPresignedUrl(
        fileName: fileName,
        contentType: contentType,
      );

      if (uploadTarget.presignedUrl.isEmpty) {
        throw const EventMutationException(
          'Server không trả presigned URL để upload ảnh.',
        );
      }

      await repository.uploadEventCoverImage(
        imageFile: coverImage,
        presignedUrl: uploadTarget.presignedUrl,
        contentType: contentType,
      );

      if (uploadTarget.objectKey.isEmpty) {
        throw const EventMutationException(
          'Server không trả object key của ảnh bìa.',
        );
      }

      await repository.updateOrganizerEventCover(
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
      final repository = ref.read(organizerEventRepositoryProvider);
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

      await repository.updateOrganizerEvent(eventId: eventId, payload: payload);

      if (coverImage != null) {
        final contentType = _contentTypeForPath(coverImage.path);
        final fileName = '$eventId.${_extensionForContentType(contentType)}';
        final uploadTarget = await repository.getEventCoverPresignedUrl(
          fileName: fileName,
          contentType: contentType,
        );

        if (uploadTarget.presignedUrl.isEmpty) {
          throw const EventMutationException(
            'Server không trả presigned URL để upload ảnh.',
          );
        }

        await repository.uploadEventCoverImage(
          imageFile: coverImage,
          presignedUrl: uploadTarget.presignedUrl,
          contentType: contentType,
        );

        if (uploadTarget.objectKey.isEmpty) {
          throw const EventMutationException(
            'Server không trả object key của ảnh bìa.',
          );
        }

        await repository.updateOrganizerEventCover(
          eventId: eventId,
          coverImageKey: uploadTarget.objectKey,
        );
      }

      ref.invalidate(userEventDetailProvider(eventId));
      ref.invalidate(organizerEventDetailProvider(eventId));
      ref.invalidate(organizerEventsProvider);
      ref.invalidate(organizerEventsPagerProvider);
      ref.invalidate(userDiscoveryEventsProvider);
      ref.invalidate(userDiscoverySearchEventsProvider);
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

class OrganizerEventRegistrationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> promoteRegistrationToCohost({
    required String eventId,
    required String registrationId,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(organizerEventRepositoryProvider)
          .promoteRegistrationToCohost(
            eventId: eventId,
            registrationId: registrationId,
          );

      ref.invalidate(organizerEventDetailProvider(eventId));
      ref.invalidate(organizerEventRegistrationsProvider(eventId));
      ref.invalidate(organizerEventsProvider);
      ref.invalidate(organizerEventsPagerProvider);
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
