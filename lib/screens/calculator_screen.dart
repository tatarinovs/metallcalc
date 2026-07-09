import 'package:flutter/material.dart';
import '../models/material_data.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_selector.dart';
import '../widgets/material_selector.dart';
import '../widgets/dimension_inputs.dart';
import '../widgets/result_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  ProfileType _profile = ProfileType.sheet;
  Grade? _grade;
  List<double> _dims = [0, 0, 0];

  double? get _volume => _profile.calcVolume(_dims[0], _dims[1], _dims[2]);

  void _onProfileChanged(ProfileType p) {
    setState(() {
      _profile = p;
      _dims = [0, 0, 0];
    });
  }

  void _onGradeChanged(Grade? g) {
    setState(() => _grade = g);
  }

  void _onDimsChanged(List<double> d) {
    setState(() => _dims = d);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      ),
    );
  }

  // Узкий макет (телефон / маленькое окно)
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            label: 'Форма проката',
            child: ProfileSelector(
              selected: _profile,
              onChanged: _onProfileChanged,
            ),
          ),
          const SizedBox(height: 10),
          _Section(
            label: 'Размеры',
            child: DimensionInputs(
              profile: _profile,
              onChanged: _onDimsChanged,
            ),
          ),
          const SizedBox(height: 10),
          _Section(
            label: 'Материал и марка',
            child: MaterialSelector(onGradeChanged: _onGradeChanged),
          ),
          const SizedBox(height: 12),
          _Section(
            label: 'Результат',
            withCard: false,
            child: ResultDisplay(
              volumeMm3: _volume,
              densityGcm3: _grade?.density,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Широкий макет (планшет / Windows)
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Левая колонка — ввод
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  label: 'Форма проката',
                  child: ProfileSelector(
                    selected: _profile,
                    onChanged: _onProfileChanged,
                  ),
                ),
                const SizedBox(height: 20),
                _Section(
                  label: 'Размеры',
                  child: DimensionInputs(
                    profile: _profile,
                    onChanged: _onDimsChanged,
                  ),
                ),
                const SizedBox(height: 20),
                _Section(
                  label: 'Материал и марка',
                  child: MaterialSelector(onGradeChanged: _onGradeChanged),
                ),
              ],
            ),
          ),
        ),
        // Разделитель
        Container(
          width: 1,
          color: AppTheme.divider,
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        // Правая колонка — результат
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  label: 'Результат',
                  withCard: false,
                  child: ResultDisplay(
                    volumeMm3: _volume,
                    densityGcm3: _grade?.density,
                  ),
                ),
                const SizedBox(height: 20),
                _Section(
                  label: 'Формула',
                  withCard: false,
                  child: _FormulaHint(profile: _profile, grade: _grade, dims: _dims),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Секция с плавающим заголовком снаружи карточки
class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  final bool withCard;

  const _Section({required this.label, required this.child, this.withCard = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (withCard)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: child,
          )
        else
          child,
      ],
    );
  }
}

/// Подсказка с формулой (только для широкого макета)
class _FormulaHint extends StatelessWidget {
  final ProfileType profile;
  final Grade? grade;
  final List<double> dims;

  const _FormulaHint({
    required this.profile,
    required this.grade,
    required this.dims,
  });

  @override
  Widget build(BuildContext context) {
    final formula = _getFormula();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.functions_rounded, size: 14, color: AppTheme.textSecondary),
              SizedBox(width: 6),
              Text(
                'Формула',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formula,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
          if (grade != null) ...[
            const SizedBox(height: 6),
            Text(
              'ρ = ${grade!.density} г/см³',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFormula() {
    switch (profile) {
      case ProfileType.sheet:
        return 'V = A × B × L\nm = V × ρ / 10⁶';
      case ProfileType.circle:
        return 'V = π × D² / 4 × L\nm = V × ρ / 10⁶';
      case ProfileType.square:
        return 'V = A² × L\nm = V × ρ / 10⁶';
      case ProfileType.hex:
        return 'V = (√3/2) × S² × L\nm = V × ρ / 10⁶';
      case ProfileType.pipe:
        return 'V = π/4 × (D² − d²) × L\nd = D − 2t\nm = V × ρ / 10⁶';
    }
  }
}
