// File: lib/mock/mock_user_data.dart

/// Mock user profile data for UserProfileView.
class MockUserData {
  MockUserData._();

  static const String name = 'Nguyễn Văn A';
  static const String studentId = 'MSSV: 21520000';
  static const String faculty = 'Khoa Công nghệ Thông tin';
  static const String className = 'Lớp: CS2021';
  static const String avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAyErzTlXp9zTUqK8e5HiJWesNTOfm10_r_PwBXepemKvp1azWgTJAsFJJ7snljJsrTQulkOtMR9kLjkqonSvAXShUrveuMti8KGM5D-f6OVJouUop9N2kaqC5W_37NT0ujje2mjYinxeiOmIA1h6bBYsST_0xbefLJ6Fy7tWlS1OL1t5CFyCJZ5_vNtl2jJTv53homf79hhU0pUjNet7E-O1x01Cqh2Rm16YoGnZsETeXS4e1oJI4IkqzfhaISEsjxeBlSTJgL8NQ';
  static const int eventCount = 12;
  static const int clubCount = 5;

  static const List<Map<String, String>> profileEvents = [
    {
      'title': 'Workshop AI: Xu hướng tương lai',
      'date': '24/10/2024',
      'status': 'Đang hoạt động',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDdkReXA_HMyY2sg2TmNmA-4IKSGCAxEeujwXP3JVGJj0W4Fp-e8ZD9fWuA5E5qrskyF4NRB5d91S1BNFky_Z1ypIIoaLx8Q2SJ3-wEB1g35UyvfuhoydWjoKDdRfoQsn7WS60bJvGCLWDu8z8KnsMdbiLnK3R94M8rb6m46ifdmPrcjeOrtzS81sXSpFBfMVHEoIAFPHXmsoj1sT-xNAwTj_zt2RnRSbC4XhUnryanmY0SL_O-zAt87b4FgYgSbMvmnWkPFdNYteY',
    },
    {
      'title': 'Đêm Open Mic trong khuôn viên',
      'date': '30/10/2024',
      'status': 'Nháp',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuByft2wTiNzS6FnbkbPZHJM7hAg7DcadGP94XTPOk7sXKdZ7fEzzpQ13Ho9er_gRbVaZbHC3fto9gJyBgmaggPFk5_22irpwRb8I9gPJxecwEkEs7it7AlXKz5nVd4gbEYCk2j3U_xSna_zTKF3KAcL7HuCYpychLHF0U69k_juvv_9srVqtc2rcBvWaUbctZV39KSW34SUPSOPnZEEc1u8gHVCqUicXZkrsseUeVZhb5sUL4xtgvrXzh-1PfTnUrrobNrxHp0JjRY',
    },
  ];
}
