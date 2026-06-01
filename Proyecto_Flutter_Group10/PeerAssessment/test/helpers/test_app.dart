import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:login/app/core/theme/app_theme.dart';

Widget buildTestApp(Widget child) {
  return GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.themeData,
    home: child,
  );
}
