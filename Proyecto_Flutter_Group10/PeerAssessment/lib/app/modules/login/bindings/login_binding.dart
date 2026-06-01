import 'package:get/get.dart';

import '../../../core/storage/session_storage_service.dart';
import '../controllers/login_controller.dart';
import '../services/auth_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SessionStorageService>(SessionStorageService.new, fenix: true);
    Get.lazyPut<AuthService>(
      () => AuthService(storage: Get.find<SessionStorageService>()),
      fenix: true,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(authService: Get.find<AuthService>()),
    );
  }
}
