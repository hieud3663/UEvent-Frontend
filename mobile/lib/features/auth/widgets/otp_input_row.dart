import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';

class OtpInputRow extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;

  const OtpInputRow({
    super.key,
    this.length = 6,
    this.onCompleted,
  });

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Paste: phân phối từng ký tự vào từng ô
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length).clamp(0, widget.length - 1);
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Backspace
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Kiểm tra đủ 6 số — mỗi ô phải có đúng 1 ký tự
    final allFilled = _controllers.every((c) => c.text.isNotEmpty);
    if (allFilled) {
      final code = _controllers.map((c) => c.text).join();
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '-',
                  hintStyle: TextStyle(color: AppColors.outline),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: const BorderSide(color: Colors.transparent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: const BorderSide(color: Colors.transparent, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (value) => _onDigitChanged(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}

