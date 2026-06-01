part of 'teacher_home_view.dart';

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.onTap,
    required this.onManageTap,
  });

  final RobleCourseHome course;
  final VoidCallback onTap;
  final VoidCallback onManageTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.code,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppTheme.cardTint,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Gestionar curso',
                          onPressed: onManageTap,
                          icon: Icon(
                            course.status == 'Closed'
                                ? Icons.archive_outlined
                                : Icons.menu_book_outlined,
                            color: AppTheme.primaryGreen,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 20,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${course.studentCount} students',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${course.pendingEvaluations} active ${course.pendingEvaluations == 1 ? 'assessment' : 'assessments'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: tone, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.bars,
    required this.tooltipLabel,
    required this.tooltipValue,
  });

  final String title;
  final String subtitle;
  final List<_ChartBar> bars;
  final String tooltipLabel;
  final String tooltipValue;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 18),
          _MiniBarChart(
            bars: bars,
            tooltipLabel: tooltipLabel,
            tooltipValue: tooltipValue,
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatefulWidget {
  const _MiniBarChart({
    required this.bars,
    required this.tooltipLabel,
    required this.tooltipValue,
  });

  final List<_ChartBar> bars;
  final String tooltipLabel;
  final String tooltipValue;

  @override
  State<_MiniBarChart> createState() => _MiniBarChartState();
}

class _MiniBarChartState extends State<_MiniBarChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(
                left: 28,
                top: 12,
                right: 8,
                bottom: 42,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E3E6)),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 28,
                top: 12,
                right: 8,
                bottom: 42,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                  (_) => Container(height: 1, color: const Color(0xFFE1E3E6)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 6,
            bottom: 34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('5', style: TextStyle(color: AppTheme.secondarySlate)),
                Text('2', style: TextStyle(color: AppTheme.secondarySlate)),
                Text('0', style: TextStyle(color: AppTheme.secondarySlate)),
              ],
            ),
          ),
          Positioned(
            left: 38,
            right: 12,
            bottom: 12,
            top: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.bars.map((bar) {
                final index = widget.bars.indexOf(bar);
                final isHovered = _hoveredIndex == index;

                return MouseRegion(
                  onEnter: (_) {
                    setState(() => _hoveredIndex = index);
                  },
                  onExit: (_) {
                    setState(() => _hoveredIndex = null);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isHovered)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFD8DDE3)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bar.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'average : ${bar.value.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(height: 54),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 32,
                        height: (bar.value / 5) * 120,
                        decoration: BoxDecoration(
                          color: bar.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 18,
                        child: Text(
                          bar.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondarySlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar {
  const _ChartBar({
    required this.label,
    required this.value,
    required this.color,
    this.highlighted = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool highlighted;
}

class _BreakdownStudent {
  const _BreakdownStudent({
    required this.id,
    required this.initials,
    required this.name,
    required this.average,
    this.details,
  });

  final String id;
  final String initials;
  final String name;
  final double average;
  final Map<String, double>? details;
}

class _StudentBreakdownCard extends StatelessWidget {
  const _StudentBreakdownCard({
    required this.student,
    required this.expanded,
    required this.onToggle,
  });

  final _BreakdownStudent student;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DDE3)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            leading: CircleAvatar(
              backgroundColor: AppTheme.cardTint,
              child: Text(
                student.initials,
                style: const TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Average: ${student.average.toStringAsFixed(1)}'),
            trailing: Icon(
              expanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
            ),
          ),
          if (expanded && student.details != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: AppTheme.cardTint,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                children: student.details!.entries
                    .map(
                      (entry) => SizedBox(
                        width: 110,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.value.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeacherInfoRow extends StatelessWidget {
  const _TeacherInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.secondarySlate),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}

class _TeacherToggleTile extends StatelessWidget {
  const _TeacherToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppTheme.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _TeacherSupportButton extends StatelessWidget {
  const _TeacherSupportButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        backgroundColor: const Color(0xFFF8F8F8),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
