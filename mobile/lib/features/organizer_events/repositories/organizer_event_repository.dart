import 'dart:io';

import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/features/event_shared/mock/mock_event_data.dart';
import 'package:frontend/features/event_shared/models/event_cover_upload_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_organizer_member_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/event_shared/models/event_room_model.dart';
import 'package:frontend/features/organizer_events/models/check_in_model.dart';
import 'package:frontend/features/organizer_events/services/organizer_event_service.dart';

abstract interface class OrganizerEventRepository {
  Future<List<EventModel>> getOrganizerEvents({
    int page = 1,
    int pageSize = 10,
  });

  Future<List<EventRoomModel>> getEventRooms();
  Future<EventModel> createOrganizerEvent(Map<String, dynamic> payload);

  Future<EventModel> updateOrganizerEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  });

  Future<EventCoverUploadModel> getEventCoverPresignedUrl({
    required String fileName,
    required String contentType,
  });

  Future<void> uploadEventCoverImage({
    required File imageFile,
    required String presignedUrl,
    required String contentType,
  });

  Future<EventModel> updateOrganizerEventCover({
    required String eventId,
    required String coverImageKey,
  });

  Future<EventModel> getOrganizerEventDetail(String eventId);

  Future<List<EventRegistrationModel>> getEventRegistrations({
    required String eventId,
    String? status,
    String? search,
  });

  Future<EventOrganizerMemberModel> promoteRegistrationToCohost({
    required String eventId,
    required String registrationId,
  });

  Future<CheckInResultModel> checkInRegistration({
    required String eventId,
    String? qrPayload,
    String? qrSignature,
    String? email,
    String? note,
  });

  Future<List<CheckInLogModel>> getCheckInLogs({
    required String eventId,
    String? result,
    String? search,
    String? userId,
    String? ticketId,
  });

  Future<List<EventQuestionModel>> getOrganizerEventQuestions({
    required String eventId,
  });

  Future<EventQuestionModel> answerEventQuestion({
    required String questionId,
    required String answerText,
  });

  Future<EventQuestionReplyModel> createQuestionReply({
    required String questionId,
    required String content,
  });
}

class OrganizerEventRepositoryImpl implements OrganizerEventRepository {
  final OrganizerEventService _service;

  OrganizerEventRepositoryImpl(this._service);

  @override
  Future<List<EventModel>> getOrganizerEvents({
    int page = 1,
    int pageSize = 10,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockEventData.list
          .where((event) => event.isOrganizer)
          .take(pageSize)
          .toList();
    }

    return _service.getOrganizerEvents(page: page, pageSize: pageSize);
  }

  @override
  Future<List<EventRoomModel>> getEventRooms() async {
    if (EnvConfig.useMockData) {
      return const [
        EventRoomModel(
          id: 'mock-room-a1',
          name: 'Auditorium',
          code: 'A1',
          capacity: 120,
        ),
      ];
    }

    return _service.getEventRooms();
  }

  @override
  Future<EventModel> createOrganizerEvent(Map<String, dynamic> payload) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockEventData.mockEventLaunchParty.copyWith(
        title: payload['title']?.toString() ?? 'Draft event',
        isOrganizer: true,
      );
    }

    return _service.createOrganizerEvent(payload);
  }

  @override
  Future<EventModel> updateOrganizerEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return MockEventData.mockEventLaunchParty.copyWith(
        id: eventId,
        title:
            payload['title']?.toString() ??
            MockEventData.mockEventLaunchParty.title,
        description:
            payload['description']?.toString() ??
            MockEventData.mockEventLaunchParty.description,
        category:
            payload['category']?.toString() ??
            MockEventData.mockEventLaunchParty.category,
        location:
            payload['location_snapshot']?.toString() ??
            MockEventData.mockEventLaunchParty.location,
        guestCount:
            (payload['max_capacity'] as num?)?.toInt() ??
            MockEventData.mockEventLaunchParty.guestCount,
        startDate: payload['start_at'] is String
            ? DateTime.parse(payload['start_at'] as String)
            : MockEventData.mockEventLaunchParty.startDate,
        endDate: payload['end_at'] is String
            ? DateTime.parse(payload['end_at'] as String)
            : MockEventData.mockEventLaunchParty.endDate,
        visibility: payload['visibility'] == 'private'
            ? EventVisibility.private
            : EventVisibility.public,
        isOrganizer: true,
      );
    }

    return _service.updateOrganizerEvent(eventId: eventId, payload: payload);
  }

  @override
  Future<EventCoverUploadModel> getEventCoverPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return EventCoverUploadModel(
        objectKey: 'events/mock/covers/$fileName',
        presignedUrl: 'https://example.com/mock-presigned-url',
        method: 'PUT',
        expiresIn: 3600,
      );
    }

    return _service.getEventCoverPresignedUrl(
      fileName: fileName,
      contentType: contentType,
    );
  }

  @override
  Future<void> uploadEventCoverImage({
    required File imageFile,
    required String presignedUrl,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    return _service.uploadEventCoverImage(
      imageFile: imageFile,
      presignedUrl: presignedUrl,
      contentType: contentType,
    );
  }

  @override
  Future<EventModel> updateOrganizerEventCover({
    required String eventId,
    required String coverImageKey,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockEventData.mockEventLaunchParty.copyWith(
        id: eventId,
        imageUrl: 'https://example.com/$coverImageKey',
        isOrganizer: true,
      );
    }

    return _service.updateOrganizerEventCover(
      eventId: eventId,
      coverImageKey: coverImageKey,
    );
  }

  @override
  Future<EventModel> getOrganizerEventDetail(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockEventData.list
          .firstWhere((event) => event.id == eventId)
          .copyWith(isOrganizer: true);
    }

    return _service.getOrganizerEventDetail(eventId);
  }

  @override
  Future<List<EventRegistrationModel>> getEventRegistrations({
    required String eventId,
    String? status,
    String? search,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return [
        EventRegistrationModel(
          id: 'mock-registration-001',
          status: 'registered',
          registeredAt: DateTime.now().subtract(const Duration(hours: 2)),
          user: const EventUserSummaryModel(
            id: 'mock-user-001',
            username: 'attendee',
            fullName: 'Attendee Name',
            email: 'attendee@example.com',
          ),
          ticket: const EventTicketSummaryModel(
            id: 'mock-ticket-001',
            ticketCode: 'UE-98210',
            status: 'valid',
          ),
        ),
        EventRegistrationModel(
          id: 'mock-registration-002',
          status: 'waitlisted',
          registeredAt: DateTime.now().subtract(const Duration(hours: 1)),
          user: const EventUserSummaryModel(
            id: 'mock-user-002',
            username: 'waitlist',
            fullName: 'Waitlist User',
            email: 'waitlist@example.com',
          ),
        ),
      ];
    }

    return _service.getEventRegistrations(
      eventId: eventId,
      status: status,
      search: search,
    );
  }

  @override
  Future<EventOrganizerMemberModel> promoteRegistrationToCohost({
    required String eventId,
    required String registrationId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const EventOrganizerMemberModel(
        id: 'mock-cohost-001',
        eventId: 'mock-event',
        user: EventUserSummaryModel(
          id: 'mock-user-001',
          username: 'attendee',
          fullName: 'Attendee Name',
          email: 'attendee@example.com',
        ),
        organizerRole: 'co_host',
      );
    }

    return _service.promoteRegistrationToCohost(
      eventId: eventId,
      registrationId: registrationId,
    );
  }

  @override
  Future<CheckInResultModel> checkInRegistration({
    required String eventId,
    String? qrPayload,
    String? qrSignature,
    String? email,
    String? note,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return CheckInResultModel(
        result: 'success',
        registration: EventRegistrationModel(
          id: 'mock-registration-001',
          eventId: eventId,
          status: 'checked_in',
          user: const EventUserSummaryModel(
            id: 'mock-user-001',
            username: 'attendee',
            fullName: 'Attendee Name',
            email: 'attendee@example.com',
          ),
        ),
      );
    }

    return _service.checkInRegistration(
      eventId: eventId,
      qrPayload: qrPayload,
      qrSignature: qrSignature,
      email: email,
      note: note,
    );
  }

  @override
  Future<List<CheckInLogModel>> getCheckInLogs({
    required String eventId,
    String? result,
    String? search,
    String? userId,
    String? ticketId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const [];
    }

    return _service.getCheckInLogs(
      eventId: eventId,
      result: result,
      search: search,
      userId: userId,
      ticketId: ticketId,
    );
  }

  @override
  Future<List<EventQuestionModel>> getOrganizerEventQuestions({
    required String eventId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const [
        EventQuestionModel(
          id: 'mock-question-001',
          question: 'Sự kiện có cấp certificate không?',
          answer: 'Có, certificate sẽ được gửi sau sự kiện.',
          answeredBy: 'Organizer',
          timeAgo: '2h ago',
        ),
        EventQuestionModel(
          id: 'mock-question-002',
          question: 'Có cần mang laptop không?',
          timeAgo: '1h ago',
        ),
      ];
    }

    return _service.getOrganizerEventQuestions(eventId: eventId);
  }

  @override
  Future<EventQuestionModel> answerEventQuestion({
    required String questionId,
    required String answerText,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return EventQuestionModel(
        id: questionId,
        question: 'Câu hỏi mẫu',
        answer: answerText,
        answeredBy: 'Organizer',
        answeredAt: DateTime.now(),
        timeAgo: 'just now',
      );
    }

    return _service.answerEventQuestion(
      questionId: questionId,
      answerText: answerText,
    );
  }

  @override
  Future<EventQuestionReplyModel> createQuestionReply({
    required String questionId,
    required String content,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return EventQuestionReplyModel(
        id: 'mock-reply-${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        isOrganizerReply: true,
        createdAt: DateTime.now(),
        timeAgo: 'just now',
      );
    }

    return _service.createQuestionReply(
      questionId: questionId,
      content: content,
    );
  }
}
