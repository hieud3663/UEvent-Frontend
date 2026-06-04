// File: lib/features/organizer_events/views/attendee_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
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
  String? _selectedRegistrationId;
  String? _pendingRegistrationId;

  @override
  Widget build(BuildContext context) {
    final registrationsState = ref.watch(
      organizerEventRegistrationsProvider(widget.eventId),
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
                    final visible = _visibleRegistrations(registrations);

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Người đăng ký',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (visible.isEmpty)
                          const AppSuccessState(
                            isEmpty: true,
                            emptyIcon: Icons.people_outline,
                            emptyTitle: 'Chưa có người đăng ký',
                            emptyDescription:
                                'Người đăng ký hợp lệ sẽ xuất hiện tại đây.',
                            emptyPadding: EdgeInsets.zero,
                            child: SizedBox.shrink(),
                          )
                        else
                          ...visible.map(
                            (registration) => _buildAttendeeCard(registration),
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

  Widget _buildAttendeeCard(EventRegistrationModel registration) {
    final user = registration.user;
    final isSelected = registration.id == _selectedRegistrationId;

    return AttendeeCard(
      imageUrl: user?.avatarUrl ?? '',
      name: user?.displayName ?? 'Unknown attendee',
      studentId: user?.email ?? user?.username ?? registration.id,
      status: _statusFromApi(registration.status),
      timestamp: registration.registeredAt == null
          ? null
          : DateFormat('HH:mm').format(registration.registeredAt!.toLocal()),
      onTap: () => setState(() {
        _selectedRegistrationId = isSelected ? null : registration.id;
      }),
      trailing: isSelected ? _buildRegistrationActions(registration) : null,
    );
  }

  Widget _buildRegistrationActions(EventRegistrationModel registration) {
    final isBusy = _pendingRegistrationId == registration.id;
    final isCheckedIn = registration.status == 'checked_in';
    final attendeeEmail = registration.user?.email ?? '';

    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: isCheckedIn ? 'Đã check-in' : 'Check-in',
            isFullWidth: true,
            isLoading: isBusy,
            onPressed: isBusy || isCheckedIn || attendeeEmail.isEmpty
                ? null
                : () => _checkInRegistration(registration),
          ),
        ],
      ),
    );
  }

  Future<void> _checkInRegistration(EventRegistrationModel registration) async {
    setState(() {
      _pendingRegistrationId = registration.id;
    });

    final result = await ref
        .read(organizerEventRegistrationControllerProvider.notifier)
        .checkInRegistration(
          eventId: widget.eventId,
          email: registration.user?.email,
          note: 'Attendee list',
        );

    if (!mounted) return;
    setState(() {
      _pendingRegistrationId = null;
    });

    showAppSnackBar(
      context,
      _checkInMessage(result?.result ?? 'invalid_ticket'),
    );
  }

  List<EventRegistrationModel> _visibleRegistrations(
    List<EventRegistrationModel> registrations,
  ) {
    return registrations.where((registration) {
      return registration.status == 'registered' ||
          registration.status == 'checked_in';
    }).toList();
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

  String _checkInMessage(String result) {
    return switch (result) {
      'success' => 'Đã check-in người đăng ký.',
      'already_checked_in' => 'Vé đã được check-in trước đó.',
      'event_unavailable' => 'Sự kiện chưa mở check-in hoặc đã kết thúc.',
      'invalid_format' => 'Thông tin check-in không hợp lệ.',
      _ => 'Không thể check-in người đăng ký.',
    };
  }
}
