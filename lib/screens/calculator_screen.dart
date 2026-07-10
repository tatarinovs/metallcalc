import 'package:flutter/material.dart';
import '../services/prefs.dart';
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
  List<double> _dims = [0, 0, 0, 0, 0];

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
      setState(() {
        _profile = savedProfile;
      });
    }
  }

  double? get _volume =>
      _profile.calcVolume(_dims[0], _dims[1], _dims[2], _dims[3], _dims[4]);

  double? get _linearMass {
    if (_grade == null) return null;
    final probe = [..._dims];
    probe[_profile.lengthParamIndex] = 1000.0;
    
    final vol1m = _profile.calcVolume(
      probe[0], probe[1], probe[2], probe[3], probe[4]
    );
    
    if (vol1m == null) return null;
    return (vol1m / 1000.0) * _grade!.density / 1000.0;
  }

  void _onProfileChanged(ProfileType p) {
    if (_profile == p) return;
    setState(() {
      _profile = p;
      _dims = [0, 0, 0, 0, 0];
    });
    prefs.setString('selectedProfile', p.name);
  }

  void _onGradeChanged(Grade? g) {
    setState(() => _grade = g);
  }

  void _onDimsChanged(List<double> d) {
    setState(() {
      _dims = List.generate(5, (i) => i < d.length ? d[i] : 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
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
            child: ResultDisplay(
              volumeMm3: _volume,
              densityGcm3: _grade?.density,
              linearMassKg: _linearMass,
            ),
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
                    linearMassKg: _linearMass,
                  ),
                ),
                const SizedBox(height: 20),
                _Section(
                  label: 'Формула',
                  withCard: false,
                  child: _FormulaHint(
                      profile: _profile, grade: _grade, dims: _dims),
                ),
              ],
            ),
          ),
        ),
      ],
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
  final List<double> dims;

  const _FormulaHint({
    required this.profile,
    required this.grade,
    required this.dims,
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
            _getFormula(),
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
      case ProfileType.pipeSquare:
        return 'V = (A² − a²) × L\na = A − 2t\nm = V × ρ / 10⁶';
      case ProfileType.pipeRect:
        return 'V = (A×B − a×b) × L\na = A−2t,  b = B−2t\nm = V × ρ / 10⁶';
      case ProfileType.angle:
        return 'V = (2A·t − t²) × L\nm = V × ρ / 10⁶';
      case ProfileType.angleUnequal:
        return 'V = (A + B − t) × t × L\nm = V × ρ / 10⁶';
      case ProfileType.channel:
        return 'V = [s·(H−2t) + 2·B·t] × L\ns — стенка,  t — полка\nm = V × ρ / 10⁶';
      case ProfileType.ibeam:
        return 'V = [s·(H−2t) + 2·B·t] × L\ns — стенка,  t — полка\nm = V × ρ / 10⁶';
      case ProfileType.tbeam:
        return 'V = [B·t + s·(H−t)] × L\ns — стенка,  t — полка\nm = V × ρ / 10⁶';
    }
  }
}
