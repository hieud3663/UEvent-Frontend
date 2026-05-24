// File: lib/features/event_shared/widgets/share_social_row.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Horizontally scrollable row of social app icons for sharing.
class ShareSocialRow extends StatelessWidget {
  const ShareSocialRow({super.key});

  static const _socials = [
    _SocialApp(
      label: 'Instagram',
      gradientColors: [Color(0xFF7B2FF7), Color(0xFFE91E8C)],
      iconUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAufR1ThEqhNrb3wNbwYsjTkGntGE4vRCH005s1BBYJo56v-L3KjCMvQSTqLQdj02gBXOdUxb31wzOj-SprWChHQ1-sN4QybuUyrGCihdpGLSYUQPZz4uRU0bX39g6xU8_Xv7EuAAjIoyXiXRd6EaXdJhs-mWU_E1Q2ucsGfjzIcdbhJdS9hPNCePUqLI1VUPCzPH5WGAPZAV9U6figmaOljth8lyrTBnoS1HczyccDyLjN8BdWmFraxBx2IpRQ1KKoTI11b2H4z_M',
    ),
    _SocialApp(
      label: 'Facebook',
      solidColor: Color(0xFF1877F2),
      iconUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDPM3oamGKwc4M5EWf0NM7qRHHhKG0kQkZgHYi8UAN7P_WxV-NwUOgjR14uQrZw9v1ky7AIxNEg99MuBjtEdC9sTcUWABX3m63hj-pdP5UhYjn0mWMrlwyjkWKASOHQDGghFHcx4kXwM3I2sq1657LIlEWQXZGVx2o0eoMngJZa5oyUgz5e1lnjfBysy8heqjxoMDp9d2CZN90qbr-htLjOloa2mnL_Kg4e0VxHIazLNZas7O2x_AWSAlXVJ8PTg7yeBJOESQk5sNA',
    ),
    _SocialApp(
      label: 'WhatsApp',
      solidColor: Color(0xFF25D366),
      iconUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuACp-E15b4i_hzTYOQdOBZwmZJg97FRJluKDljRN_Ldb3iGczKbl6F12_Q3JzyPrjxZEXA5GlPrWK3W7g8fWpCZPDC6gFJiNbbjj3yOnNi9IbY4CIMCGzuHLiW2xb1qT3nCfdcPE0Ly04_mB3lPbpOqVs0xCJdrtoUWnjAQKxBz22ldA1H6HX-6zcagDBcuxSP75U6aC5KNnh05cGHYpHqR470IV24gKZDz5Era4UE8wFFXLRUwFDUi9ypQqhUt5OUnLT5gdQRmiEM',
    ),
    _SocialApp(
      label: 'Messages',
      solidColor: Color(0xFF101322),
      iconUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXVuYVCi9i3-BDISf5ujCH0maCWCMVQ_szyEA2pcv4c-zK_tIutKI6FTF3kFX0JBCLLWxIt64_m4ra7Lb-v1dba1mt_OoLuV3KQhA4AzLug5fh-0_ptqUmXsHq7btO1QQBfj8opMySICVj9H_H6sT2cz5qLoruYTGtIBU5m54lamlFVIp0fXkmFE0K_K_7QLtTDBimXa_Bu4D9bQGlvGFJ81qQx-aN_uTgI7wla4tRiGR_1q7afmLsnZEMpJu_-w1O0ILEK7knkL8',
    ),
    _SocialApp(
      label: 'Telegram',
      solidColor: Color(0xFF0EA5E9),
      iconUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAduGe8ubT4Ahr-mRjS-Rt6Pd14sg_MugAGcQkShSWCvl5TLOsJNZkQ2E1IDPxA-1FlrQF-TTbuN0YyYUKhEnZ19_4EWmtO0MaH8xGuCRKYariqrWu_gA2K1a_WNM1skPuK9FJ544id9ymmZ2adO1IUk2Bh2OBNTc2RJdPg02tXnjgfG4FL65_Ax0F4bOfbCMDOcemFY3CHkn8Qh7AQD7s4l-cmRi4fB1_jpyXx3f6fD631YJiYMCZKRiKDppU1ZvQF9PYeub2UcTk',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      itemCount: _socials.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, i) => _SocialItem(app: _socials[i]),
    );
  }
}

class _SocialApp {
  final String label;
  final String iconUrl;
  final Color? solidColor;
  final List<Color>? gradientColors;

  const _SocialApp({
    required this.label,
    required this.iconUrl,
    this.solidColor,
    this.gradientColors,
  });
}

class _SocialItem extends StatelessWidget {
  final _SocialApp app;

  const _SocialItem({required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: app.solidColor,
            gradient: app.gradientColors != null
                ? LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: app.gradientColors!,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: (app.solidColor ?? app.gradientColors!.first).withValues(
                  alpha: 0.3,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.network(
              app.iconUrl,
              fit: BoxFit.contain,
              cacheWidth: 128,
              errorBuilder: (_, _, _) => const SizedBox(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          app.label,
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
