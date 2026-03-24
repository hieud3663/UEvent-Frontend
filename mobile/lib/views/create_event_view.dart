// File: lib/views/create_event_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';
import '../widgets/glass_top_bar.dart';
import '../widgets/glass_input_field.dart';
import '../widgets/primary_button.dart';

class CreateEventView extends StatefulWidget {
  final VoidCallback? onBack;
  const CreateEventView({super.key, this.onBack});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  bool _isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          _buildBackgroundBlobs(),
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: GlassTopBar(
                  title: 'Create Event',
                  titleStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                  leadingIcon: Icons.arrow_back_ios,
                  trailingIcon: Icons.more_horiz,
                  onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCoverUpload(),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildForm(),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildBottomCta(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(children: [
      GlassInputField(label: 'Event Name', placeholder: 'Summer Rooftop Gala'),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: GlassInputField(label: 'Start Date', placeholder: 'Oct 24, 2023', leadingIcon: Icons.calendar_today)),
        const SizedBox(width: 16),
        Expanded(child: GlassInputField(label: 'Start Time', placeholder: '07:00 PM', leadingIcon: Icons.schedule)),
      ]),
      const SizedBox(height: 16),
      GlassInputField(label: 'Location', leadingIcon: Icons.location_on, child: Row(children: [
        const Icon(Icons.location_on, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text('UTC2 Conference Room A', style: AppTextStyles.bodyLarge)),
        const Icon(Icons.expand_more, color: AppColors.navInactive),
      ])),
      const SizedBox(height: 16),
      GlassInputField(label: 'Number of guests', placeholder: 'e.g. 120', leadingIcon: Icons.group, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildVisibilityToggle(),
      const SizedBox(height: 16),
      GlassInputField(label: 'Description', placeholder: 'Tell everyone about your event...', maxLines: 4),
    ]);
  }

  Widget _buildCoverUpload() {
    return AspectRatio(aspectRatio: 16 / 9, child: Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFDCDCDF), width: 2), color: Colors.white.withValues(alpha: 0.3)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.add_photo_alternate, color: AppColors.onPrimaryDark, size: 24)),
        const SizedBox(height: 12),
        Text('Add Event Cover', style: AppTextStyles.titleSmall),
        const SizedBox(height: 4),
        Text('16:9 ASPECT RATIO RECOMMENDED', style: AppTextStyles.inputLabel.copyWith(letterSpacing: 1.5)),
      ]),
    ));
  }

  Widget _buildVisibilityToggle() {
    return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
    ), child: Row(children: [
      Expanded(child: GestureDetector(onTap: () => setState(() => _isPublic = true), child: AnimatedContainer(
        duration: AppConstants.animNormal, padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: _isPublic ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: Text('PUBLIC', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.5, color: _isPublic ? AppColors.onPrimaryDark : AppColors.navInactive)),
      ))),
      Expanded(child: GestureDetector(onTap: () => setState(() => _isPublic = false), child: AnimatedContainer(
        duration: AppConstants.animNormal, padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: !_isPublic ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: Text('PRIVATE', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.5, color: !_isPublic ? AppColors.onPrimaryDark : AppColors.navInactive)),
      ))),
    ]));
  }

  Widget _buildBottomCta() {
    return Positioned(bottom: 0, left: 0, right: 0, child: Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
        const Color(0xFFF2F2F7).withValues(alpha: 0.0), const Color(0xFFF2F2F7).withValues(alpha: 0.8), const Color(0xFFF2F2F7),
      ])),
      child: PrimaryButton(label: 'Create Event', icon: Icons.rocket_launch, onPressed: () {}),
    ));
  }

  Widget _buildBackgroundBlobs() {
    return Positioned.fill(child: IgnorePointer(child: Stack(children: [
      Positioned(top: -50, right: -50, child: Container(width: 300, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1)))),
      Positioned(top: 200, left: -50, child: Container(width: 250, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withValues(alpha: 0.1)))),
    ])));
  }
}
