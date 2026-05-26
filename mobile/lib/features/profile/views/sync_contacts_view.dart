import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class SyncContactsView extends StatefulWidget {
  final VoidCallback? onBack;

  const SyncContactsView({super.key, this.onBack});

  @override
  State<SyncContactsView> createState() => _SyncContactsViewState();
}

class _SyncContactsViewState extends State<SyncContactsView> {
  var _isLoading = false;
  var _hasLoaded = false;
  String? _errorMessage;
  List<_ContactSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      final granted =
          permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited;
      if (!granted) {
        if (!mounted) return;
        setState(() {
          _hasLoaded = true;
          _isLoading = false;
          _errorMessage =
              'UEvents chưa được cấp quyền đọc danh bạ trên thiết bị này.';
          _suggestions = const [];
        });
        return;
      }

      final contacts = await FlutterContacts.getAll(
        properties: const {
          ContactProperty.name,
          ContactProperty.phone,
          ContactProperty.email,
        },
      );
      final suggestions =
          contacts
              .map(_ContactSuggestion.fromContact)
              .whereType<_ContactSuggestion>()
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

      if (!mounted) return;
      setState(() {
        _hasLoaded = true;
        _isLoading = false;
        _suggestions = suggestions.take(50).toList(growable: false);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLoaded = true;
        _isLoading = false;
        _errorMessage =
            'Không thể đọc danh bạ lúc này. Vui lòng kiểm tra quyền hệ thống và thử lại.';
        _suggestions = const [];
      });
    }
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildPrivacyNote(),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: _hasLoaded ? 'Đọc lại danh bạ' : 'Đọc danh bạ',
                        icon: Icons.contacts,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _loadContacts,
                      ),
                      const SizedBox(height: 24),
                      _buildBody(),
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
              title: 'Đọc danh bạ',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(
                Icons.connect_without_contact,
                size: 64,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Gợi ý bạn bè từ danh bạ',
          style: AppTextStyles.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'UEvents chỉ đọc danh bạ trên thiết bị để hiển thị gợi ý kết nối. Dữ liệu danh bạ không được tải lên máy chủ.',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPrivacyNote() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chỉ tên, số điện thoại hoặc email có trong danh bạ được dùng để dựng danh sách gợi ý cục bộ trong phiên hiện tại.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && !_hasLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _StateMessage(
        icon: Icons.error_outline,
        title: 'Chưa thể đọc danh bạ',
        message: _errorMessage!,
      );
    }

    if (!_hasLoaded) {
      return const SizedBox.shrink();
    }

    if (_suggestions.isEmpty) {
      return const _StateMessage(
        icon: Icons.person_search,
        title: 'Chưa có gợi ý',
        message:
            'Danh bạ hiện chưa có liên hệ kèm số điện thoại hoặc email để hiển thị.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gợi ý (${_suggestions.length})',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.black.withValues(alpha: 0.05),
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    suggestion.initials,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  suggestion.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  suggestion.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  suggestion.kind == _ContactSuggestionKind.email
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                  color: AppColors.outline,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _ContactSuggestionKind { phone, email }

class _ContactSuggestion {
  const _ContactSuggestion({
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.kind,
  });

  final String name;
  final String subtitle;
  final String initials;
  final _ContactSuggestionKind kind;

  static _ContactSuggestion? fromContact(Contact contact) {
    final name = (contact.displayName ?? '').trim();
    if (name.isEmpty) return null;

    final phone = contact.phones
        .map(
          (phone) => (phone.normalizedNumber ?? '').trim().isNotEmpty
              ? phone.normalizedNumber!.trim()
              : phone.number.trim(),
        )
        .where((number) => number.isNotEmpty)
        .firstOrNull;
    if (phone != null) {
      return _ContactSuggestion(
        name: name,
        subtitle: phone,
        initials: _initials(name),
        kind: _ContactSuggestionKind.phone,
      );
    }

    final email = contact.emails
        .map((email) => email.address.trim())
        .where((address) => address.isNotEmpty)
        .firstOrNull;
    if (email == null) return null;

    return _ContactSuggestion(
      name: name,
      subtitle: email,
      initials: _initials(name),
      kind: _ContactSuggestionKind.email,
    );
  }

  static String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
