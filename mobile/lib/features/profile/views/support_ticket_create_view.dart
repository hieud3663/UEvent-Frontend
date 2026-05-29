import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';

typedef SubmitSupportTicket =
    Future<SupportTicketModel> Function(String subject, String description);

class SupportTicketCreateView extends StatefulWidget {
  final SubmitSupportTicket onSubmit;

  const SupportTicketCreateView({super.key, required this.onSubmit});

  @override
  State<SupportTicketCreateView> createState() =>
      _SupportTicketCreateViewState();
}

class _SupportTicketCreateViewState extends State<SupportTicketCreateView> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 112)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Liên hệ hỗ trợ', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Mô tả ngắn gọn vấn đề để đội vận hành có thể phản hồi.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlassInputField(
                        label: 'Tiêu đề',
                        placeholder: 'Nhập tiêu đề yêu cầu',
                        controller: _subjectController,
                      ),
                      const SizedBox(height: 16),
                      GlassInputField(
                        label: 'Nội dung',
                        placeholder: 'Mô tả vấn đề bạn cần hỗ trợ',
                        controller: _descriptionController,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Gửi yêu cầu hỗ trợ',
                        isLoading: _submitting,
                        onPressed: _submitting ? null : _submit,
                      ),
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
              title: 'Liên hệ hỗ trợ',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (subject.isEmpty || description.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập tiêu đề và nội dung.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final ticket = await widget.onSubmit(subject, description);
      if (mounted) Navigator.of(context).pop(ticket);
    } on DioException catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        error.message ?? 'Không thể gửi yêu cầu hỗ trợ. Vui lòng thử lại.',
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Không thể gửi yêu cầu hỗ trợ. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
