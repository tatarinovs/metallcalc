import 'package:flutter/material.dart';
import '../services/prefs.dart';
import '../models/material_data.dart';
import '../data/materials_db.dart';
import '../theme/app_theme.dart';

class MaterialSelector extends StatefulWidget {
  final ValueChanged<Grade?> onGradeChanged;

  const MaterialSelector({super.key, required this.onGradeChanged});

  @override
  State<MaterialSelector> createState() => _MaterialSelectorState();
}

class _MaterialSelectorState extends State<MaterialSelector> {
  MaterialGroup? _selectedGroup;
  Grade? _selectedGrade;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() {
    final lastGroup = prefs.getString('last_group');
    if (lastGroup != null) {
      try {
        _selectedGroup = materialsDb.firstWhere((g) => g.name == lastGroup);
        final lastGrade = prefs.getString('last_grade_${_selectedGroup!.name}');
        if (lastGrade != null) {
          try {
            _selectedGrade = _selectedGroup!.grades.firstWhere((g) => g.name == lastGrade);
          } catch (_) {}
        }
        if (_selectedGrade == null && _selectedGroup!.grades.isNotEmpty) {
          _selectedGrade = _selectedGroup!.grades.first;
        }
      } catch (_) {
        // Fallback if not found
      }
    }

    if (_selectedGrade != null) {
      Future.microtask(() => widget.onGradeChanged(_selectedGrade));
    }
  }

  void _onGroupChanged(MaterialGroup? group) {
    if (group == null) return;
    prefs.setString('last_group', group.name);

    Grade? prevGrade;
    final lastGrade = prefs.getString('last_grade_${group.name}');
    if (lastGrade != null) {
      try {
        prevGrade = group.grades.firstWhere((g) => g.name == lastGrade);
      } catch (_) {}
    }

    if (prevGrade == null && group.grades.isNotEmpty) {
      prevGrade = group.grades.first;
      prefs.setString('last_grade_${group.name}', prevGrade.name);
    }

    setState(() {
      _selectedGroup = group;
      _selectedGrade = prevGrade;
    });
    widget.onGradeChanged(prevGrade);
  }

  void _onGradeChanged(Grade? grade) {
    if (grade != null && _selectedGroup != null) {
      prefs.setString('last_grade_${_selectedGroup!.name}', grade.name);
    }
    setState(() {
      _selectedGrade = grade;
    });
    widget.onGradeChanged(grade);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Первый уровень: материал ---
        _StyledDropdown<MaterialGroup>(
          label: 'Материал',
          value: _selectedGroup,
          items: materialsDb,
          displayText: (g) => g.name,
          onChanged: _onGroupChanged,
          hint: 'Выберите материал',
        ),
        const SizedBox(height: 12),
        // --- Второй уровень: марка ---
        _StyledDropdown<Grade>(
          label: 'Марка',
          value: _selectedGrade,
          items: _selectedGroup?.grades ?? [],
          displayText: (g) => '${g.name}  (${g.density} г/см³)',
          onChanged: _onGradeChanged,
          hint: _selectedGroup == null ? 'Сначала выберите материал' : 'Выберите марку',
          enabled: _selectedGroup != null,
        ),
      ],
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) displayText;
  final ValueChanged<T?> onChanged;
  final String hint;
  final bool enabled;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.displayText,
    required this.onChanged,
    required this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppTheme.surfaceVariant : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? AppTheme.divider : AppTheme.divider.withValues(alpha: 0.4),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              hint: Text(
                hint,
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: enabled ? 1.0 : 0.5),
                  fontSize: 14,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? AppTheme.textSecondary : AppTheme.divider,
              ),
              items: enabled
                  ? items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          displayText(item),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList()
                  : [],
              onChanged: enabled ? onChanged : null,
              selectedItemBuilder: (context) => items.map((item) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayText(item),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
