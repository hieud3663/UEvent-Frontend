import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/config/faculty_config.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/services/profile_service.dart';
import 'package:frontend/features/profile/widgets/edit_profile_form_sections.dart';
import 'package:frontend/features/profile/widgets/profile_avatar_editor.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatefulWidget {
  final UserModel? user;
  final ProfileService? profileService;
  final VoidCallback? onBack;
  final VoidCallback? onSaved;
  final VoidCallback? onChangeEmail;

  const EditProfileView({
    super.key,
    this.user,
    this.profileService,
    this.onBack,
    this.onSaved,
    this.onChangeEmail,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _studentCodeCtrl;
  late final TextEditingController _classNameCtrl;
  late final TextEditingController _phoneCtrl;

  final _imagePicker = ImagePicker();
  String? _selectedFaculty;
  File? _selectedAvatarFile;
  String? _selectedAvatarFileName;
  String? _selectedAvatarContentType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _studentCodeCtrl = TextEditingController(text: user?.studentCode ?? '');
    _classNameCtrl = TextEditingController(text: user?.className ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedFaculty = FacultyConfig.normalize(user?.faculty);

    for (final controller in [_fullNameCtrl, _studentCodeCtrl]) {
      controller.addListener(_refreshFormState);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _studentCodeCtrl.dispose();
    _classNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _fullNameCtrl.text.trim().isNotEmpty &&
      _studentCodeCtrl.text.trim().isNotEmpty;

  void _refreshFormState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleSave() async {
    if (!_isFormValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'full_name': _fullNameCtrl.text.trim(),
        'student_code': _studentCodeCtrl.text.trim(),
      };

      final className = _classNameCtrl.text.trim();
      if (className.isNotEmpty) updateData['class_name'] = className;

      final faculty = FacultyConfig.normalize(_selectedFaculty);
      if (faculty != null) updateData['faculty'] = faculty;

      final phone = _phoneCtrl.text.trim();
      if (phone.isNotEmpty) updateData['phone_number'] = phone;

      final avatarImageKey = await _uploadSelectedAvatarIfNeeded();
      if (avatarImageKey != null) {
        updateData['avatar_image_key'] = avatarImageKey;
      }

      await widget.profileService?.updateProfile(updateData);

      if (mounted) {
        showAppSnackBar(
          context,
          'Cập nhật thành công!',
          backgroundColor: AppColors.primary,
        );
        widget.onSaved?.call();
      }
    } on DioException catch (error) {
      if (mounted) {
        showAppSnackBar(
          context,
          _apiErrorMessage(error),
          backgroundColor: Colors.red,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Lưu thất bại. Vui lòng thử lại.',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAvatar() async {
    if (_isSaving) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 88,
      );
      if (pickedFile == null || !mounted) return;

      setState(() {
        _selectedAvatarFile = File(pickedFile.path);
        _selectedAvatarFileName = pickedFile.name;
        _selectedAvatarContentType =
            pickedFile.mimeType ?? _contentTypeFromFileName(pickedFile.name);
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Không thể chọn ảnh. Vui lòng thử lại.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<String?> _uploadSelectedAvatarIfNeeded() async {
    final file = _selectedAvatarFile;
    if (file == null) return null;

    final profileService = widget.profileService;
    if (profileService == null) {
      throw StateError('ProfileService chưa được cấu hình.');
    }

    final fileName = _selectedAvatarFileName ?? file.uri.pathSegments.last;
    final contentType =
        _selectedAvatarContentType ?? _contentTypeFromFileName(fileName);

    final uploadTarget = await profileService.getAvatarPresignedUrl(
      fileName: fileName,
      contentType: contentType,
    );
    if (uploadTarget.presignedUrl.isEmpty || uploadTarget.objectKey.isEmpty) {
      throw StateError('Server không trả URL upload avatar hợp lệ.');
    }

    await profileService.uploadAvatarImage(
      imageFile: file,
      presignedUrl: uploadTarget.presignedUrl,
      contentType: contentType,
    );
    return uploadTarget.objectKey;
  }

  String _contentTypeFromFileName(String fileName) {
    final normalizedName = fileName.toLowerCase();
    if (normalizedName.endsWith('.png')) return 'image/png';
    if (normalizedName.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _apiErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        return firstValue.toString();
      }
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
    }

    return 'Không thể hoàn tất yêu cầu. Vui lòng thử lại.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ProfileAvatarEditor(
                        avatarUrl: widget.user?.avatarUrl,
                        avatarCacheKey: widget.user?.stableAvatarCacheKey,
                        previewFile: _selectedAvatarFile,
                        isLoading: _isSaving,
                        onTap: _pickAvatar,
                      ),
                      const SizedBox(height: 48),
                      EditProfileEmailSection(
                        email: widget.user?.email,
                        onChangeEmail: widget.onChangeEmail,
                      ),
                      const SizedBox(height: 32),
                      EditProfileFormFields(
                        fullNameController: _fullNameCtrl,
                        studentCodeController: _studentCodeCtrl,
                        classNameController: _classNameCtrl,
                        phoneController: _phoneCtrl,
                        selectedFaculty: _selectedFaculty,
                        onFacultyChanged: (value) => setState(
                          () =>
                              _selectedFaculty = FacultyConfig.normalize(value),
                        ),
                      ),
                      const SizedBox(height: 48),
                      PrimaryButton(
                        label: _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                        isLoading: _isSaving,
                        onPressed: (_isFormValid && !_isSaving)
                            ? _handleSave
                            : null,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Chỉnh sửa hồ sơ',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}
