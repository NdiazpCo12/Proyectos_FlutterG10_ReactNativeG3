import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/error_message_formatter.dart';
import '../../../core/roble/roble.dart';
import '../../../core/theme/app_theme.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/models/auth_user.dart';
import '../../login/services/auth_service.dart';
import '../../login/views/login_view.dart';
import '../controllers/teacher_home_controller.dart';
import 'create_course_view.dart';

part 'teacher_ui_state.dart';
part 'teacher_course_detail_view.dart';
part 'teacher_evaluation_builder_view.dart';
part 'teacher_assessment_detail_view.dart';
part 'teacher_dashboard_view.dart';
part 'teacher_evaluations_view.dart';
part 'teacher_reports_view.dart';
part 'teacher_profile_view.dart';
part 'teacher_shared_widgets.dart';

class TeacherHomeView extends GetView<TeacherHomeController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TeacherDashboard(controller: controller),
      _TeacherEvaluations(controller: controller),
      _TeacherReports(controller: controller),
      const _TeacherProfile(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedTab.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedTab.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Assessments',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Results',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
