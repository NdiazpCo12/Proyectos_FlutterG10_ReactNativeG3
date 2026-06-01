part of 'student_home_view.dart';

class _StudentProfile extends StatelessWidget {
  const _StudentProfile({
    required this.emailNotifications,
    required this.assessmentReminders,
    required this.newResults,
    required this.onEmailNotificationsChanged,
    required this.onAssessmentRemindersChanged,
    required this.onNewResultsChanged,
  });

  final bool emailNotifications;
  final bool assessmentReminders;
  final bool newResults;
  final ValueChanged<bool> onEmailNotificationsChanged;
  final ValueChanged<bool> onAssessmentRemindersChanged;
  final ValueChanged<bool> onNewResultsChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
                  final roleLabel = _studentRoleLabel(user?.role);

                  return _StudentSurfaceCard(
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
                                        : 'Student',
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
                        _ProfileInfoRow(
                          icon: Icons.mail_outline,
                          text: email != null && email.isNotEmpty
                              ? email
                              : 'No email available',
                        ),
                        const SizedBox(height: 14),
                        const _ProfileInfoRow(
                          icon: Icons.school_outlined,
                          text: 'Computer Science Department',
                        ),
                        const SizedBox(height: 14),
                        _ProfileInfoRow(
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
              _StudentSurfaceCard(
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
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    _SettingToggleTile(
                      title: 'Email Notifications',
                      subtitle: 'Receive updates via email',
                      value: emailNotifications,
                      onChanged: onEmailNotificationsChanged,
                    ),
                    const Divider(height: 22),
                    _SettingToggleTile(
                      title: 'Assessment Reminders',
                      subtitle: 'Get reminded about due dates',
                      value: assessmentReminders,
                      onChanged: onAssessmentRemindersChanged,
                    ),
                    const Divider(height: 22),
                    _SettingToggleTile(
                      title: 'New Results',
                      subtitle: 'Notify when results are available',
                      value: newResults,
                      onChanged: onNewResultsChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _StudentSurfaceCard(
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
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    _SupportButton(
                      icon: Icons.help_outline,
                      label: 'Help Center',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _SupportButton(
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
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
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

String _studentRoleLabel(String? role) {
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
        return 'Student';
      }
      return '${normalizedRole[0].toUpperCase()}${normalizedRole.substring(1)}';
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.secondarySlate),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}

class _SettingToggleTile extends StatelessWidget {
  const _SettingToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppTheme.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        backgroundColor: const Color(0xFFF8F8F8),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
