import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/create_course_controller.dart';

/// Standalone view for creating or updating a course from a Brightspace CSV.
class CreateCourseView extends GetView<CreateCourseController> {
  const CreateCourseView({
    super.key,
    this.initialCourseName,
    this.screenTitle = 'Crear Curso',
    this.submitLabel = 'Cargar CSV',
  });

  final String? initialCourseName;
  final String screenTitle;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final courseNameController = TextEditingController(
      text: initialCourseName ?? '',
    );
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppTheme.themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          screenTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.upload_file_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Importar desde Brightspace',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sube un CSV con grupos y estudiantes para crear o actualizar el curso automaticamente.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Nombre del Curso',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: courseNameController,
                  decoration: InputDecoration(
                    hintText: 'Ej. Ingenieria de Software 2025-10',
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryGreen,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Campo requerido'
                      : null,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Formato CSV esperado',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Group Category Name, Group Name, Group Code, '
                        'Username, OrgDefinedId, First Name, Last Name, '
                        'Email Address, Group Enrollment Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Si la categoria ya existe en ese curso, se reemplazan sus grupos y membresias antes de importar el nuevo CSV.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => FilledButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (formKey.currentState?.validate() ?? false) {
                              controller.pickAndUpload(
                                courseNameController.text,
                              );
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload_rounded),
                    label: Text(
                      controller.isLoading.value
                          ? 'Procesando...'
                          : submitLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  final message = controller.statusMessage.value;
                  final loading = controller.isLoading.value;
                  if (message.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final isError = message.startsWith('Error');
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(message),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: loading
                            ? AppTheme.primaryGreen.withValues(alpha: 0.06)
                            : isError
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: loading
                              ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                              : isError
                              ? Colors.red.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (loading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              isError
                                  ? Icons.error_outline_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 20,
                              color: isError
                                  ? Colors.red.shade600
                                  : Colors.green.shade600,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 13,
                                color: loading
                                    ? AppTheme.primaryGreen
                                    : isError
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Obx(() {
                  if (!controller.isLoading.value) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: controller.progress.value > 0
                              ? controller.progress.value
                              : null,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
