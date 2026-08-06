import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/calculator.dart';

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
  final double? volumeMm3; // объём в мм³
  final double? densityGcm3; // плотность г/см³
  final double? linearMassKg; // масса 1 п.м.

  const ResultDisplay({
    super.key,
    required this.volumeMm3,
    required this.densityGcm3,
    this.linearMassKg,
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

  @override
  Widget build(BuildContext context) {
    final hasResult = volumeMm3 != null && densityGcm3 != null;
    double? massKg;
    double? volumeCm3;

    if (hasResult) {
      volumeCm3 = volumeMm3! / 1000.0; // мм³ → см³
      massKg = calculateMassKg(
        volumeMm3: volumeMm3!,
        densityGcm3: densityGcm3!,
      );
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
              key: ValueKey(
                  '${volumeCm3?.toStringAsFixed(4)}_${massKg?.toStringAsFixed(6)}'),
              volumeCm3: volumeCm3!,
              massKg: massKg!,
              linearMassKg: linearMassKg,
              formatMass: _formatMass,
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
  final double? linearMassKg;
  final String Function(double) formatMass;

  const _ResultCard({
    super.key,
    required this.volumeCm3,
    required this.massKg,
    this.linearMassKg,
    required this.formatMass,
  });

  @override
  Widget build(BuildContext context) {
    final massStr = formatMass(massKg);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? const [Color(0xFF0D2137), Color(0xFF0A1628)]
              : [colorScheme.surface, colorScheme.surfaceContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Теоретическая масса',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: massStr));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Скопировано: $massStr',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: colorScheme.secondary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.only(
                          bottom: 20, left: 60, right: 60),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                label: const Text('Копировать'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  textStyle: const TextStyle(fontSize: 11),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(44, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Масса крупно
          Text(
            massStr,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colorScheme.outline),
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
                label: 'Вес 1 п.м.',
                value: linearMassKg != null
                    ? '${_formatValue(linearMassKg!, 3)} кг'
                    : '---',
                icon: Icons.straighten_outlined,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;

    final msg = noMaterial
        ? 'Выберите материал и введите размеры'
        : 'Введите все размеры для расчёта';

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calculate_outlined,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
