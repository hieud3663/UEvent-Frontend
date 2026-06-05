import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class SplashProgress {
  final double value;
  final String label;

  const SplashProgress({required this.value, required this.label});

  factory SplashProgress.initial() =>
      const SplashProgress(value: 0.05, label: 'Đang khởi động ứng dụng');
}

class SplashView extends StatefulWidget {
  final VoidCallback? onInitializationComplete;
  final ValueListenable<SplashProgress> progressListenable;

  const SplashView({
    super.key,
    required this.progressListenable,
    this.onInitializationComplete,
  });

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    widget.onInitializationComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glow shapes without runtime blur to keep startup smooth.
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glassmorphic Logo
                    Container(
                      width: 112,
                      height: 112,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.event_available,
                          size: 60,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Titles
                    Text(
                      'UEvents',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ứng dụng quản lý sự kiện UTC2',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 32,
              right: 32,
              child: ValueListenableBuilder<SplashProgress>(
                valueListenable: widget.progressListenable,
                builder: (context, progress, _) {
                  final safeValue = progress.value.clamp(0.0, 1.0);
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            progress.label.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            '${(safeValue * 100).toInt()}%',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.black.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 6,
                              width: double.infinity,
                              color: Colors.black.withValues(alpha: 0.05),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeOut,
                                  width: constraints.maxWidth * safeValue,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Footer text
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                'UCODE TEAM • 2026',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.black.withValues(alpha: 0.3),
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
