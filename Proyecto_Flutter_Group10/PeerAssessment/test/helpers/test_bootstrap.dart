import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrapTestEnvironment(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  Get.reset();
  SharedPreferences.setMockInitialValues({});
  addTearDown(() async {
    Get.reset();
  });
}
