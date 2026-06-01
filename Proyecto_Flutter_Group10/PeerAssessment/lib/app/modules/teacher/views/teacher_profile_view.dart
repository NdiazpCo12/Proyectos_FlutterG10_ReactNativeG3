part of 'teacher_home_view.dart';

class _TeacherProfile extends StatelessWidget {
  const _TeacherProfile();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(22, 24, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage your account settings',
                    style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            children: [
              FutureBuilder<AuthUser?>(
                future: Get.find<AuthService>().getStoredUser(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final name = user?.name.trim();
                  final email = user?.email.trim();
                  final roleLabel = _teacherRoleLabel(user?.role);

                  return _SurfaceCard(
                    borderRadius: 20,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: AppTheme.cardTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: AppTheme.primaryGreen,
                                size: 38,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name != null && name.isNotEmpty
                                        ? name
                                        : 'Teacher',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    roleLabel,
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        const SizedBox(height: 18),
                        _TeacherInfoRow(
                          icon: Icons.mail_outline,
                          text: email != null && email.isNotEmpty
                              ? email
                              : 'No email available',
                        ),
                        const SizedBox(height: 14),
                        const _TeacherInfoRow(
                          icon: Icons.school_outlined,
                          text: 'Computer Science Department',
                        ),
                        const SizedBox(height: 14),
                        _TeacherInfoRow(
                          icon: Icons.shield_outlined,
                          text: '$roleLabel Account',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _SurfaceCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: AppTheme.primaryGreen,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Manage your notification preferences',
                      style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => _TeacherToggleTile(
                        title: 'Email Notifications',
                        subtitle: 'Receive updates via email',
                        value: _TeacherUiState.emailNotifications.value,
                        onChanged: (value) {
                          _TeacherUiState.emailNotifications.value = value;
                        },
                      ),
                    ),
                    const Divider(height: 22),
                    Obx(
                      () => _TeacherToggleTile(
                        title: 'Assessment Reminders',
                        subtitle: 'Get reminded about due dates',
                        value: _TeacherUiState.assessmentReminders.value,
                        onChanged: (value) {
                          _TeacherUiState.assessmentReminders.value = value;
                        },
                      ),
                    ),
                    const Divider(height: 22),
                    Obx(
                      () => _TeacherToggleTile(
                        title: 'New Results',
                        subtitle: 'Notify when results are available',
                        value: _TeacherUiState.newResults.value,
                        onChanged: (value) {
                          _TeacherUiState.newResults.value = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SurfaceCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                        SizedBox(width: 10),
                        Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Get help and support',
                      style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 18),
                    _TeacherSupportButton(
                      icon: Icons.help_outline,
                      label: 'Help Center',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _TeacherSupportButton(
                      icon: Icons.mail_outline,
                      label: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    try {
                      await Get.find<AuthService>().logout();
                    } catch (_) {
                      await Get.find<AuthService>().clearLocalSession();
                    }
                    Get.offAll(
                      () => const LoginView(),
                      binding: LoginBinding(),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD81B45),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Peer Assessment Platform',
                      style: TextStyle(
                        color: AppTheme.secondarySlate,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Powered by Roble • Version 1.0.0',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _teacherRoleLabel(String? role) {
  final normalizedRole = role?.trim().toLowerCase() ?? '';

  switch (normalizedRole) {
    case 'profesor':
    case 'teacher':
    case 'docente':
      return 'Teacher';
    case 'estudiante':
    case 'student':
    case 'alumno':
      return 'Student';
    default:
      if (normalizedRole.isEmpty) {
        return 'Teacher';
      }
      return '${normalizedRole[0].toUpperCase()}${normalizedRole.substring(1)}';
  }
}
