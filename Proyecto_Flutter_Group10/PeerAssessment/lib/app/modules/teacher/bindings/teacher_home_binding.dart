import 'package:get/get.dart';

import '../controllers/create_course_controller.dart';
import '../controllers/teacher_home_controller.dart';

class TeacherHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherHomeController>(TeacherHomeController.new);
    Get.lazyPut<CreateCourseController>(CreateCourseController.new);
  }
}
