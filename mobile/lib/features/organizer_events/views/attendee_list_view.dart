// File: lib/features/organizer_events/views/attendee_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_filter_chip.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_search_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/event_shared/widgets/attendee_card.dart';

class AttendeeListView extends ConsumerStatefulWidget {
  final String eventId;
  final VoidCallback? onBack;

  const AttendeeListView({super.key, required this.eventId, this.onBack});

  @override
  ConsumerState<AttendeeListView> createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends ConsumerState<AttendeeListView> {
  int _activeFilterIndex = 0;
  String _query = '';

  final List<String> _filters = const [
    'All',
    'Registered',
    'Waitlisted',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final registrationsState = ref.watch(
      organizerEventRegistrationsProvider(widget.eventId),
    );
    final mutationState = ref.watch(
      organizerEventRegistrationControllerProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                ),
                sliver: registrationsState.when(
                  loading: () => const SliverToBoxAdapter(
                    child: AppLoadingState(
                      height: 260,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  error: (_, _) => SliverToBoxAdapter(
                    child: AppErrorState(
                      title: 'Không tải được danh sách',
                      description:
                          'Vui lòng kiểm tra quyền organizer và thử lại.',
                      padding: EdgeInsets.zero,
                      onRetry: () => ref.invalidate(
                        organizerEventRegistrationsProvider(widget.eventId),
                      ),
                    ),
                  ),
                  data: (registrations) {
                    final visible = _filteredRegistrations(registrations);

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Danh sách người tham gia',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassSearchBar(
                          placeholder: 'Tìm người đăng ký theo email...',
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(_filters.length, (index) {
                              return GlassFilterChip(
                                label: _filterLabel(_filters[index]),
                                isActive: _activeFilterIndex == index,
                                onTap: () =>
                                    setState(() => _activeFilterIndex = index),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (visible.isEmpty)
                          const AppSuccessState(
                            isEmpty: true,
                            emptyIcon: Icons.people_outline,
                            emptyTitle: 'Chưa có attendee',
                            emptyDescription:
                                'Danh sách đăng ký sẽ xuất hiện tại đây.',
                            emptyPadding: EdgeInsets.zero,
                            child: SizedBox.shrink(),
                          )
                        else
                          ...visible.map(
                            (registration) => _buildAttendeeCard(
                              registration,
                              mutationState.isLoading,
                            ),
                          ),
                        const SizedBox(height: 100),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Quản lý sự kiện',
              leadingIcon: Icons.close,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: GlassIconButton(
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(
                  organizerEventRegistrationsProvider(widget.eventId),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeCard(
    EventRegistrationModel registration,
    bool isPromoting,
  ) {
    final user = registration.user;

    return AttendeeCard(
      imageUrl: user?.avatarUrl ?? '',
      name: user?.displayName ?? 'Unknown attendee',
      studentId: user?.email ?? user?.username ?? registration.id,
      status: _statusFromApi(registration.status),
      timestamp: registration.registeredAt == null
          ? null
          : DateFormat('HH:mm').format(registration.registeredAt!.toLocal()),
      trailing: registration.canPromoteToCohost
          ? SizedBox(
              width: 118,
              child: PrimaryButton(
                label: 'Co-host',
                isFullWidth: false,
                isLoading: isPromoting,
                onPressed: isPromoting
                    ? null
                    : () => _promoteRegistration(registration),
              ),
            )
          : null,
    );
  }

  Future<void> _promoteRegistration(EventRegistrationModel registration) async {
    final ok = await ref
        .read(organizerEventRegistrationControllerProvider.notifier)
        .promoteRegistrationToCohost(
          eventId: widget.eventId,
          registrationId: registration.id,
        );

    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, 'Đã cấp quyền co-host.');
    } else {
      showAppSnackBar(context, 'Không cấp được quyền co-host.');
    }
  }

  List<EventRegistrationModel> _filteredRegistrations(
    List<EventRegistrationModel> registrations,
  ) {
    final selected = _filters[_activeFilterIndex].toLowerCase();
    final query = _query.trim().toLowerCase();

    return registrations.where((registration) {
      final matchesStatus =
          selected == 'all' ||
          registration.status.toLowerCase() == selected ||
          (selected == 'registered' && registration.status == 'checked_in');
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;

      final user = registration.user;
      final haystack = [
        user?.displayName,
        user?.email,
        user?.username,
        registration.ticket?.ticketCode,
      ].whereType<String>().join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  String _filterLabel(String value) {
    return switch (value) {
      'All' => 'Tất cả',
      'Registered' => 'Đã đăng ký',
      'Waitlisted' => 'Danh sách chờ',
      'Cancelled' => 'Đã hủy',
      _ => value,
    };
  }

  AttendeeStatus _statusFromApi(String status) {
    return switch (status) {
      'checked_in' => AttendeeStatus.checkedIn,
      'registered' => AttendeeStatus.registered,
      'waitlisted' => AttendeeStatus.waitlisted,
      'cancelled' || 'rejected' => AttendeeStatus.cancelled,
      _ => AttendeeStatus.pending,
    };
  }
}
