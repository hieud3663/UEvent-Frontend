// File: lib/features/events/views/edit_event_details_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/segmented_toggle.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:frontend/features/events/controller/event_mutation_controller.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/event_room_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';
import 'package:frontend/features/events/widgets/edit_hero_image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditEventDetailsView extends ConsumerStatefulWidget {
  final String eventId;
  final EventModel? initialEvent;
  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const EditEventDetailsView({
    super.key,
    required this.eventId,
    this.initialEvent,
    this.onBack,
    this.onSave,
    this.onDelete,
  });

  @override
  ConsumerState<EditEventDetailsView> createState() =>
      _EditEventDetailsViewState();
}

class _EditEventDetailsViewState extends ConsumerState<EditEventDetailsView> {
  final _nameCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isPublic = true;
  bool _hydrated = false;
  File? _coverImageFile;
  EventRoomModel? _selectedRoom;
  EventCategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final initialEvent = widget.initialEvent;
    if (initialEvent != null) {
      _hydrate(initialEvent);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endDateCtrl.dispose();
    _endTimeCtrl.dispose();
    _capacityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(organizerEventDetailProvider(widget.eventId));
    final event =
        detailState.whenOrNull(data: (value) => value) ?? widget.initialEvent;
    final isSubmitting = ref.watch(eventMutationControllerProvider).isLoading;

    if (!_hydrated && event != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hydrated) _hydrate(event);
      });
    }

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Không tải được sự kiện',
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vui lòng thử lại sau.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Retry',
                    icon: Icons.refresh,
                    onPressed: () => ref.invalidate(
                      organizerEventDetailProvider(widget.eventId),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    EditHeroImagePicker(
                      imageUrl: event?.imageUrl ?? '',
                      imageFile: _coverImageFile,
                      onTap: isSubmitting ? () {} : _pickCoverImage,
                    ),
                    const SizedBox(height: 24),
                    _buildForm(),
                    const SizedBox(height: 28),
                    TextActionButton(
                      label: 'Cancel and Delete Event',
                      foregroundColor: AppColors.error,
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      onPressed: isSubmitting ? null : widget.onDelete,
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Edit Event',
              leadingIcon: Icons.arrow_back,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: GlassIconButton(
                icon: Icons.save,
                iconSize: 20,
                iconColor: AppColors.primary,
                onPressed: isSubmitting ? null : _submit,
              ),
            ),
          ),
          _buildBottomCta(isSubmitting),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final roomsAsync = ref.watch(eventRoomsProvider);
    final categoriesAsync = ref.watch(eventCategoriesProvider);

    return Column(
      children: [
        GlassInputField(label: 'Event Name', controller: _nameCtrl),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassInputField(
                label: 'Start Date',
                leadingIcon: Icons.calendar_today,
                controller: _startDateCtrl,
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassInputField(
                label: 'Start Time',
                leadingIcon: Icons.schedule,
                controller: _startTimeCtrl,
                keyboardType: TextInputType.datetime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassInputField(
                label: 'End Date',
                leadingIcon: Icons.event_available,
                controller: _endDateCtrl,
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassInputField(
                label: 'End Time',
                leadingIcon: Icons.schedule,
                controller: _endTimeCtrl,
                keyboardType: TextInputType.datetime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRoomDropdown(roomsAsync),
        const SizedBox(height: 16),
        _buildCategoryDropdown(categoriesAsync),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Max Capacity',
          leadingIcon: Icons.group,
          controller: _capacityCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildVisibilityToggle(),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Description',
          maxLines: 8,
          controller: _descCtrl,
        ),
      ],
    );
  }

  Widget _buildRoomDropdown(AsyncValue<List<EventRoomModel>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) {
        final selectedRoom = _selectedRoom ?? _matchingInitialRoom(rooms);

        return GlassDropdownField<EventRoomModel>(
          label: 'Location',
          placeholder: rooms.isEmpty ? 'No rooms available' : 'Select room',
          value: selectedRoom,
          items: rooms
              .map(
                (room) => GlassDropdownItem(
                  value: room,
                  label: '${room.displayName} - ${room.capacity} seats',
                  icon: Icons.location_on,
                ),
              )
              .toList(),
          onChanged: rooms.isEmpty
              ? null
              : (room) => setState(() => _selectedRoom = room),
        );
      },
      loading: () => const GlassInputField(
        label: 'Location',
        child: _FieldStatusText(text: 'Loading rooms...'),
      ),
      error: (_, _) => GlassInputField(
        label: 'Location',
        child: _RetryFieldText(
          text: 'Could not load rooms',
          onRetry: () => ref.invalidate(eventRoomsProvider),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    AsyncValue<List<EventCategoryModel>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        final selectedCategory =
            _selectedCategory ?? _matchingInitialCategory(categories);

        return GlassDropdownField<EventCategoryModel>(
          label: 'Category',
          placeholder: categories.isEmpty
              ? 'No categories available'
              : 'Select category',
          value: selectedCategory,
          items: categories
              .map(
                (category) => GlassDropdownItem(
                  value: category,
                  label: category.name,
                  icon: Icons.category_outlined,
                ),
              )
              .toList(),
          onChanged: categories.isEmpty
              ? null
              : (category) => setState(() => _selectedCategory = category),
        );
      },
      loading: () => const GlassInputField(
        label: 'Category',
        child: _FieldStatusText(text: 'Loading categories...'),
      ),
      error: (_, _) => GlassInputField(
        label: 'Category',
        child: _RetryFieldText(
          text: 'Could not load categories',
          onRetry: () => ref.invalidate(eventCategoriesProvider),
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return GlassInputField(
      label: 'Visibility',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isPublic ? 'Public Event' : 'Private Event',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SegmentedToggle(
            options: const ['Public', 'Private'],
            selectedIndex: _isPublic ? 0 : 1,
            onSelect: (index) => setState(() => _isPublic = index == 0),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(bool isSubmitting) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withValues(alpha: 0),
              AppColors.background.withValues(alpha: 0.9),
              AppColors.background,
            ],
          ),
        ),
        child: PrimaryButton(
          label: isSubmitting ? 'Updating Event' : 'Update Event Details',
          icon: Icons.save_outlined,
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : _submit,
        ),
      ),
    );
  }

  void _hydrate(EventModel event) {
    _nameCtrl.text = event.title;
    _startDateCtrl.text = DateFormat('yyyy-MM-dd').format(event.startDate);
    _startTimeCtrl.text = DateFormat('HH:mm').format(event.startDate);
    final end = event.endDate ?? event.startDate.add(const Duration(hours: 2));
    _endDateCtrl.text = DateFormat('yyyy-MM-dd').format(end);
    _endTimeCtrl.text = DateFormat('HH:mm').format(end);
    _capacityCtrl.text = event.guestCount?.toString() ?? '';
    _descCtrl.text = event.description ?? '';
    _isPublic = event.visibility != EventVisibility.private;
    _hydrated = true;
  }

  EventRoomModel? _matchingInitialRoom(List<EventRoomModel> rooms) {
    final event = widget.initialEvent;
    final location = event?.location.trim().toLowerCase();
    if (location == null || location.isEmpty) return null;

    for (final room in rooms) {
      final values = [room.id, room.name, room.code, room.displayName]
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty);
      if (values.any(location.contains)) return room;
    }
    return null;
  }

  EventCategoryModel? _matchingInitialCategory(
    List<EventCategoryModel> categories,
  ) {
    final event = widget.initialEvent;
    final category = event?.category?.trim().toLowerCase();
    if (category == null || category.isEmpty) return null;

    for (final item in categories) {
      final values = [item.id, item.name, item.slug ?? '']
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty);
      if (values.contains(category)) return item;
    }
    return null;
  }

  Future<void> _pickCoverImage() async {
    XFile? pickedImage;
    try {
      pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
    } on PlatformException {
      if (!mounted) return;
      _showMessage('Không mở được thư viện ảnh. Vui lòng khởi động lại app.');
      return;
    }

    if (pickedImage == null) return;
    setState(() => _coverImageFile = File(pickedImage!.path));
  }

  Future<void> _submit() async {
    final title = _nameCtrl.text.trim();
    final maxCapacity = int.tryParse(_capacityCtrl.text.trim());
    final startAt = _parseDateTime(_startDateCtrl.text, _startTimeCtrl.text);
    final endAt = _parseDateTime(_endDateCtrl.text, _endTimeCtrl.text);

    if (title.isEmpty ||
        maxCapacity == null ||
        startAt == null ||
        endAt == null) {
      _showMessage('Vui lòng nhập tên, thời gian và sức chứa hợp lệ.');
      return;
    }

    if (!endAt.isAfter(startAt)) {
      _showMessage('Thời gian kết thúc phải sau thời gian bắt đầu.');
      return;
    }

    final selectedRoom = _selectedRoom;
    if (selectedRoom != null &&
        selectedRoom.capacity > 0 &&
        maxCapacity > selectedRoom.capacity) {
      _showMessage('Số khách không được vượt quá sức chứa phòng.');
      return;
    }

    final updated = await ref
        .read(eventMutationControllerProvider.notifier)
        .updateOrganizerEvent(
          eventId: widget.eventId,
          title: title,
          description: _descCtrl.text.trim(),
          category: _selectedCategory,
          room: selectedRoom,
          coverImage: _coverImageFile,
          maxCapacity: maxCapacity,
          startAt: startAt,
          endAt: endAt,
          isPublic: _isPublic,
        );

    if (!mounted) return;

    if (updated) {
      _showMessage('Cập nhật sự kiện thành công.');
      widget.onSave?.call();
      widget.onBack?.call();
      return;
    }

    final error = ref.read(eventMutationControllerProvider).error;
    _showMessage(eventMutationErrorMessage(error ?? Object()));
  }

  DateTime? _parseDateTime(String date, String time) {
    final normalized = '${date.trim()} ${time.trim()}';
    for (final pattern in ['yyyy-MM-dd HH:mm', 'yyyy-MM-dd HH:mm:ss']) {
      try {
        return DateFormat(pattern).parseStrict(normalized);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  void _showMessage(String message) {
    showAppSnackBar(context, message);
  }
}

class _FieldStatusText extends StatelessWidget {
  final String text;

  const _FieldStatusText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.inputHint);
  }
}

class _RetryFieldText extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _RetryFieldText({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(text, style: AppTextStyles.inputHint)),
        TextActionButton(
          label: 'Retry',
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          onPressed: onRetry,
        ),
      ],
    );
  }
}
