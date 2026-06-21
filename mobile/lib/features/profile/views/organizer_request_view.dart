import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/profile/models/organizer_request_model.dart';
import 'package:frontend/features/profile/services/profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:image_picker/image_picker.dart';

class OrganizerRequestView extends ConsumerStatefulWidget {
  final ProfileService profileService;
  final VoidCallback? onBack;
  final VoidCallback? onSubmitted;

  const OrganizerRequestView({
    super.key,
    required this.profileService,
    this.onBack,
    this.onSubmitted,
  });

  @override
  ConsumerState<OrganizerRequestView> createState() => _OrganizerRequestViewState();
}

class _OrganizerRequestViewState extends ConsumerState<OrganizerRequestView> {
  final _reasonCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  List<OrganizerRequestModel> _requests = [];
  OrganizerRequestModel? _latestRequest;
  File? _proofFile;
  String? _proofFileName;
  String? _proofContentType;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reasonCtrl.addListener(_refreshFormState);
    _loadLatestRequest();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  bool _canSubmit(bool isOrganizer) {
    final isLocked = _latestRequest?.isPending == true || (_latestRequest?.isApproved == true && isOrganizer);
    return !_isSubmitting &&
        _proofFile != null &&
        _reasonCtrl.text.trim().isNotEmpty &&
        !isLocked;
  }

  // Validate trước khi gọi API — trả về null nếu hợp lệ, chuỗi lỗi nếu không.
  String? _validate() {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      return 'Vui lòng nhập lý do đăng ký.';
    }
    if (reason.length < 20) {
      return 'Lý do phải có ít nhất 20 ký tự (hiện tại: ${reason.length}).';
    }
    if (reason.length > 500) {
      return 'Lý do không được vượt quá 500 ký tự.';
    }

    final file = _proofFile;
    if (file == null) {
      return 'Vui lòng chọn ảnh tài liệu chứng minh.';
    }

    // Kiểm tra định dạng file
    final name = (_proofFileName ?? file.uri.pathSegments.last).toLowerCase();
    final allowedExtensions = ['.jpg', '.jpeg', '.png'];
    final hasValidExtension = allowedExtensions.any(name.endsWith);
    if (!hasValidExtension) {
      return 'Chỉ chấp nhận ảnh định dạng JPG hoặc PNG.';
    }

    // Kiểm tra kích thước file (tối đa 5MB)
    const maxBytes = 5 * 1024 * 1024;
    final fileSize = file.lengthSync();
    if (fileSize > maxBytes) {
      final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      return 'Ảnh quá lớn ($sizeMb MB). Vui lòng chọn ảnh dưới 5 MB.';
    }

    return null;
  }

  void _refreshFormState() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLatestRequest() async {
    setState(() => _isLoading = true);
    try {
      final requests = await widget.profileService.getMyOrganizerRequests();
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _latestRequest = requests.isEmpty ? null : requests.first;
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Không thể tải trạng thái yêu cầu. Vui lòng thử lại.',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProofImage() async {
    if (_isSubmitting) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );
      if (pickedFile == null || !mounted) return;

      setState(() {
        _proofFile = File(pickedFile.path);
        _proofFileName = pickedFile.name;
        _proofContentType =
            pickedFile.mimeType ?? _contentTypeFromFileName(pickedFile.name);
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Không thể chọn ảnh tài liệu. Vui lòng thử lại.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _submitRequest() async {
    final proofFile = _proofFile;
    final user = ref.read(userProfileProvider).value;
    final isOrganizer = user?.primaryRole.trim().toLowerCase() == 'organizer';
    if (!_canSubmit(isOrganizer) || proofFile == null) return;

    // Validate trước khi gọi bất kỳ API nào
    final validationError = _validate();
    if (validationError != null) {
      showAppSnackBar(context, validationError, backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final fileName = _proofFileName ?? proofFile.uri.pathSegments.last;
      final contentType =
          _proofContentType ?? _contentTypeFromFileName(fileName);

      final uploadTarget = await widget.profileService
          .getOrganizerRequestProofPresignedUrl(
            fileName: fileName,
            contentType: contentType,
          );
      if (uploadTarget.presignedUrl.isEmpty || uploadTarget.objectKey.isEmpty) {
        throw StateError('Server không trả URL upload tài liệu hợp lệ.');
      }

      await widget.profileService.uploadOrganizerRequestProof(
        proofFile: proofFile,
        presignedUrl: uploadTarget.presignedUrl,
        contentType: contentType,
      );

      final request = await widget.profileService.createOrganizerRequest(
        reason: _reasonCtrl.text.trim(),
        proofFileKey: uploadTarget.objectKey,
        proofFileName: fileName,
      );

      if (!mounted) return;
      setState(() {
        _requests = [request, ..._requests];
        _latestRequest = request;
        _proofFile = null;
        _proofFileName = null;
        _proofContentType = null;
        _reasonCtrl.clear();
      });
      showAppSnackBar(
        context,
        'Đã gửi yêu cầu. Admin sẽ xem xét tài liệu của bạn.',
        backgroundColor: AppColors.primary,
      );
      widget.onSubmitted?.call();
    } on DioException catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        _apiErrorMessage(error),
        backgroundColor: Colors.red,
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Không thể gửi yêu cầu. Vui lòng thử lại.',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _contentTypeFromFileName(String fileName) {
    final normalizedName = fileName.toLowerCase();
    if (normalizedName.endsWith('.png')) return 'image/png';
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
    final user = ref.watch(userProfileProvider).value;
    final isOrganizer = user?.primaryRole.trim().toLowerCase() == 'organizer';

    final isPending = _latestRequest?.isPending == true;
    final isApproved = _latestRequest?.isApproved == true;
    final isLocked = isPending || (isApproved && isOrganizer);

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_latestRequest != null)
                        _RequestStatusCard(request: _latestRequest!),
                      if (!_isLoading) ...[
                        const SizedBox(height: 24),
                        GlassInputField(
                          label: 'Lý do đăng ký',
                          placeholder:
                              'Mô tả ngắn về nhu cầu tổ chức sự kiện của bạn',
                          controller: _reasonCtrl,
                          maxLines: 5,
                          readOnly: isLocked,
                        ),
                        const SizedBox(height: 6),
                        // Character counter
                        Builder(builder: (context) {
                          final len = _reasonCtrl.text.trim().length;
                          final isShort = len > 0 && len < 20;
                          final isOver = len > 500;
                          final color = isOver
                              ? AppColors.error
                              : isShort
                              ? Colors.orange
                              : AppColors.onSurfaceVariant;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (isShort)
                                Text(
                                  'Tối thiểu 20 ký tự',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: Colors.orange),
                                )
                              else
                                const SizedBox.shrink(),
                              Text(
                                '$len / 500',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: color),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 20),
                        _ProofPickerCard(
                          proofFile: _proofFile,
                          proofFileName: _proofFileName,
                          enabled: !isLocked && !_isSubmitting,
                          onTap: _pickProofImage,
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: (isApproved && isOrganizer)
                              ? 'Đã là người tổ chức'
                              : isPending
                                  ? 'Yêu cầu đang chờ duyệt'
                                  : 'Gửi yêu cầu',
                          icon: Icons.send,
                          isLoading: _isSubmitting,
                          onPressed: _canSubmit(isOrganizer) ? _submitRequest : null,
                        ),
                        // ── Lịch sử yêu cầu ──────────────────────────────
                        if (_requests.isNotEmpty) ...[
                          const SizedBox(height: 36),
                          Row(
                            children: [
                              const Icon(
                                Icons.history,
                                size: 18,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lịch sử yêu cầu',
                                style: AppTextStyles.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _requests.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) =>
                                _RequestHistoryItem(request: _requests[index]),
                          ),
                        ],
                        const SizedBox(height: 120),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          GlassTopBar(
            title: 'Yêu cầu trở thành người tổ chức',
            leadingIcon: Icons.arrow_back,
            onLeadingTap: widget.onBack,
          ),
        ],
      ),
    );
  }
}

// ── Status Card (yêu cầu mới nhất, hiển thị đầu trang) ──────────────────────

class _RequestStatusCard extends StatelessWidget {
  final OrganizerRequestModel request;

  const _RequestStatusCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = request.isApproved
        ? AppColors.primary
        : request.isRejected
        ? AppColors.error
        : AppColors.onSurfaceVariant;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request.statusLabel,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(request.reason, style: AppTextStyles.bodyMedium),
          ],
          if (request.reviewNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Ghi chú admin: ${request.reviewNote}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── History Item (từng dòng trong danh sách lịch sử) ────────────────────────

class _RequestHistoryItem extends StatelessWidget {
  final OrganizerRequestModel request;

  const _RequestHistoryItem({required this.request});

  Color get _statusColor {
    if (request.isApproved) return const Color(0xFF22C55E);
    if (request.isRejected) return AppColors.error;
    if (request.isCancelled) return AppColors.onSurfaceVariant;
    return const Color(0xFFF59E0B); // pending — amber
  }

  IconData get _statusIcon {
    if (request.isApproved) return Icons.check_circle_outline;
    if (request.isRejected) return Icons.cancel_outlined;
    if (request.isCancelled) return Icons.remove_circle_outline;
    return Icons.schedule;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon circle
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.statusLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (request.createdAt != null)
                      Text(
                        _formatDate(request.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                if (request.reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    request.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                if (request.proofFileName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          request.proofFileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (request.reviewNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ghi chú: ${request.reviewNote}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Proof Picker Card ────────────────────────────────────────────────────────

class _ProofPickerCard extends StatelessWidget {
  final File? proofFile;
  final String? proofFileName;
  final bool enabled;
  final VoidCallback onTap;

  const _ProofPickerCard({
    required this.proofFile,
    required this.proofFileName,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: proofFile == null
                  ? const Icon(
                      Icons.upload_file,
                      color: AppColors.primary,
                      size: 32,
                    )
                  : Image.file(proofFile!, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proofFileName ?? 'Chọn ảnh tài liệu chứng minh',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ảnh thẻ sinh viên, giấy xác nhận CLB hoặc tài liệu liên quan.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
