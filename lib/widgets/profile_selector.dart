import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/material_data.dart';
import '../theme/app_theme.dart';

class ProfileSelector extends StatelessWidget {
  final ProfileType selected;
  final ValueChanged<ProfileType> onChanged;

  const ProfileSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Row(
        children: ProfileType.values.map((p) {
          final isSelected = p == selected;
          final isLast = p == ProfileType.values.last;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent.withValues(alpha: 0.15)
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.accent : AppTheme.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileIcon(type: p, active: isSelected),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            p.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  final ProfileType type;
  final bool active;

  const _ProfileIcon({required this.type, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.accent : AppTheme.textSecondary;
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _ProfilePainter(type: type, color: color)),
    );
  }
}

class _ProfilePainter extends CustomPainter {
  final ProfileType type;
  final Color color;

  _ProfilePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dim = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case ProfileType.sheet:
        canvas.drawRect(Rect.fromLTWH(3, 7, w - 6, h - 11), stroke);
        // depth lines
        canvas.drawLine(const Offset(3, 7), Offset(1, 4), dim);
        canvas.drawLine(Offset(w - 3, 7), Offset(w - 1, 4), dim);
        canvas.drawLine(Offset(1, 4), Offset(w - 1, 4), dim);
        break;

      case ProfileType.circle:
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2 - 2, stroke);
        canvas.drawLine(
          Offset(w / 2, h / 2),
          Offset(w / 2 + (w / 2 - 2) * math.cos(-math.pi / 6),
              h / 2 + (h / 2 - 2) * math.sin(-math.pi / 6)),
          dim,
        );
        break;

      case ProfileType.square:
        canvas.drawRect(Rect.fromLTWH(2, 2, w - 4, h - 4), stroke);
        break;

      case ProfileType.hex:
        final cx = w / 2;
        final cy = h / 2;
        final r = w / 2 - 1.5;
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * math.pi / 180;
          final px = cx + r * math.cos(angle);
          final py = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, stroke);
        break;

      case ProfileType.pipe:
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2 - 1.5, stroke);
        canvas.drawCircle(
            Offset(w / 2, h / 2), w / 2 - 6.5, stroke..strokeWidth = 1.4);
        break;
    }
  }

  @override
  bool shouldRepaint(_ProfilePainter old) =>
      old.color != color || old.type != type;
}
