// File: lib/features/user_events/views/event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';
import 'package:frontend/features/event_shared/widgets/event_action_bar.dart';
import 'package:frontend/features/event_shared/widgets/event_hero_header.dart';
import 'package:frontend/features/event_shared/widgets/event_info_row.dart';
import 'package:frontend/features/event_shared/widgets/event_organizer_card.dart';
import 'package:frontend/features/event_shared/widgets/event_qa_section.dart';
import 'package:frontend/features/user_events/controller/user_event_controller.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  final EventModel? initialEvent;
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final VoidCallback? onRegister;
  final VoidCallback? onManage;
  final VoidCallback? onMyTicket;
  final VoidCallback? onUnregister;
  final VoidCallback? onAskQuestion;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.initialEvent,
    this.onBack,
    this.onShare,
    this.onRegister,
    this.onManage,
    this.onMyTicket,
    this.onUnregister,
    this.onAskQuestion,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isFavourited = false;
  bool _isFollowingOrganizer = false;

  void _invalidateEventDetailData() {
    ref.invalidate(userEventDetailProvider(widget.eventId));
    ref.invalidate(userPublicEventQuestionsProvider(widget.eventId));
    ref.invalidate(userEventFeedbacksProvider(widget.eventId));
    ref.invalidate(userEventFeedbackSummaryProvider(widget.eventId));
  }

  Future<void> _refreshEventDetailData() {
    ref.invalidate(userPublicEventQuestionsProvider(widget.eventId));
    ref.invalidate(userEventFeedbacksProvider(widget.eventId));
    ref.invalidate(userEventFeedbackSummaryProvider(widget.eventId));
    return ref
        .refresh(userEventDetailProvider(widget.eventId).future)
        .then<void>((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(userEventDetailProvider(widget.eventId));
    final registrationState = ref.watch(
      userEventRegistrationControllerProvider,
    );
    final detailEvent = detailState.whenOrNull(data: (value) => value);
    final event = detailEvent ?? widget.initialEvent;

    if (event == null && detailState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null && detailState.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AppErrorState(
            title: 'Không tải được sự kiện',
            description: 'Sự kiện không tồn tại hoặc hiện không công khai.',
            onRetry: _invalidateEventDetailData,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshEventDetailData,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: EventHeroHeader(
                    imageUrl: event?.imageUrl ?? '',
                    onBack: widget.onBack,
                    onShare: widget.onShare,
                    onFavourite: () =>
                        setState(() => _isFavourited = !_isFavourited),
                    isFavourited: _isFavourited,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.pagePaddingH,
                        36,
                        AppConstants.pagePaddingH,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CategoryBadge(label: event?.category ?? 'Sự kiện'),
                          const SizedBox(height: 12),
                          Text(
                            event?.title ?? '',
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontSize: 26,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          EventInfoRow(
                            icon: Icons.calendar_today,
                            label: _formatDate(event?.startDate),
                            subtitle: _formatTimeRange(event),
                          ),
                          const SizedBox(height: 12),
                          EventInfoRow(
                            icon: Icons.location_on,
                            label: event?.location.isNotEmpty == true
                                ? event!.location
                                : 'Chưa có địa điểm',
                            subtitle: event?.deepLink,
                          ),
                          const SizedBox(height: 20),
                          EventOrganizerCard(
                            organizerAvatarUrls: _organizerAvatarUrls(event),
                            extraOrganizersCount: _extraOrganizerCount(event),
                            organizerName: _organizerDisplayName(event),
                            fallbackAvatarLabel: _organizerDisplayName(event),
                            isFollowing: _isFollowingOrganizer,
                            onFollow: event == null
                                ? null
                                : () => _toggleOrganizerFollow(event),
                          ),
                          if (event?.isRegisteredByCurrentUser == true) ...[
                            const SizedBox(height: 16),
                            _MyTicketCard(onTap: widget.onMyTicket),
                          ],
                          const SizedBox(height: 24),
                          _AboutSection(description: event?.description),
                          if (event?.registrationFields.isNotEmpty == true)
                            _RegistrationFieldsPreview(event: event!),
                          const SizedBox(height: 24),
                          _QuestionsSection(
                            eventId: widget.eventId,
                            onAskQuestion: widget.onAskQuestion,
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EventActionBar(
              mode: _actionBarMode(detailEvent),
              onRegister: widget.onRegister,
              onManage: widget.onManage,
              onUnregister: widget.onUnregister,
              isRegisterLoading: registrationState.isLoading,
              isUnregisterLoading: registrationState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  EventActionBarMode _actionBarMode(EventModel? event) {
    if (event?.canManageCurrentUser == true) {
      return EventActionBarMode.manage;
    }
    if (event?.isRegisteredByCurrentUser == true) {
      return EventActionBarMode.registered;
    }
    return EventActionBarMode.unregistered;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Chưa có thời gian';

    final formatted = DateFormat(
      "EEEE, dd 'tháng' MM 'năm' yyyy",
      'vi',
    ).format(value.toLocal());
    return _capitalizeFirstLetter(formatted);
  }

  String _formatTimeRange(EventModel? event) {
    if (event == null) return '';

    final formatter = DateFormat('HH:mm', 'vi');
    final start = formatter.format(event.startDate.toLocal());
    final endDate = event.endDate;
    if (endDate == null) return start;

    final localEndDate = endDate.toLocal();
    final end = formatter.format(localEndDate);
    final localStartDate = event.startDate.toLocal();
    final isSameDay =
        localStartDate.year == localEndDate.year &&
        localStartDate.month == localEndDate.month &&
        localStartDate.day == localEndDate.day;

    if (isSameDay) return '$start - $end';
    return '$start - ${_formatDate(localEndDate)} lúc $end';
  }

  String _capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value.characters.first.toUpperCase() +
        value.characters.skip(1).join();
  }

  String _organizerSummary(EventModel? event) {
    final organizers = event?.organizers ?? const [];
    if (organizers.isEmpty) return 'Ban tổ chức UEvents';
    return organizers.first.user.displayName;
  }

  String _organizerDisplayName(EventModel? event) {
    final createdByName = event?.createdBy?.displayName.trim();
    if (createdByName != null && createdByName.isNotEmpty) {
      return createdByName;
    }
    return _organizerSummary(event);
  }

  List<String> _organizerAvatarUrls(EventModel? event) {
    if (event == null) return const <String>[];

    final urls = <String>[];
    final seen = <String>{};

    void addUserAvatar(EventUserSummaryModel? user) {
      if (user == null) return;
      final url = user.avatarUrl.trim();
      if (url.isEmpty || !seen.add(url)) return;
      urls.add(url);
    }

    for (final organizer in event.organizers) {
      addUserAvatar(organizer.user);
      if (urls.length >= 3) return urls;
    }

    addUserAvatar(event.createdBy);
    return urls.take(3).toList(growable: false);
  }

  int _extraOrganizerCount(EventModel? event) {
    final peopleCount = _organizerPeopleCount(event);
    if (peopleCount <= 1) return 0;

    final visibleAvatarCount = _organizerAvatarUrls(event).length;
    final primaryVisibleCount = visibleAvatarCount == 0
        ? 1
        : visibleAvatarCount;
    final extraCount = peopleCount - primaryVisibleCount;
    return extraCount > 0 ? extraCount : 0;
  }

  int _organizerPeopleCount(EventModel? event) {
    if (event == null) return 0;
    if (event.organizers.isNotEmpty) return event.organizers.length;
    return event.createdBy == null ? 0 : 1;
  }

  void _toggleOrganizerFollow(EventModel event) {
    setState(() => _isFollowingOrganizer = !_isFollowingOrganizer);

    final organizerName =
        event.createdBy?.displayName ?? _organizerSummary(event);
    showAppSnackBar(
      context,
      _isFollowingOrganizer
          ? 'Đã theo dõi $organizerName.'
          : 'Đã bỏ theo dõi $organizerName.',
    );
  }
}

class _MyTicketCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _MyTicketCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppConstants.radiusCard,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vé của tôi', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Xem thông tin vé đã đăng ký',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionsSection extends ConsumerWidget {
  final String eventId;
  final VoidCallback? onAskQuestion;

  const _QuestionsSection({required this.eventId, this.onAskQuestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(userPublicEventQuestionsProvider(eventId));

    return questionsState.when(
      loading: () =>
          const AppLoadingState(height: 140, padding: EdgeInsets.zero),
      error: (_, _) => AppErrorState(
        title: 'Không tải được bình luận',
        description: 'Vui lòng thử lại sau.',
        padding: EdgeInsets.zero,
        onRetry: () =>
            ref.invalidate(userPublicEventQuestionsProvider(eventId)),
      ),
      data: (questions) {
        final visibleQuestions = _sortedQuestions(questions);

        return EventQaSection(
          questions: visibleQuestions.take(3).toList(),
          totalCount: visibleQuestions.length,
          onAskQuestion: onAskQuestion,
          onReplyQuestion: (question, content) =>
              _replyToQuestion(ref, question, content),
          onViewAll: () => _showAllQuestions(context, ref, visibleQuestions),
        );
      },
    );
  }

  Future<bool> _replyToQuestion(
    WidgetRef ref,
    EventQuestionModel question,
    String content,
  ) {
    return ref
        .read(userEventEngagementControllerProvider.notifier)
        .replyToQuestion(
          eventId: eventId,
          questionId: question.id,
          content: content,
        );
  }

  List<EventQuestionModel> _sortedQuestions(
    List<EventQuestionModel> questions,
  ) {
    final sorted = [...questions];
    sorted.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      final aDate = a.askedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.askedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  void _showAllQuestions(
    BuildContext context,
    WidgetRef ref,
    List<EventQuestionModel> questions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Hỏi đáp', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: EventQaSection(
                    questions: questions,
                    totalCount: questions.length,
                    onAskQuestion: onAskQuestion,
                    onReplyQuestion: (question, content) =>
                        _replyToQuestion(ref, question, content),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;

  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String? description;

  const _AboutSection({this.description});

  @override
  Widget build(BuildContext context) {
    final text = description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Về sự kiện', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Text(
          text?.isNotEmpty == true ? text! : 'Chưa có mô tả sự kiện.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _RegistrationFieldsPreview extends StatelessWidget {
  final EventModel event;

  const _RegistrationFieldsPreview({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Biểu mẫu đăng ký', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          ...event.registrationFields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      field.isRequired ? '${field.label} *' : field.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
