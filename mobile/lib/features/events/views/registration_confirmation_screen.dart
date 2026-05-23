// File: lib/features/events/views/registration_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_checkbox_tile.dart';
import 'package:frontend/core/widgets/glass_dropdown_field.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/event_registration_model.dart';
import 'package:frontend/features/events/models/registration_field_model.dart';

class RegistrationConfirmationScreen extends StatefulWidget {
  final EventModel event;
  final Future<EventRegistrationModel?> Function(
    List<EventRegistrationAnswerModel> answers,
  )?
  onConfirm;
  final VoidCallback? onCancel;

  const RegistrationConfirmationScreen({
    super.key,
    required this.event,
    this.onConfirm,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required EventModel event,
    Future<EventRegistrationModel?> Function(
      List<EventRegistrationAnswerModel> answers,
    )?
    onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => RegistrationConfirmationScreen(
        event: event,
        onConfirm: onConfirm,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<RegistrationConfirmationScreen> createState() =>
      _RegistrationConfirmationScreenState();
}

class _RegistrationConfirmationScreenState
    extends State<RegistrationConfirmationScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectValues = {};
  bool _agreedToTerms = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final field in widget.event.registrationFields) {
      _controllers[field.fieldKey] = TextEditingController();
      if (field.options.isNotEmpty) {
        _selectValues[field.fieldKey] = field.options.first;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.event_available,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text('Event Registration', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Register for '),
                    TextSpan(
                      text: widget.event.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.event.registrationFields.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...widget.event.registrationFields.map(_buildField),
              ],
              const SizedBox(height: 16),
              GlassCheckboxTile(
                value: _agreedToTerms,
                onChanged: (value) =>
                    setState(() => _agreedToTerms = value ?? false),
                title: 'I agree to the Terms of Participation',
                icon: Icons.verified_user_outlined,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Confirm Registration',
                icon: Icons.arrow_forward,
                isLoading: _isSubmitting,
                onPressed: _agreedToTerms ? _submit : null,
              ),
              const SizedBox(height: 12),
              Text(
                _deadlineText(),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(RegistrationFieldModel field) {
    final label = field.isRequired ? '${field.label} *' : field.label;
    final options = field.options;

    if (field.fieldType == 'select' && options.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassDropdownField<String>(
          label: label,
          value: _selectValues[field.fieldKey] ?? options.first,
          items: options
              .map(
                (option) =>
                    GlassDropdownItem<String>(value: option, label: option),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectValues[field.fieldKey] = value);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassInputField(
        label: label,
        placeholder: field.label,
        controller: _controllers[field.fieldKey],
      ),
    );
  }

  Future<void> _submit() async {
    final validationError = _validateRequiredFields();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final registration = await widget.onConfirm?.call(_answers());
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      if (registration != null) {
        Navigator.of(context).pop();
      } else {
        setState(
          () => _errorMessage = 'Không đăng ký được sự kiện. Vui lòng thử lại.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Không đăng ký được sự kiện. Vui lòng thử lại.';
      });
    }
  }

  String? _validateRequiredFields() {
    for (final field in widget.event.registrationFields) {
      if (!field.isRequired) continue;
      final value = _fieldValue(field).trim();
      if (value.isEmpty) return 'Vui lòng nhập ${field.label}.';
    }

    return null;
  }

  List<EventRegistrationAnswerModel> _answers() {
    return widget.event.registrationFields
        .map(
          (field) => EventRegistrationAnswerModel(
            fieldId: field.fieldKey,
            value: _fieldValue(field),
          ),
        )
        .where((answer) => answer.value.trim().isNotEmpty)
        .toList();
  }

  String _fieldValue(RegistrationFieldModel field) {
    if (field.fieldType == 'select') {
      return _selectValues[field.fieldKey] ?? '';
    }

    return _controllers[field.fieldKey]?.text ?? '';
  }

  String _deadlineText() {
    final closeAt = widget.event.registrationCloseAt;
    if (closeAt == null) return 'Seats are limited.';
    return 'Registration closes at ${closeAt.toLocal()}. Seats are limited.';
  }
}
