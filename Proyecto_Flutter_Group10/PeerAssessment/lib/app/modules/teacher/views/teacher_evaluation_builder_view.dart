part of 'teacher_home_view.dart';

class TeacherEvaluationBuilderView extends StatefulWidget {
  const TeacherEvaluationBuilderView({super.key});

  @override
  State<TeacherEvaluationBuilderView> createState() =>
      _TeacherEvaluationBuilderViewState();
}

class _TeacherEvaluationBuilderViewState
    extends State<TeacherEvaluationBuilderView> {
  final _nameController = TextEditingController();
  final TeacherHomeController _controller = Get.find<TeacherHomeController>();

  String? _courseId;
  String? _categoryId;
  List<RobleGroupCategoryRecord> _categories = const [];
  bool _publicResults = true;
  double _durationDays = 7;
  bool _isInitializing = true;
  bool _isLoadingCategories = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    if (_controller.courses.isEmpty) {
      await _controller.fetchCourses();
    }

    if (!mounted) {
      return;
    }

    if (_controller.courses.isNotEmpty) {
      _courseId = _controller.courses.first.id;
      await _loadCategories(_courseId!, preserveSelection: false);
    }

    if (!mounted) {
      return;
    }

    setState(() => _isInitializing = false);
  }

  Future<void> _loadCategories(
    String courseId, {
    bool preserveSelection = true,
  }) async {
    setState(() => _isLoadingCategories = true);

    try {
      final categories = await _controller.loadCourseCategories(courseId);
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        if (preserveSelection &&
            categories.any((category) => category.id == _categoryId)) {
          _categoryId = _categoryId;
        } else {
          _categoryId = categories.isNotEmpty ? categories.first.id : null;
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _submit() async {
    final assessmentName = _nameController.text.trim();
    if (assessmentName.isEmpty) {
      Get.snackbar(
        'Assessment',
        'Ingresa un nombre para el assessment.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_courseId == null) {
      Get.snackbar(
        'Assessment',
        'Selecciona un curso antes de continuar.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_categoryId == null) {
      Get.snackbar(
        'Assessment',
        'El curso seleccionado no tiene categorias disponibles.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final assessmentId = await _controller.createAssessment(
        name: assessmentName,
        courseId: _courseId!,
        categoryId: _categoryId!,
        publicResults: _publicResults,
        durationDays: _durationDays.round(),
      );

      if (!mounted) {
        return;
      }

      Get.off(() => TeacherAssessmentDetailView(assessmentId: assessmentId));
      Get.snackbar(
        'Evaluacion creada',
        'La evaluacion se guardo correctamente con la rubrica predeterminada.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Error',
        formatUserErrorMessage(
          error,
          fallback: 'No se pudo crear la evaluacion.',
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(22, 52, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: Get.back,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Create Assessment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set up a new peer assessment',
                  style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Basic information about the assessment',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _FieldLabel('Assessment Name *'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Sprint 1 Team Review',
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Course *'),
                      const SizedBox(height: 10),
                      Obx(() {
                        final courses = _controller.courses;
                        if (courses.isEmpty) {
                          return const Text(
                            'Primero debes crear al menos un curso.',
                            style: TextStyle(color: AppTheme.textMuted),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _courseId,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: const InputDecoration(
                            hintText: 'Select a course',
                          ),
                          items: courses
                              .map(
                                (course) => DropdownMenuItem<String>(
                                  value: course.id,
                                  child: Text(
                                    '${course.name} (${course.code})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isSubmitting
                              ? null
                              : (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _courseId = value;
                                    _categoryId = null;
                                  });
                                  _loadCategories(
                                    value,
                                    preserveSelection: false,
                                  );
                                },
                        );
                      }),
                      const SizedBox(height: 18),
                      const _FieldLabel('Group Category *'),
                      const SizedBox(height: 10),
                      if (_isLoadingCategories)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _categoryId,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: const InputDecoration(
                            hintText: 'Select group category',
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                          onChanged: _isSubmitting
                              ? null
                              : (value) {
                                  setState(() => _categoryId = value);
                                },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Time Window',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How long will students have to complete this?',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Duration (days)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            _durationDays.round().toString(),
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _durationDays,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() => _durationDays = value);
                              },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              '1 day',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '30 days',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Visibility Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Control who can see the results',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Public Results',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Students can view their results',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _publicResults,
                            activeThumbColor: AppTheme.primaryGreen,
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    setState(() => _publicResults = value);
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Default Rubric',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This version uses the default rubric: Punctuality, Contributions, Commitment and Attitude.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _isSubmitting ? 'Creating...' : 'Create Assessment',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : Get.back,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
