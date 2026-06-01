import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/auth_exception.dart';
import '../../student/views/student_home_view.dart';
import '../../teacher/bindings/teacher_home_binding.dart';
import '../../teacher/views/teacher_home_view.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  LoginController({
    required AuthService authService,
    VoidCallback? onOpenTeacherHome,
    VoidCallback? onOpenStudentHome,
  }) : _authService = authService,
       _onOpenTeacherHome = onOpenTeacherHome,
       _onOpenStudentHome = onOpenStudentHome;

  final AuthService _authService;
  final VoidCallback? _onOpenTeacherHome;
  final VoidCallback? _onOpenStudentHome;

  final emailController = TextEditingController();
  final passwordController = TextEditingController(
    text: AuthService.defaultUserPassword,
  );

  final isSubmitting = false.obs;

  Future<void> signIn() async {
    if (isSubmitting.value) {
      return;
    }

    final email = emailController.text.trim();
    final password = AuthService.defaultUserPassword;

    if (email.isEmpty) {
      Get.snackbar(
        'Login',
        'Ingresa el correo institucional para continuar.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final session = await _authService.signIn(
        email: email,
        password: password,
      );
      _openHomeForUser(session.user);
    } on AuthException catch (error) {
      Get.snackbar(
        'Login',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Login',
        'No fue posible iniciar sesion. Intenta de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      await _authService.logout();
    } on AuthException {
      await _authService.clearLocalSession();
    }
  }

  void _openHomeForUser(AuthUser user) {
    final normalizedRole = user.role.trim().toLowerCase();

    if (_isTeacherRole(normalizedRole)) {
      if (_onOpenTeacherHome != null) {
        _onOpenTeacherHome();
        return;
      }
      Get.offAll(() => const TeacherHomeView(), binding: TeacherHomeBinding());
      return;
    }

    if (_isStudentRole(normalizedRole)) {
      if (_onOpenStudentHome != null) {
        _onOpenStudentHome();
        return;
      }
      Get.offAll(() => const StudentHomeView());
      return;
    }

    throw AuthException(
      'Rol no soportado por la app: ${user.role.isEmpty ? 'sin rol' : user.role}.',
    );
  }

  bool _isTeacherRole(String role) {
    return role == 'profesor' ||
        role == 'teacher' ||
        role == 'docente' ||
        role == 'admin';
  }

  bool _isStudentRole(String role) {
    return role == 'estudiante' || role == 'student' || role == 'alumno';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
