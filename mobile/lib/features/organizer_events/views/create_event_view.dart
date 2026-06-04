// File: lib/features/organizer_events/views/create_event_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/segmented_toggle.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_room_model.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateEventView extends ConsumerStatefulWidget {
  final String? eventId;
  final EventModel? initialEvent;
  final VoidCallback? onBack;
  final VoidCallback? onSaved;

  const CreateEventView({
    super.key,
    this.eventId,
    this.initialEvent,
    this.onBack,
    this.onSaved,
  });

  @override
  ConsumerState<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends ConsumerState<CreateEventView> {
  final _titleController = TextEditingController();
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _registrationOpenDateController = TextEditingController();
  final _registrationOpenTimeController = TextEditingController();
  final _registrationCloseDateController = TextEditingController();
  final _registrationCloseTimeController = TextEditingController();
  final _cancellationDeadlineDateController = TextEditingController();
  final _cancellationDeadlineTimeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isPublic = true;
  bool _activateImmediately = true;
  bool _hydrated = false;
  bool _hydratedFromDetail = false;
  File? _coverImageFile;
  EventRoomModel? _selectedRoom;
  EventCategoryModel? _selectedCategory;
  EventModel? _activeEvent;

  bool get _isEditing => widget.eventId != null || widget.initialEvent != null;
  String? get _resolvedEventId => widget.eventId ?? widget.initialEvent?.id;

  @override
  void initState() {
    super.initState();
    final initialEvent = widget.initialEvent;
    if (initialEvent != null) {
      _hydrate(initialEvent);
      return;
    }

    _setDefaultSchedule();
  }

  void _setDefaultSchedule() {
    final now = DateTime.now();
    final start = now.add(const Duration(days: 1));
    final end = start.add(const Duration(hours: 2));
    _setScheduleControllers(startAt: start, endAt: end);
    _setRegistrationScheduleControllers(
      registrationOpenAt: now,
      registrationCloseAt: start.subtract(const Duration(hours: 1)),
      cancellationDeadlineAt: start.subtract(const Duration(hours: 3)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _registrationOpenDateController.dispose();
    _registrationOpenTimeController.dispose();
    _registrationCloseDateController.dispose();
    _registrationCloseTimeController.dispose();
    _cancellationDeadlineDateController.dispose();
    _cancellationDeadlineTimeController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventId = _resolvedEventId;
    final detailState = _isEditing && eventId != null
        ? ref.watch(organizerEventDetailProvider(eventId))
        : null;
    final detailEvent = detailState?.whenOrNull(data: (value) => value);
    final event = detailEvent ?? widget.initialEvent;

    if (_isEditing && !_hydrated && event != null) {
      _activeEvent = event;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hydrated) _hydrate(event);
      });
    }

    if (_isEditing &&
        detailEvent != null &&
        !_hydratedFromDetail &&
        _canHydrateFromDetail()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hydratedFromDetail && _canHydrateFromDetail()) {
          _hydrate(detailEvent, fromDetail: true);
          setState(() {});
        }
      });
    }

    if (_isEditing && event == null && detailState?.isLoading == true) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isEditing && event == null && detailState?.hasError == true) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
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
                    label: 'Thử lại',
                    icon: Icons.refresh,
                    onPressed: eventId == null
                        ? null
                        : () => ref.invalidate(
                            organizerEventDetailProvider(eventId),
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
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          _buildBackgroundBlobs(),
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCoverUpload(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildForm(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: _isEditing ? 'Chỉnh sửa sự kiện' : 'Tạo sự kiện',
              titleStyle: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              leadingIcon: Icons.arrow_back_ios,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
          _buildBottomCta(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final roomsAsync = ref.watch(organizerEventRoomsProvider);
    final categoriesAsync = ref.watch(organizerEventCategoriesProvider);

    return Column(
      children: [
        GlassInputField(label: 'Tên sự kiện', controller: _titleController),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Mô tả',
          controller: _descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Thời gian bắt đầu',
          child: _DateTimePickerButton(
            icon: Icons.event,
            value: _formatPickerDateTime(_currentStartAt),
            onTap: () => _pickDateTime(isStart: true),
          ),
        ),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Thời gian kết thúc',
          child: _DateTimePickerButton(
            icon: Icons.event_available,
            value: _formatPickerDateTime(_currentEndAt),
            onTap: () => _pickDateTime(isStart: false),
          ),
        ),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Mở đăng ký',
          child: _DateTimePickerButton(
            icon: Icons.how_to_reg,
            value: _formatPickerDateTime(_currentRegistrationOpenAt),
            onTap: () => _pickRegistrationDateTime(
              field: _RegistrationDateTimeField.open,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Đóng đăng ký',
          child: _DateTimePickerButton(
            icon: Icons.event_busy,
            value: _formatPickerDateTime(_currentRegistrationCloseAt),
            onTap: () => _pickRegistrationDateTime(
              field: _RegistrationDateTimeField.close,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Hạn hủy đăng ký',
          child: _DateTimePickerButton(
            icon: Icons.cancel_schedule_send,
            value: _formatPickerDateTime(_currentCancellationDeadlineAt),
            onTap: () => _pickRegistrationDateTime(
              field: _RegistrationDateTimeField.cancellationDeadline,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildRoomDropdown(roomsAsync),
        const SizedBox(height: 16),
        _buildCategoryDropdown(categoriesAsync),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Số lượng khách',
          placeholder: _selectedRoom == null
              ? 'VD: 120'
              : 'Tối đa ${_selectedRoom!.capacity}',
          leadingIcon: Icons.group,
          controller: _capacityController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildVisibilityToggle(),
        if (!_isEditing) ...[
          const SizedBox(height: 16),
          _buildPublishStateToggle(),
        ],
      ],
    );
  }

  Widget _buildRoomDropdown(AsyncValue<List<EventRoomModel>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) {
        final selectedRoom = _selectedRoom ?? _matchingInitialRoom(rooms);

        return GlassDropdownField<EventRoomModel>(
          label: 'Địa điểm',
          placeholder: rooms.isEmpty ? 'Không có phòng khả dụng' : 'Chọn phòng',
          value: selectedRoom,
          items: rooms
              .map(
                (room) => GlassDropdownItem(
                  value: room,
                  label: '${room.displayName} - ${room.capacity} chỗ',
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
        label: 'Địa điểm',
        child: _LoadingFieldText(text: 'Đang tải phòng...'),
      ),
      error: (_, _) => GlassInputField(
        label: 'Địa điểm',
        child: _RetryFieldText(
          text: 'Không tải được danh sách phòng',
          onRetry: () => ref.invalidate(organizerEventRoomsProvider),
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
          label: 'Danh mục',
          placeholder: categories.isEmpty
              ? 'Không có danh mục khả dụng'
              : 'Chọn danh mục',
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
        label: 'Danh mục',
        child: _LoadingFieldText(text: 'Đang tải danh mục...'),
      ),
      error: (_, _) => GlassInputField(
        label: 'Danh mục',
        child: _RetryFieldText(
          text: 'Không tải được danh mục',
          onRetry: () => ref.invalidate(organizerEventCategoriesProvider),
        ),
      ),
    );
  }

  Widget _buildCoverUpload() {
    final imageFile = _coverImageFile;
    final currentImageUrl =
        _activeEvent?.imageUrl ?? widget.initialEvent?.imageUrl ?? '';
    final hasCurrentImage = currentImageUrl.isNotEmpty && imageFile == null;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: _pickCoverImage,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDCDCDF), width: 2),
              color: Colors.white.withValues(alpha: 0.3),
              image: imageFile != null || hasCurrentImage
                  ? DecorationImage(
                      image: imageFile != null
                          ? FileImage(imageFile)
                          : NetworkImage(currentImageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.18),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    imageFile == null
                        ? Icons.add_photo_alternate
                        : Icons.photo_library_outlined,
                    color: AppColors.onPrimaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  imageFile == null && !hasCurrentImage
                      ? 'Thêm ảnh bìa'
                      : 'Đổi ảnh bìa',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: imageFile == null && !hasCurrentImage
                        ? null
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  imageFile != null
                      ? _fileNameFromPath(imageFile.path)
                      : hasCurrentImage
                      ? 'ẢNH BÌA HIỆN TẠI'
                      : 'KHUYẾN NGHỊ TỶ LỆ 16:9',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inputLabel.copyWith(
                    letterSpacing: 1.5,
                    color: imageFile == null && !hasCurrentImage
                        ? null
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final settingsController = ref.read(appSettingControllerProvider.notifier);
    final permission = await settingsController.requestPermission(
      AppPermissionKey.photos,
    );
    final allowed =
        permission?.status == AppPermissionStatus.granted ||
        permission?.status == AppPermissionStatus.limited;
    if (!allowed) {
      if (permission?.status.canOpenSystemSettings == true) {
        await settingsController.openSystemSettings(AppPermissionKey.photos);
      }
      if (mounted) {
        _showMessage('Cần quyền ảnh và thư viện để chọn ảnh bìa sự kiện.');
      }
      return;
    }

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
    final selectedImage = pickedImage;
    setState(() => _coverImageFile = File(selectedImage.path));
  }

  Future<void> _submitEvent() async {
    final isSubmitting = ref
        .read(organizerEventMutationControllerProvider)
        .isLoading;
    if (isSubmitting) return;

    final title = _titleController.text.trim();
    final selectedCategory = _selectedCategory;
    final selectedRoom = _selectedRoom;
    final coverImage = _coverImageFile;
    final maxCapacity = int.tryParse(_capacityController.text.trim());
    final startAt = _parseDateTime(
      _startDateController.text,
      _startTimeController.text,
    );
    final endAt = _parseDateTime(
      _endDateController.text,
      _endTimeController.text,
    );
    final registrationOpenAt = _parseDateTime(
      _registrationOpenDateController.text,
      _registrationOpenTimeController.text,
    );
    final registrationCloseAt = _parseDateTime(
      _registrationCloseDateController.text,
      _registrationCloseTimeController.text,
    );
    final cancellationDeadlineAt = _parseDateTime(
      _cancellationDeadlineDateController.text,
      _cancellationDeadlineTimeController.text,
    );

    if (_isEditing) {
      await _submitEventUpdate(
        title: title,
        selectedCategory: selectedCategory,
        selectedRoom: selectedRoom,
        coverImage: coverImage,
        maxCapacity: maxCapacity,
        startAt: startAt,
        endAt: endAt,
        registrationOpenAt: registrationOpenAt,
        registrationCloseAt: registrationCloseAt,
        cancellationDeadlineAt: cancellationDeadlineAt,
      );
      return;
    }

    if (title.isEmpty ||
        selectedCategory == null ||
        selectedRoom == null ||
        coverImage == null ||
        maxCapacity == null ||
        startAt == null ||
        endAt == null ||
        registrationOpenAt == null ||
        registrationCloseAt == null ||
        cancellationDeadlineAt == null) {
      _showMessage('Vui lòng nhập đủ thông tin và chọn ảnh bìa.');
      return;
    }

    if (!_validateSchedule(
      startAt: startAt,
      endAt: endAt,
      registrationOpenAt: registrationOpenAt,
      registrationCloseAt: registrationCloseAt,
      cancellationDeadlineAt: cancellationDeadlineAt,
    )) {
      return;
    }

    if (selectedRoom.capacity > 0 && maxCapacity > selectedRoom.capacity) {
      _showMessage('Số khách không được vượt quá sức chứa phòng.');
      return;
    }

    final created = await ref
        .read(organizerEventMutationControllerProvider.notifier)
        .createOrganizerEventWithCover(
          title: title,
          description: _descriptionController.text.trim(),
          category: selectedCategory,
          room: selectedRoom,
          coverImage: coverImage,
          maxCapacity: maxCapacity,
          startAt: startAt,
          endAt: endAt,
          registrationOpenAt: registrationOpenAt,
          registrationCloseAt: registrationCloseAt,
          cancellationDeadlineAt: cancellationDeadlineAt,
          isPublic: _isPublic,
          activateImmediately: _activateImmediately,
        );

    if (!mounted) return;

    if (created) {
      _showMessage('Tạo sự kiện thành công.');
      widget.onBack?.call();
      return;
    }

    final error = ref.read(organizerEventMutationControllerProvider).error;
    _showMessage(eventMutationErrorMessage(error ?? Object()));
  }

  Future<void> _submitEventUpdate({
    required String title,
    required EventCategoryModel? selectedCategory,
    required EventRoomModel? selectedRoom,
    required File? coverImage,
    required int? maxCapacity,
    required DateTime? startAt,
    required DateTime? endAt,
    required DateTime? registrationOpenAt,
    required DateTime? registrationCloseAt,
    required DateTime? cancellationDeadlineAt,
  }) async {
    final eventId = _resolvedEventId;
    if (eventId == null) {
      _showMessage('Không tìm thấy sự kiện để cập nhật.');
      return;
    }

    if (title.isEmpty ||
        maxCapacity == null ||
        startAt == null ||
        endAt == null ||
        registrationOpenAt == null ||
        registrationCloseAt == null ||
        cancellationDeadlineAt == null) {
      _showMessage('Vui lòng nhập tên, thời gian và sức chứa hợp lệ.');
      return;
    }

    if (!_validateSchedule(
      startAt: startAt,
      endAt: endAt,
      registrationOpenAt: registrationOpenAt,
      registrationCloseAt: registrationCloseAt,
      cancellationDeadlineAt: cancellationDeadlineAt,
    )) {
      return;
    }

    if (selectedRoom != null &&
        selectedRoom.capacity > 0 &&
        maxCapacity > selectedRoom.capacity) {
      _showMessage('Số khách không được vượt quá sức chứa phòng.');
      return;
    }

    final updated = await ref
        .read(organizerEventMutationControllerProvider.notifier)
        .updateOrganizerEvent(
          eventId: eventId,
          title: title,
          description: _descriptionController.text.trim(),
          category: selectedCategory,
          room: selectedRoom,
          coverImage: coverImage,
          maxCapacity: maxCapacity,
          startAt: startAt,
          endAt: endAt,
          registrationOpenAt: registrationOpenAt,
          registrationCloseAt: registrationCloseAt,
          cancellationDeadlineAt: cancellationDeadlineAt,
          isPublic: _isPublic,
        );

    if (!mounted) return;

    if (updated) {
      _showMessage('Cập nhật sự kiện thành công.');
      widget.onSaved?.call();
      widget.onBack?.call();
      return;
    }

    _showMessage('Không cập nhật được sự kiện. Vui lòng thử lại.');
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

  DateTime? get _currentStartAt =>
      _parseDateTime(_startDateController.text, _startTimeController.text);

  DateTime? get _currentEndAt =>
      _parseDateTime(_endDateController.text, _endTimeController.text);

  DateTime? get _currentRegistrationOpenAt => _parseDateTime(
    _registrationOpenDateController.text,
    _registrationOpenTimeController.text,
  );

  DateTime? get _currentRegistrationCloseAt => _parseDateTime(
    _registrationCloseDateController.text,
    _registrationCloseTimeController.text,
  );

  DateTime? get _currentCancellationDeadlineAt => _parseDateTime(
    _cancellationDeadlineDateController.text,
    _cancellationDeadlineTimeController.text,
  );

  String _formatPickerDateTime(DateTime? value) {
    if (value == null) return 'Chọn ngày và giờ';
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  bool _validateSchedule({
    required DateTime startAt,
    required DateTime endAt,
    required DateTime registrationOpenAt,
    required DateTime registrationCloseAt,
    required DateTime cancellationDeadlineAt,
  }) {
    if (!endAt.isAfter(startAt)) {
      _showMessage('Thời gian kết thúc phải sau thời gian bắt đầu.');
      return false;
    }

    if (registrationOpenAt.isAfter(registrationCloseAt)) {
      _showMessage('Thời gian đóng đăng ký phải sau thời gian mở đăng ký.');
      return false;
    }

    if (registrationCloseAt.isAfter(startAt)) {
      _showMessage('Thời gian đóng đăng ký phải trước thời gian tổ chức.');
      return false;
    }

    if (cancellationDeadlineAt.isAfter(startAt)) {
      _showMessage('Hạn hủy đăng ký phải trước thời gian tổ chức.');
      return false;
    }

    return true;
  }

  void _setScheduleControllers({
    required DateTime startAt,
    required DateTime endAt,
  }) {
    _startDateController.text = DateFormat('yyyy-MM-dd').format(startAt);
    _startTimeController.text = DateFormat('HH:mm').format(startAt);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(endAt);
    _endTimeController.text = DateFormat('HH:mm').format(endAt);
  }

  void _setRegistrationScheduleControllers({
    required DateTime registrationOpenAt,
    required DateTime registrationCloseAt,
    required DateTime cancellationDeadlineAt,
  }) {
    _setRegistrationOpenControllers(registrationOpenAt);
    _setRegistrationCloseControllers(registrationCloseAt);
    _setCancellationDeadlineControllers(cancellationDeadlineAt);
  }

  void _setStartControllers(DateTime value) {
    _startDateController.text = DateFormat('yyyy-MM-dd').format(value);
    _startTimeController.text = DateFormat('HH:mm').format(value);
  }

  void _setEndControllers(DateTime value) {
    _endDateController.text = DateFormat('yyyy-MM-dd').format(value);
    _endTimeController.text = DateFormat('HH:mm').format(value);
  }

  void _setRegistrationOpenControllers(DateTime value) {
    _registrationOpenDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(value);
    _registrationOpenTimeController.text = DateFormat('HH:mm').format(value);
  }

  void _setRegistrationCloseControllers(DateTime value) {
    _registrationCloseDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(value);
    _registrationCloseTimeController.text = DateFormat('HH:mm').format(value);
  }

  void _setCancellationDeadlineControllers(DateTime value) {
    _cancellationDeadlineDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(value);
    _cancellationDeadlineTimeController.text = DateFormat(
      'HH:mm',
    ).format(value);
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final current = isStart
        ? _currentStartAt ?? now.add(const Duration(days: 1))
        : _currentEndAt ??
              (_currentStartAt ?? now.add(const Duration(days: 1))).add(
                const Duration(hours: 2),
              );
    final initialDate = DateTime(current.year, current.month, current.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (pickedTime == null || !mounted) return;

    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _setStartControllers(pickedDateTime);
        final currentEnd = _currentEndAt;
        if (currentEnd == null || !currentEnd.isAfter(pickedDateTime)) {
          _setEndControllers(pickedDateTime.add(const Duration(hours: 2)));
        }
        final currentRegistrationClose = _currentRegistrationCloseAt;
        if (currentRegistrationClose == null ||
            currentRegistrationClose.isAfter(pickedDateTime)) {
          _setRegistrationCloseControllers(
            pickedDateTime.subtract(const Duration(hours: 1)),
          );
        }
        final currentCancellationDeadline = _currentCancellationDeadlineAt;
        if (currentCancellationDeadline == null ||
            currentCancellationDeadline.isAfter(pickedDateTime)) {
          _setCancellationDeadlineControllers(
            pickedDateTime.subtract(const Duration(hours: 3)),
          );
        }
      } else {
        _setEndControllers(pickedDateTime);
      }
    });
  }

  Future<void> _pickRegistrationDateTime({
    required _RegistrationDateTimeField field,
  }) async {
    final now = DateTime.now();
    final startAt = _currentStartAt ?? now.add(const Duration(days: 1));
    final current = switch (field) {
      _RegistrationDateTimeField.open => _currentRegistrationOpenAt ?? now,
      _RegistrationDateTimeField.close =>
        _currentRegistrationCloseAt ??
            startAt.subtract(const Duration(hours: 1)),
      _RegistrationDateTimeField.cancellationDeadline =>
        _currentCancellationDeadlineAt ??
            startAt.subtract(const Duration(hours: 3)),
    };
    final initialDate = DateTime(current.year, current.month, current.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (pickedTime == null || !mounted) return;

    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      switch (field) {
        case _RegistrationDateTimeField.open:
          _setRegistrationOpenControllers(pickedDateTime);
        case _RegistrationDateTimeField.close:
          _setRegistrationCloseControllers(pickedDateTime);
        case _RegistrationDateTimeField.cancellationDeadline:
          _setCancellationDeadlineControllers(pickedDateTime);
      }
    });
  }

  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final slashIndex = normalized.lastIndexOf('/');
    return slashIndex == -1 ? normalized : normalized.substring(slashIndex + 1);
  }

  void _showMessage(String message) {
    showAppSnackBar(context, message);
  }

  void _hydrate(EventModel event, {bool fromDetail = false}) {
    _activeEvent = event;
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    final end = event.endDate ?? event.startDate.add(const Duration(hours: 2));
    _setScheduleControllers(startAt: event.startDate, endAt: end);
    _setRegistrationScheduleControllers(
      registrationOpenAt:
          event.registrationOpenAt ??
          event.startDate.subtract(const Duration(days: 7)),
      registrationCloseAt:
          event.registrationCloseAt ??
          event.startDate.subtract(const Duration(hours: 1)),
      cancellationDeadlineAt:
          event.cancellationDeadlineAt ??
          event.startDate.subtract(const Duration(hours: 3)),
    );
    _capacityController.text = event.guestCount?.toString() ?? '';
    _isPublic = event.visibility != EventVisibility.private;
    _activateImmediately = event.status != EventStatus.draft;
    _hydrated = true;
    if (fromDetail) _hydratedFromDetail = true;
  }

  bool _canHydrateFromDetail() {
    final activeEvent = _activeEvent;
    if (activeEvent == null) return true;

    final activeEnd =
        activeEvent.endDate ??
        activeEvent.startDate.add(const Duration(hours: 2));
    final activeRegistrationOpen =
        activeEvent.registrationOpenAt ??
        activeEvent.startDate.subtract(const Duration(days: 7));
    final activeRegistrationClose =
        activeEvent.registrationCloseAt ??
        activeEvent.startDate.subtract(const Duration(hours: 1));
    final activeCancellationDeadline =
        activeEvent.cancellationDeadlineAt ??
        activeEvent.startDate.subtract(const Duration(hours: 3));

    return _titleController.text == activeEvent.title &&
        _descriptionController.text == (activeEvent.description ?? '') &&
        _startDateController.text ==
            DateFormat('yyyy-MM-dd').format(activeEvent.startDate) &&
        _startTimeController.text ==
            DateFormat('HH:mm').format(activeEvent.startDate) &&
        _endDateController.text == DateFormat('yyyy-MM-dd').format(activeEnd) &&
        _endTimeController.text == DateFormat('HH:mm').format(activeEnd) &&
        _registrationOpenDateController.text ==
            DateFormat('yyyy-MM-dd').format(activeRegistrationOpen) &&
        _registrationOpenTimeController.text ==
            DateFormat('HH:mm').format(activeRegistrationOpen) &&
        _registrationCloseDateController.text ==
            DateFormat('yyyy-MM-dd').format(activeRegistrationClose) &&
        _registrationCloseTimeController.text ==
            DateFormat('HH:mm').format(activeRegistrationClose) &&
        _cancellationDeadlineDateController.text ==
            DateFormat('yyyy-MM-dd').format(activeCancellationDeadline) &&
        _cancellationDeadlineTimeController.text ==
            DateFormat('HH:mm').format(activeCancellationDeadline) &&
        _capacityController.text == (activeEvent.guestCount?.toString() ?? '');
  }

  EventRoomModel? _matchingInitialRoom(List<EventRoomModel> rooms) {
    final location = (_activeEvent ?? widget.initialEvent)?.location
        .trim()
        .toLowerCase();
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
    final category = (_activeEvent ?? widget.initialEvent)?.category
        ?.trim()
        .toLowerCase();
    if (category == null || category.isEmpty) return null;

    for (final item in categories) {
      final values = [item.id, item.name, item.slug ?? '']
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty);
      if (values.contains(category)) return item;
    }
    return null;
  }

  Widget _buildVisibilityToggle() {
    return GlassInputField(
      label: 'Hiển thị',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isPublic ? 'Sự kiện công khai' : 'Sự kiện riêng tư',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SegmentedToggle(
            options: const ['Công khai', 'Riêng tư'],
            selectedIndex: _isPublic ? 0 : 1,
            onSelect: (index) => setState(() => _isPublic = index == 0),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishStateToggle() {
    return GlassInputField(
      label: 'Trạng thái xuất bản',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _activateImmediately ? 'Kích hoạt ngay' : 'Lưu nháp',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SegmentedToggle(
            options: const ['Kích hoạt', 'Nháp'],
            selectedIndex: _activateImmediately ? 0 : 1,
            onSelect: (index) =>
                setState(() => _activateImmediately = index == 0),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta() {
    final isSubmitting = ref
        .watch(organizerEventMutationControllerProvider)
        .isLoading;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF2F2F7).withValues(alpha: 0.0),
              const Color(0xFFF2F2F7).withValues(alpha: 0.8),
              const Color(0xFFF2F2F7),
            ],
          ),
        ),
        child: PrimaryButton(
          label: isSubmitting
              ? (_isEditing ? 'Đang cập nhật' : 'Đang tạo sự kiện')
              : (_isEditing ? 'Cập nhật sự kiện' : 'Tạo sự kiện'),
          icon: _isEditing ? Icons.save_outlined : Icons.rocket_launch,
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : _submitEvent,
        ),
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: -50,
              child: Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RegistrationDateTimeField { open, close, cancellationDeadline }

class _DateTimePickerButton extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _DateTimePickerButton({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingFieldText extends StatelessWidget {
  final String text;

  const _LoadingFieldText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.inputHint)),
      ],
    );
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
        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.inputHint)),
        TextActionButton(label: 'Thử lại', onPressed: onRetry),
      ],
    );
  }
}
