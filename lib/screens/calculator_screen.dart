import 'package:flutter/material.dart';
import '../services/prefs.dart';
import '../services/calculator.dart';
import '../models/material_data.dart';
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
  // [a, b, c, d, e] — 5 измерений; неиспользуемые = 0
  final ValueNotifier<List<double>> _dims =
      ValueNotifier<List<double>>(List<double>.filled(5, 0));

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profileName = prefs.getString('selectedProfile');
    if (profileName != null) {
      final savedProfile = ProfileType.values.firstWhere(
        (e) => e.name == profileName,
        orElse: () => ProfileType.sheet,
      );
      _profile = savedProfile;
    }
  }

  double? _volumeFor(List<double> dimensions) => _profile.calcVolume(
        dimensions[0],
        dimensions[1],
        dimensions[2],
        dimensions[3],
        dimensions[4],
      );

  double? _linearMassFor(List<double> dimensions) {
    final grade = _grade;
    if (grade == null) return null;
    return calculateLinearMassKg(
      profile: _profile,
      dimensions: dimensions,
      densityGcm3: grade.density,
    );
  }

  void _onProfileChanged(ProfileType p) {
    if (_profile == p) return;
    setState(() {
      _profile = p;
    });
    _dims.value = List<double>.filled(5, 0);
    prefs.setString('selectedProfile', p.name);
  }

  void _onGradeChanged(Grade? g) {
    setState(() => _grade = g);
  }

  void _onDimsChanged(List<double> d) {
    _dims.value = List<double>.generate(
      5,
      (index) => index < d.length ? d[index] : 0.0,
    );
  }

  @override
  void dispose() {
    _dims.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 700 && size.height >= 520;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      ),
    );
  }

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
            child: _buildResultDisplay(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Container(
          width: 1,
          color: Theme.of(context).colorScheme.outline,
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  label: 'Результат',
                  withCard: false,
                  child: _buildResultDisplay(),
                ),
                const SizedBox(height: 20),
                _Section(
                  label: 'Формула',
                  withCard: false,
                  child: _FormulaHint(profile: _profile, grade: _grade),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    return ValueListenableBuilder<List<double>>(
      valueListenable: _dims,
      builder: (context, dimensions, _) => ResultDisplay(
        volumeMm3: _volumeFor(dimensions),
        densityGcm3: _grade?.density,
        linearMassKg: _linearMassFor(dimensions),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  final bool withCard;

  const _Section(
      {required this.label, required this.child, this.withCard = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
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
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: child,
          )
        else
          child,
      ],
    );
  }
}

class _FormulaHint extends StatelessWidget {
  final ProfileType profile;
  final Grade? grade;

  const _FormulaHint({
    required this.profile,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.functions_rounded,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Формула',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile.formula,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
          if (grade != null) ...[
            const SizedBox(height: 6),
            Text(
              'ρ = ${grade!.density} г/см³',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
