import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('vi'));
  }

  String get loginSubtitle => _text('loginSubtitle');
  String get preferredLogin => _text('preferredLogin');
  String get studentEmail => _text('studentEmail');
  String get passkeyLogin => _text('passkeyLogin');
  String get emailContinue => _text('emailContinue');
  String get sendingCode => _text('sendingCode');
  String get googleContinue => _text('googleContinue');
  String get openingGoogle => _text('openingGoogle');
  String get or => _text('or');
  String get passkeyUnavailable => _text('passkeyUnavailable');

  String _text(String key) {
    final languageCode = locale.languageCode == 'en' ? 'en' : 'vi';
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['vi']![key]!;
  }

  static const _localizedValues = {
    'vi': {
      'loginSubtitle': 'Đăng nhập để tiếp tục',
      'preferredLogin': 'ĐĂNG NHẬP ƯU TIÊN',
      'studentEmail': 'EMAIL SINH VIÊN',
      'passkeyLogin': 'Đăng nhập bằng Passkey',
      'emailContinue': 'Tiếp tục với Email',
      'sendingCode': 'Đang gửi mã...',
      'googleContinue': 'Tiếp tục với Google',
      'openingGoogle': 'Đang mở Google...',
      'or': 'HOẶC',
      'passkeyUnavailable': 'Passkey chưa khả dụng trên thiết bị này.',
    },
    'en': {
      'loginSubtitle': 'Sign in to continue',
      'preferredLogin': 'PREFERRED SIGN-IN',
      'studentEmail': 'STUDENT EMAIL',
      'passkeyLogin': 'Sign in with Passkey',
      'emailContinue': 'Continue with Email',
      'sendingCode': 'Sending code...',
      'googleContinue': 'Continue with Google',
      'openingGoogle': 'Opening Google...',
      'or': 'OR',
      'passkeyUnavailable': 'Passkey is not available on this device.',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return const {'vi', 'en'}.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
