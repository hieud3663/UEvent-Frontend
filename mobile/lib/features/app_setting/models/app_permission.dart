enum AppPermissionKey {
  notification,
  location,
  contacts,
  camera,
  photos;

  String get label {
    return switch (this) {
      AppPermissionKey.notification => 'Thông báo',
      AppPermissionKey.location => 'Vị trí',
      AppPermissionKey.contacts => 'Danh bạ',
      AppPermissionKey.camera => 'Camera',
      AppPermissionKey.photos => 'Ảnh và thư viện',
    };
  }
}

enum AppPermissionStatus {
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional;

  String get label {
    return switch (this) {
      AppPermissionStatus.denied => 'Chưa cấp quyền',
      AppPermissionStatus.granted => 'Được phép',
      AppPermissionStatus.restricted => 'Bị giới hạn',
      AppPermissionStatus.limited => 'Được phép một phần',
      AppPermissionStatus.permanentlyDenied => 'Bị từ chối',
      AppPermissionStatus.provisional => 'Được phép tạm thời',
    };
  }

  bool get canOpenSystemSettings {
    return this == AppPermissionStatus.permanentlyDenied ||
        this == AppPermissionStatus.restricted;
  }
}

class AppPermissionInfo {
  final AppPermissionKey key;
  final AppPermissionStatus status;

  const AppPermissionInfo({required this.key, required this.status});
}
