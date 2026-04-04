// File: lib/features/events/mock/mock_manage_team_data.dart

import 'package:frontend/features/events/models/team_member_model.dart';

/// Mock team member data for Manage Team screen.
class MockManageTeamData {
  MockManageTeamData._();

  static const List<TeamMemberModel> teamMembers = [
    TeamMemberModel(
      id: '1',
      name: 'Alex Morgan',
      role: 'Admin',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFuL6NEAAge6fvYvVth0uzStI429Dajq-NiNb2nAYa4pRLMrPGGE8jJTsSmhEucJa4f-KUkkV_fGulm3rw929-C5H7dH3cmXfNMTEoXTKyrXxsuFoXPPxkX-oPo5r9Bi8QCDyBMwPOQyEKbe8GgpjXBpn9__L1Og6KGMrcyV2zK-XrMaSIkB26jAUNy4hCyz4V8gH2DQ2UR2Q59FgQ1BK66c2sMi0xU8YNhLQvUN34Ap8LkfTxpbh65tmQQEMKw6hz1ztwShbCCR8',
    ),
    TeamMemberModel(
      id: '2',
      name: 'Jordan Smith',
      role: 'Staff',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBqVls72LTDAaYL5PxFCVtnZTvtW7vPP6MuqEXvQp7XMjRQUYkZAhmDpUsp5FJrPQ3jlfKof36ucQdDjUerfqm9i5tqvUsJG75POZECaXd5tMTD67F39sD9153ffy1qh_XD0lhOwg-PrVO9cBA0X9FEymCjIAz5fq6dh4KvZFdI6HQLkwTlYTKTperkfjkPKcSDKZIc4TFhoYL9-0_IIVoOZxs8mCHfRKwYTScSoipsz2LWiKP5msD74Y9uJWLWHDsBcL3otuE2IwM',
    ),
    TeamMemberModel(
      id: '3',
      name: 'Riley King',
      role: 'Staff',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAHXMeqmVpFETbxlZcWBB-5-lqS_veeqBx54mzWRkqIKdT9AST-MPgHOsmY35L-HGvDls7QmjOpsAKujBXVTigJxvwkN0Cvw29OQijkrH_zQbutusBdqaTHnV2_pXwZCANM_oytzX9W59lVe0ZYyM6WY_Uq2vcVfRFAzpINmqku86-xFHYavdPd2tNmdw4JIV2AZd7xKmrYs-Po9PKo0Hoy_fdI76Lwmx4y1wCBwSHU4W2p8QDAD1vV9pfjC0vhYzM3urGHfK-58M0',
    ),
    TeamMemberModel(
      id: '4',
      name: 'Casey Wright',
      role: 'Volunteer',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA-Bcf1Pcg8-bI__Mq4l6OmFnlil_ZzazuHOXQoHPBB6f1QsN_tSjSh-ZZWdO3wDpPDt6FGvPKi6xDEQsZEUFiKWKuV2wYefQMOXh4eey_CVMKmhe5r7n-43GR2hJrcP-jn_G9lNx5S1e3cf4bfwuo8P4QLD09sdoqR9TlLX8AqUGmYmkvSH81ao--Ltd5pZWhYD4r_KVh_cfA2J28lj7q6qGP0v9226JrPKbrU7TuTi6z1a-8RvhWx1PVCd-8EojwXY0bU5YsT-AU',
    ),
  ];
}
