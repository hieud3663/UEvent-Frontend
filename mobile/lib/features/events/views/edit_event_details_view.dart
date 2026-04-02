// File: lib/features/events/views/edit_event_details_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/segmented_toggle.dart';
import 'package:frontend/features/events/widgets/edit_hero_image_picker.dart';

class EditEventDetailsView extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;

  const EditEventDetailsView({
    super.key,
    this.onBack,
    this.onSave,
    this.onDelete,
  });

  @override
  State<EditEventDetailsView> createState() => _EditEventDetailsViewState();
}

class _EditEventDetailsViewState extends State<EditEventDetailsView> {
  int _visibilityIndex = 0; // 0 for Public, 1 for Private
  String _selectedRoom = 'UTC2 - Grand Hall';
  
  // Controllers for mock data
  final _nameCtrl = TextEditingController(text: 'Amber Glass Design Summit 2024');
  final _startCtrl = TextEditingController(text: '2024-11-15 09:00');
  final _endCtrl = TextEditingController(text: '2024-11-15 18:00');
  final _capacityCtrl = TextEditingController(text: '250');
  final _descCtrl = TextEditingController(text: '''# The Ethereal Concierge: Design 2024

Join us for a deep dive into **iOS Glassmorphism** and the future of ambient computing. We will cover:
- Surface Hierarchy
- Tonal Layering
- The No-Line Rule

*Lunch will be provided in UTC2 Grand Hall.*''');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _capacityCtrl.dispose();
    _descCtrl.dispose();
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Top bar spacing
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // ── Hero Image Picker ──
                    EditHeroImagePicker(
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBOzntXnVresl2Q7f7k5kom1aVHvE-UQnTwVvcQMODurtQ127FvsV2bD-i_Qz8uzTOitXV1iKuf_CjIr5DPvZchh9v7zcsddJv8CbLuGU0iT2VBGAZ1dRsdzG7MiCdMxi5LMGXGcd8u-iqccVUtWSJjW7Pu2-oDQRES9o3LXweWjFQZEN6PDVSA8Hes98t2EtK4GGf7VZMa0EqkdTWvzCyCzhlUpew6-ltwFWCbMt4LyNcNiLt4USq_wpUF1eks1VdVhDX8vfbnfiU',
                      onTap: () {
                        // Mock change cover
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Image Gallery...')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Form Area ──
                    
                    // Event Name
                    GlassInputField(
                      label: 'Event Name',
                      controller: _nameCtrl,
                    ),
                    const SizedBox(height: 16),

                    // Date & Time Grid
                    Row(
                      children: [
                        Expanded(
                          child: GlassInputField(
                            label: 'Start Date & Time',
                            leadingIcon: Icons.calendar_today,
                            controller: _startCtrl,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassInputField(
                            label: 'End Date & Time',
                            leadingIcon: Icons.event_busy,
                            controller: _endCtrl,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location & Capacity Grid
                    Row(
                      children: [
                        Expanded(
                          child: GlassInputField(
                            label: 'Location (Room)',
                            leadingIcon: Icons.location_on,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRoom,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                style: AppTextStyles.bodyLarge,
                                dropdownColor: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(16),
                                items: [
                                  'UTC2 - Grand Hall',
                                  'UTC2 - Seminar Room A',
                                  'UTC2 - Workshop Hub',
                                  'Virtual Room 01'
                                ].map((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRoom = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassInputField(
                            label: 'Max Capacity',
                            leadingIcon: Icons.group,
                            controller: _capacityCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visibility Toggle
                    GlassInputField(
                      label: 'Visibility',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _visibilityIndex == 0 ? 'Public Event' : 'Private Event',
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                          ),
                          SegmentedToggle(
                            options: const ['Public', 'Private'],
                            selectedIndex: _visibilityIndex,
                            onSelect: (index) => setState(() => _visibilityIndex = index),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Area (with markdown toolbar)
                    GlassInputField(
                      label: 'Description (Markdown Supported)',
                      labelTrailing: Row(
                        children: [
                          _buildToolbarIcon(Icons.format_bold),
                          const SizedBox(width: 8),
                          _buildToolbarIcon(Icons.format_italic),
                          const SizedBox(width: 8),
                          _buildToolbarIcon(Icons.link),
                        ],
                      ),
                      maxLines: 8,
                      controller: _descCtrl,
                    ),
                    const SizedBox(height: 32),

                    // Delete Action
                    Center(
                      child: TextButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        label: Text(
                          'Cancel and Delete Event',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error.withValues(alpha: 0.1), 
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Update Button
                    PrimaryButton(
                      label: 'Update Event Details',
                      onPressed: widget.onSave ?? () {},
                    ),
                    const SizedBox(height: 48),

                  ]),
                ),
              ),
            ],
          ),

          // ── Fixed Top Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Edit Event',
              leadingIcon: Icons.arrow_back,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: widget.onSave,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.save, size: 20, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGyz__EdRe2QUhLlU1zYft3UT2E1ibEQqIVExS9A37iKs-yJ3I-iMio-vgzA9EMFdbsuB1-MPFgEPZ4gO-PrWXq_m7ScP8iAeFGfwdyQCuR5ppvdagZhL9JghAUC6b-EdfnsgfoLN8nhcjOmcseUQM-2vICTZByEvoChW9t3iILEnmQHSi61-BRJ_sY-GREM8BwCkG9sXNKADbcNPZyq2FwVtO-CXHX5ythd0tKGvAN9nYbKgDyTeGGC0Sw35X3fdWkPFzKSjYQtc',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Icon(
        icon,
        size: 18,
        color: AppColors.navInactive.withValues(alpha: 0.7),
      ),
    );
  }
}
