import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

String _formatValue(double val, int decimals) {
  String s = val.toStringAsFixed(decimals);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0*$'), '');
    if (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
    }
  }
  return s;
}

class ResultDisplay extends StatelessWidget {
  final double? volumeMm3;   // объём в мм³
  final double? densityGcm3; // плотность г/см³

  const ResultDisplay({
    super.key,
    required this.volumeMm3,
    required this.densityGcm3,
  });

  String _formatMass(double kg) {
    if (kg < 0.001) {
      return '${_formatValue(kg * 1e6, 3)} мг';
    } else if (kg < 1.0) {
      return '${_formatValue(kg * 1000, 3)} г';
    } else if (kg >= 1000) {
      return '${_formatValue(kg / 1000, 3)} т';
    } else {
      return '${_formatValue(kg, 3)} кг';
    }
  }

  String _formatMassKg(double kg) {
    if (kg < 0.001) {
      return '${_formatValue(kg * 1e6, 3)} мг';
    }
    if (kg < 1.0) return '${_formatValue(kg * 1000, 3)} г';
    if (kg >= 1000) return '${_formatValue(kg / 1000, 3)} т';
    return '${_formatValue(kg, 3)} кг';
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = volumeMm3 != null && densityGcm3 != null;
    double? massKg;
    double? volumeCm3;

    if (hasResult) {
      volumeCm3 = volumeMm3! / 1000.0;          // мм³ → см³
      massKg = volumeCm3 * densityGcm3! / 1000; // г → кг
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: hasResult
          ? _ResultCard(
              key: ValueKey('${volumeCm3?.toStringAsFixed(4)}_${massKg?.toStringAsFixed(6)}'),
              volumeCm3: volumeCm3!,
              massKg: massKg!,
              formatMass: _formatMass,
              formatMassKg: _formatMassKg,
            )
          : _EmptyCard(
              key: const ValueKey('empty'),
              noMaterial: densityGcm3 == null,
              noDims: volumeMm3 == null && densityGcm3 != null,
            ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double volumeCm3;
  final double massKg;
  final String Function(double) formatMass;
  final String Function(double) formatMassKg;

  const _ResultCard({
    super.key,
    required this.volumeCm3,
    required this.massKg,
    required this.formatMass,
    required this.formatMassKg,
  });

  @override
  Widget build(BuildContext context) {
    final massStr = formatMass(massKg);
    final massFullStr = formatMassKg(massKg);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2137), Color(0xFF0A1628)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Результат',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: massFullStr));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Скопировано: $massFullStr',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppTheme.accentDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.only(bottom: 20, left: 60, right: 60),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 12, color: AppTheme.accent),
                      SizedBox(width: 4),
                      Text(
                        'Копировать',
                        style: TextStyle(color: AppTheme.accent, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Масса крупно
          Text(
            massStr,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          // Детали
          Row(
            children: [
              _MetricChip(
                label: 'Объём',
                value: volumeCm3 >= 1000
                    ? '${_formatValue(volumeCm3 / 1000, 3)} дм³'
                    : '${_formatValue(volumeCm3, 3)} см³',
                icon: Icons.view_in_ar_rounded,
              ),
              const SizedBox(width: 12),
              _MetricChip(
                label: 'Масса',
                value: '${_formatValue(massKg, 3)} кг',
                icon: Icons.monitor_weight_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _EmptyCard extends StatelessWidget {
  final bool noMaterial;
  final bool noDims;

  const _EmptyCard({super.key, required this.noMaterial, required this.noDims});

  @override
  Widget build(BuildContext context) {
    final msg = noMaterial
        ? 'Выберите материал и введите размеры'
        : 'Введите все размеры для расчёта';

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calculate_outlined,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
