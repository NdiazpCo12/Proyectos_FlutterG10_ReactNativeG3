import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/app/modules/teacher/controllers/create_course_controller.dart';
import 'package:login/app/modules/teacher/views/create_course_view.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateCourseView', () {
    Future<void> pumpCreateCourse(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await bootstrapTestEnvironment(tester);
      Get.put<CreateCourseController>(CreateCourseController());
      await tester.pumpWidget(buildTestApp(const CreateCourseView()));
      await tester.pump();
    }

    testWidgets('renders form content', (tester) async {
      await pumpCreateCourse(tester);

      expect(find.text('Crear Curso'), findsOneWidget);
      expect(find.text('Nombre del Curso'), findsOneWidget);
      expect(find.text('Formato CSV esperado'), findsOneWidget);
      expect(find.text('Cargar CSV'), findsOneWidget);
    });

    testWidgets('validates required course name', (tester) async {
      await pumpCreateCourse(tester);

      await tester.tap(find.text('Cargar CSV'));
      await tester.pump();

      expect(find.text('Campo requerido'), findsOneWidget);
    });
  });
}
