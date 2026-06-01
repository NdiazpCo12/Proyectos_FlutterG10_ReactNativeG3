part of 'teacher_home_view.dart';

class _TeacherDashboard extends StatelessWidget {
  const _TeacherDashboard({required this.controller});

  final TeacherHomeController controller;

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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Obx(
                () => Text(
                  'Welcome back, ${controller.displayName.value}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Column(
            children: [
              _SurfaceCard(
                borderRadius: 28,
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brightspace\nIntegration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Sync your courses and data',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Obx(
                      () => FilledButton.icon(
                        onPressed: controller.isSyncing.value
                            ? null
                            : controller.syncWithBrightspace,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: controller.isSyncing.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          controller.isSyncing.value ? 'Syncing' : 'Sync Now',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Enrolled Courses',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${controller.courses.length} courses',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: 'Crear Curso',
                    child: FilledButton.icon(
                      onPressed: () => Get.to(() => const CreateCourseView()),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Crear',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoadingCourses.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  );
                }

                if (controller.courses.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No hay cursos registrados',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.courses
                      .map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _CourseCard(
                            course: course,
                            onTap: () {
                              Get.to(
                                () => TeacherCourseDetailView(course: course),
                              );
                            },
                            onManageTap: () {
                              Get.to(
                                () => TeacherCourseDetailView(course: course),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
