// File: lib/mock/mock_team_data.dart

import 'package:frontend/features/events/models/team_member_model.dart';

/// Mock team member data for Event Detail Organizer screen.
class MockTeamData {
  MockTeamData._();

  static const List<TeamMemberModel> btcTeam = [
    TeamMemberModel(
      id: '1',
      name: 'Alex Rivera',
      role: 'Lead Organizer',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1vKi1oHMg6_dl9xhiW7b2bwhzyjlRY_HJaEdNI1nm6Oz7UFCToEY2qcuIMXDNS0Jrxb66teq7Od1aN8OVVzLdHPrDdmboMU_KBQqRk5OXdq6_FPwdL0H_jCNE9b55oXq-YL2z-5ATwdBV1r-SzAZOC-Xb23-QdZWsgW6OQ-OZYDktj4dX3vQIn_wzl47Nr-GF0XA98hElVGbsnMfylrw7VUZed3tKe_fOY6uflHtz5W1KqrRhogGpDKH5AiUf7I2eGpjr2jBf0AA',
    ),
    TeamMemberModel(
      id: '2',
      name: 'Marcus Chen',
      role: 'Head of Operations',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC8b_KswTJcj25j5WaMQycFiiyrLzpjZbeAwiRJ1NlWGkkG7mcTMI5qCZNwcqq8hH2WO6FnH1FdjPmpvt016s_flN3AGnlnb6Wxc1aC_gVVX0BPT0XE299i7rBdPXSedi6cr1r-mM20plKJrKjcx-MG98XAAPipKuilIm-bRiN3Z3DcH59U1jKQu4y59gsrlT91qB4V8REyeWtVpxDpNWksawqQMjlSp-KvowGVvYMHYrsHGDlVqRd1LEQZOS_7couPi_oQdhsHVJ0',
    ),
    TeamMemberModel(
      id: '3',
      name: 'Sarah Jenkins',
      role: 'Tech Lead',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAtO4QG-JFTWgJWsfv5gcl44HVaRHK8Y8tcs0gFN4pOocsmg5FqGBFTchHHRzv2lyMiTdamKxkArer9TWYCVAvCkPExt5k7W2HKr7HOmUMNINHBUcpCuej_VT_jzN0kQveLx6ClX-KPQTwOhlmeSWSxeSH3_CI16TA3yoUPnudumY5oLD9wLhBPCSqvcPo88Rl3F9MRb91u3pzGH4RL_sREt1U6K1GgKPRwMhZx4HwzJjoRlFR5fX0dvQbhge0PP35J3aBFUthLUFE',
    ),
  ];
}
