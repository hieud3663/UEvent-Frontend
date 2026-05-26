import 'package:frontend/features/app_setting/models/app_setting_state.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  const AppVersionService();

  Future<AppVersionInfo> getVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersionInfo(version: info.version, buildNumber: info.buildNumber);
  }
}
