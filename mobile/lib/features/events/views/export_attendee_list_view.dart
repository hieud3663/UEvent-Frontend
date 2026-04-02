// File: lib/features/events/views/export_attendee_list_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/events/models/export_config_model.dart';
import 'package:frontend/core/widgets/glass_radio_card.dart';
import 'package:frontend/core/widgets/glass_checkbox_tile.dart';

class ExportAttendeeListView extends StatefulWidget {
  final VoidCallback? onClose;
  final ValueChanged<ExportConfigModel>? onDownloadReport;

  const ExportAttendeeListView({
    super.key,
    this.onClose,
    this.onDownloadReport,
  });

  @override
  State<ExportAttendeeListView> createState() => _ExportAttendeeListViewState();
}

class _ExportAttendeeListViewState extends State<ExportAttendeeListView> {
  late ExportConfigModel _config;

  @override
  void initState() {
    super.initState();
    _config = ExportConfigModel.initial();
  }

  void _handleFormatChange(ExportFormat format) {
    setState(() {
      _config = _config.copyWith(format: format);
    });
  }

  void _handleSelectAll() {
    setState(() {
      _config = _config.selectAll();
    });
  }

  void _handleDownload() {
    if (widget.onDownloadReport != null) {
      widget.onDownloadReport!(_config);
    } else {
      // Provide visual feedback if no callback is supplied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading report...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The screen has a main background
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Spacing under the fixed GlassTopBar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              // ── Format Selection ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Format',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GlassRadioCard<ExportFormat>(
                              value: ExportFormat.csv,
                              groupValue: _config.format,
                              onChanged: _handleFormatChange,
                              icon: Icons.table_chart_outlined,
                              title: 'CSV',
                              subtitle: 'FOR EXCEL',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GlassRadioCard<ExportFormat>(
                              value: ExportFormat.pdf,
                              groupValue: _config.format,
                              onChanged: _handleFormatChange,
                              icon: Icons.picture_as_pdf_outlined,
                              title: 'PDF',
                              subtitle: 'VISUAL REPORT',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Fields Selection ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Column(
                    children: [
                      SectionHeader(
                        title: 'Fields to Include',
                        actionText: 'Select All',
                        onActionTap: _handleSelectAll,
                      ),
                      const SizedBox(height: 16),
                      GlassCheckboxTile(
                        value: _config.includeName,
                        onChanged: (val) => setState(() =>
                            _config = _config.copyWith(includeName: val ?? false)),
                        title: 'Attendee Name',
                        icon: Icons.person_outline,
                      ),
                      GlassCheckboxTile(
                        value: _config.includeId,
                        onChanged: (val) => setState(() =>
                            _config = _config.copyWith(includeId: val ?? false)),
                        title: 'Ticket ID',
                        icon: Icons.confirmation_number_outlined,
                      ),
                      GlassCheckboxTile(
                        value: _config.includeEmail,
                        onChanged: (val) => setState(() =>
                            _config = _config.copyWith(includeEmail: val ?? false)),
                        title: 'Email Address',
                        icon: Icons.email_outlined,
                      ),
                      GlassCheckboxTile(
                        value: _config.includeStatus,
                        onChanged: (val) => setState(() =>
                            _config = _config.copyWith(includeStatus: val ?? false)),
                        title: 'Check-in Status',
                        icon: Icons.how_to_reg,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),

          // ── Fixed Bottom Button Area ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppConstants.pagePaddingH,
                right: AppConstants.pagePaddingH,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16, // SafeArea equivalent
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: PrimaryButton(
                label: 'Download Report',
                onPressed: _handleDownload,
                icon: Icons.download_rounded,
              ),
            ),
          ),

          // ── Fixed Top Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Export Attendee List',
              leadingIcon: Icons.close,
              onLeadingTap: widget.onClose ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
