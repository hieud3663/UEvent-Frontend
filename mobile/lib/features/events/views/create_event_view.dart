// File: lib/views/create_event_view.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/segmented_toggle.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_room_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';
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
  bool _isSubmitting = false;
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
              title: 'Create Event',
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
    final roomsAsync = ref.watch(eventRoomsProvider);
    final categoriesAsync = ref.watch(eventCategoriesProvider);

    return Column(
      children: [
        GlassInputField(
          label: 'Event Name',
          placeholder: 'Summer Rooftop Gala',
          controller: _titleController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassInputField(
                label: 'Start Date',
                placeholder: '2026-05-22',
                leadingIcon: Icons.calendar_today,
                controller: _startDateController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassInputField(
                label: 'Start Time',
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
                label: 'End Date',
                placeholder: '2026-05-23',
                leadingIcon: Icons.event_available,
                controller: _endDateController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassInputField(
                label: 'End Time',
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
          label: 'Number of guests',
          placeholder: _selectedRoom == null
              ? 'e.g. 120'
              : 'Max ${_selectedRoom!.capacity}',
          leadingIcon: Icons.group,
          controller: _capacityController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildVisibilityToggle(),
        const SizedBox(height: 16),
        GlassInputField(
          label: 'Description',
          placeholder: 'Tell everyone about your event...',
          controller: _descriptionController,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildRoomDropdown(AsyncValue<List<EventRoomModel>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) => GlassDropdownField<EventRoomModel>(
        label: 'Location',
        placeholder: rooms.isEmpty ? 'No rooms available' : 'Select room',
        value: _selectedRoom,
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
      ),
      loading: () => const GlassInputField(
        label: 'Location',
        child: _LoadingFieldText(text: 'Loading rooms...'),
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
      data: (categories) => GlassDropdownField<EventCategoryModel>(
        label: 'Category',
        placeholder: categories.isEmpty
            ? 'No categories available'
            : 'Select category',
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
        label: 'Category',
        child: _LoadingFieldText(text: 'Loading categories...'),
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
                  imageFile == null ? 'Add Event Cover' : 'Change Event Cover',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: imageFile == null ? null : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  imageFile == null
                      ? '16:9 ASPECT RATIO RECOMMENDED'
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
    if (_isSubmitting) return;

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

    setState(() => _isSubmitting = true);

    try {
      final eventService = ref.read(eventServiceProvider);
      final registrationOpenAt = DateTime.now();
      final registrationCloseAt = startAt.subtract(const Duration(hours: 1));
      final cancellationDeadlineAt = startAt.subtract(const Duration(hours: 3));

      final createdEvent = await eventService.createOrganizerEvent({
        'title': title,
        'category': selectedCategory.id,
        'room': selectedRoom.id,
        'description': _descriptionController.text.trim(),
        'visibility': _isPublic ? 'public' : 'private',
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
        'location_snapshot': selectedRoom.displayName,
        'cover_image_url': '',
        'deep_link': '',
        'status': 'draft',
      });

      final contentType = _contentTypeForPath(coverImage.path);
      final fileName =
          '${createdEvent.id}.${_extensionForContentType(contentType)}';
      final uploadTarget = await eventService.getEventCoverPresignedUrl(
        fileName: fileName,
        contentType: contentType,
      );
      if (uploadTarget.presignedUrl.isEmpty) {
        _showMessage('Server không trả presigned URL để upload ảnh.');
        return;
      }

      await eventService.uploadEventCoverImage(
        imageFile: coverImage,
        presignedUrl: uploadTarget.presignedUrl,
        contentType: contentType,
      );

      ref.invalidate(organizerEventsProvider);
      ref.invalidate(organizerEventsPagerProvider);
      if (!mounted) return;
      _showMessage('Tạo sự kiện thành công.');
      widget.onBack?.call();
    } on DioException catch (error) {
      if (!mounted) return;
      _showMessage(_uploadErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Không tạo được sự kiện. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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

  String _toApiDate(DateTime date) => date.toUtc().toIso8601String();

  String _uploadErrorMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data?.toString();
    if (statusCode != null && error.requestOptions.uri.host.contains('s3')) {
      debugPrint('S3 upload failed [$statusCode]: $responseData');
      return 'Tạo event thành công nhưng upload ảnh lên S3 thất bại ($statusCode).';
    }

    debugPrint('Create event failed: ${error.message} $responseData');
    return 'Không tạo được sự kiện. Vui lòng thử lại.';
  }

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

  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final slashIndex = normalized.lastIndexOf('/');
    return slashIndex == -1 ? normalized : normalized.substring(slashIndex + 1);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  Widget _buildBottomCta() {
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
          label: _isSubmitting ? 'Creating Event' : 'Create Event',
          icon: Icons.rocket_launch,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitEvent,
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
        TextActionButton(label: 'Retry', onPressed: onRetry),
      ],
    );
  }
}
