import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/app_setting/controller/app_setting_controller.dart';
import 'package:frontend/features/app_setting/models/app_setting_state.dart';

export 'app_setting_dependencies.dart';

final appSettingControllerProvider =
    AsyncNotifierProvider<AppSettingController, AppSettingState>(
      AppSettingController.new,
    );
