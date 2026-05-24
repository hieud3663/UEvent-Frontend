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
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_room_model.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateEventView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const CreateEventView({super.key, this.onBack});

  @override
  ConsumerState<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends ConsumerState<CreateEventView> {
  final _titleController = TextEditingController();
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isPublic = true;
  bool _activateImmediately = true;
  File? _coverImageFile;
  EventRoomModel? _selectedRoom;
  EventCategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final start = DateTime.now().add(const Duration(days: 1));
    final end = start.add(const Duration(hours: 2));
    _startDateController.text = DateFormat('yyyy-MM-dd').format(start);
    _startTimeController.text = DateFormat('HH:mm').format(start);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(end);
    _endTimeController.text = DateFormat('HH:mm').format(end);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              title: 'Tạo sự kiện',
              titleStyle: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              leadingIcon: Icons.arrow_back_ios,
              trailingIcon: Icons.more_horiz,
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
        GlassInputField(
          label: 'Tên sự kiện',
          placeholder: 'Đêm nhạc sân thượng mùa hè',
          controller: _titleController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassInputField(
                label: 'Ngày bắt đầu',
                placeholder: '2026-05-22',
                leadingIcon: Icons.calendar_today,
                controller: _startDateController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassInputField(
                label: 'Giờ bắt đầu',
                placeholder: '07:00',
                leadingIcon: Icons.schedule,
                controller: _startTimeController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassInputField(
                label: 'Ngày kết thúc',
                placeholder: '2026-05-23',
                leadingIcon: Icons.event_available,
                controller: _endDateController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassInputField(
                label: 'Giờ kết thúc',
                placeholder: '09:00',
                leadingIcon: Icons.schedule,
                controller: _endTimeController,
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
        const SizedBox(height: 16),
        _buildPublishStateToggle(),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Mô tả',
          placeholder: 'Giới thiệu sự kiện của bạn...',
          controller: _descriptionController,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildRoomDropdown(AsyncValue<List<EventRoomModel>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) => GlassDropdownField<EventRoomModel>(
        label: 'Địa điểm',
        placeholder: rooms.isEmpty ? 'Không có phòng khả dụng' : 'Chọn phòng',
        value: _selectedRoom,
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
      ),
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
      data: (categories) => GlassDropdownField<EventCategoryModel>(
        label: 'Danh mục',
        placeholder: categories.isEmpty
            ? 'Không có danh mục khả dụng'
            : 'Chọn danh mục',
        value: _selectedCategory,
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
      ),
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
              image: imageFile == null
                  ? null
                  : DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.18),
                        BlendMode.darken,
                      ),
                    ),
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
                  imageFile == null ? 'Thêm ảnh bìa' : 'Đổi ảnh bìa',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: imageFile == null ? null : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  imageFile == null
                      ? 'KHUYẾN NGHỊ TỶ LỆ 16:9'
                      : _fileNameFromPath(imageFile.path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inputLabel.copyWith(
                    letterSpacing: 1.5,
                    color: imageFile == null ? null : Colors.white,
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

    if (title.isEmpty ||
        selectedCategory == null ||
        selectedRoom == null ||
        coverImage == null ||
        maxCapacity == null ||
        startAt == null ||
        endAt == null) {
      _showMessage('Vui lòng nhập đủ thông tin và chọn ảnh bìa.');
      return;
    }

    if (!endAt.isAfter(startAt)) {
      _showMessage('Thời gian kết thúc phải sau thời gian bắt đầu.');
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

  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final slashIndex = normalized.lastIndexOf('/');
    return slashIndex == -1 ? normalized : normalized.substring(slashIndex + 1);
  }

  void _showMessage(String message) {
    showAppSnackBar(context, message);
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
          label: isSubmitting ? 'Đang tạo sự kiện' : 'Tạo sự kiện',
          icon: Icons.rocket_launch,
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
