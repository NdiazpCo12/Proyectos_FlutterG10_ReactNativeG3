part of 'teacher_home_view.dart';

class TeacherCourseDetailView extends StatefulWidget {
  const TeacherCourseDetailView({super.key, required this.course});

  final RobleCourseHome course;

  @override
  State<TeacherCourseDetailView> createState() =>
      _TeacherCourseDetailViewState();
}

class _TeacherCourseDetailViewState extends State<TeacherCourseDetailView> {
  late Future<RobleCourseManagementData> _detailsFuture;
  bool _isDeleting = false;

  TeacherHomeController get _controller => Get.find<TeacherHomeController>();

  @override
  void initState() {
    super.initState();
    _detailsFuture = _controller.loadCourseManagementData(widget.course);
  }

  Future<void> _reload() async {
    setState(() {
      _detailsFuture = _controller.loadCourseManagementData(widget.course);
    });
    await _detailsFuture;
  }

  Future<void> _openCsvUpdate() async {
    await Get.to(
      () => CreateCourseView(
        initialCourseName: widget.course.name,
        screenTitle: 'Actualizar Curso',
        submitLabel: 'Actualizar con CSV',
      ),
    );

    await _controller.fetchCourses();
    if (!mounted) {
      return;
    }
    await _reload();
  }

  Future<void> _deleteCourse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar curso'),
        content: Text(
          'Se eliminaran el curso "${widget.course.name}", sus categorias, grupos, membresias y estudiantes sin otros grupos asociados. Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await _controller.deleteCourse(widget.course);
      if (!mounted) {
        return;
      }

      Get.back();
      Get.snackbar(
        'Curso eliminado',
        'Se eliminó "${widget.course.name}" correctamente.',
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
          fallback: 'No se pudo eliminar el curso en este momento.',
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.course.name),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _isDeleting ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<RobleCourseManagementData>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No se pudo cargar el curso',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatUserErrorMessage(
                            snapshot.error!,
                            fallback:
                                'No se pudo cargar la informacion del curso.',
                          ),
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Intentar de nuevo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final roster = data.roster;
          final uniqueGroups = roster
              .map((entry) => entry.groupId)
              .toSet()
              .length;

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                _SurfaceCard(
                  borderRadius: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.course.code,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.course.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _TeacherInfoRow(
                        icon: Icons.alternate_email_rounded,
                        text: data.course.teacherEmail.isEmpty
                            ? 'Sin correo del docente'
                            : data.course.teacherEmail,
                      ),
                      const SizedBox(height: 10),
                      _TeacherInfoRow(
                        icon: Icons.calendar_month_outlined,
                        text: 'Creado el ${_formatDate(data.course.createdAt)}',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniInfo(
                              label: 'Estudiantes',
                              value: data.studentCount.toString(),
                            ),
                          ),
                          Expanded(
                            child: _MiniInfo(
                              label: 'Grupos',
                              value: uniqueGroups.toString(),
                            ),
                          ),
                          Expanded(
                            child: _MiniInfo(
                              label: 'Categorias',
                              value: data.categories.length.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestion del curso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Desde aqui puedes volver a importar el CSV del curso o eliminarlo por completo.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _isDeleting ? null : _openCsvUpdate,
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text('Actualizar con CSV'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isDeleting ? null : _deleteCourse,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                            icon: _isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_outline_rounded),
                            label: Text(
                              _isDeleting ? 'Eliminando...' : 'Eliminar curso',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categorias del curso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (data.categories.isEmpty)
                        const Text(
                          'Este curso no tiene categorias registradas.',
                          style: TextStyle(color: AppTheme.textMuted),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: data.categories
                              .map(
                                (category) => _StatusChip(
                                  label: category.name,
                                  tone: AppTheme.primaryGreen,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Estudiantes registrados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${roster.length} registros',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (roster.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Aun no hay estudiantes registrados para este curso.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      else
                        ...roster.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CourseRosterTile(entry: entry),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _CourseRosterTile extends StatelessWidget {
  const _CourseRosterTile({required this.entry});

  final RobleCourseRosterEntry entry;

  @override
  Widget build(BuildContext context) {
    final initials = _buildInitials(entry.fullName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8E5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.cardTint,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PillTag(
                      label: entry.groupName,
                      color: AppTheme.primaryGreen,
                    ),
                    _PillTag(
                      label: entry.categoryName,
                      color: AppTheme.secondarySlate,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Codigo de grupo: ${entry.groupCode}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (entry.orgDefinedId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'OrgDefinedId: ${entry.orgDefinedId}',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
