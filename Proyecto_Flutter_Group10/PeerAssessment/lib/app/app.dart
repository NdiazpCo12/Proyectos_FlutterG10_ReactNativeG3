import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'modules/login/bindings/login_binding.dart';
import 'modules/login/views/login_view.dart';

class PeerAssessmentApp extends StatelessWidget {
  const PeerAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peer Assessment',
      theme: AppTheme.themeData,
      initialBinding: LoginBinding(),
      home: const LoginView(),
    );
  }
}
