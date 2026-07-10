import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/material_data.dart';
import '../theme/app_theme.dart';

// Профили, отображаемые отдельными кнопками
const _mainProfiles = [
  ProfileType.sheet,
];

// Прутки (сплошное сечение)
const _barOptions = [
  ProfileType.circle,
  ProfileType.hex,
  ProfileType.square,
];

// Подтипы труб
const _pipeOptions = [
  ProfileType.pipe,
  ProfileType.pipeSquare,
  ProfileType.pipeRect,
];

// Подтипы фасонного проката
const _structuralOptions = [
  ProfileType.angle,
  ProfileType.angleUnequal,
  ProfileType.channel,
  ProfileType.ibeam,
  ProfileType.tbeam,
];

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
        children: [
          // Обычные профили
          ..._mainProfiles.map((p) {
            final isSelected = p == selected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(p),
                  child: _ProfileButton(
                    type: p,
                    label: p.label,
                    isSelected: isSelected,
                  ),
                ),
              ),
            );
          }),

          // Кнопка «Пруток» (квадрат/шестигранник) с выпадающим меню
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _GroupDropdownButton(
                groupLabel: 'Пруток',
                options: _barOptions,
                selected: selected,
                onChanged: onChanged,
              ),
            ),
          ),

          // Кнопка «Труба» с выпадающим меню
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _GroupDropdownButton(
                groupLabel: 'Труба',
                options: _pipeOptions,
                selected: selected,
                onChanged: onChanged,
              ),
            ),
          ),

          // Кнопка «Фасонный» с выпадающим меню
          Expanded(
            child: _GroupDropdownButton(
              groupLabel: 'Фасонный',
              options: _structuralOptions,
              selected: selected,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Универсальная кнопка-группа с выпадающим меню
class _GroupDropdownButton extends StatelessWidget {
  final String groupLabel;
  final List<ProfileType> options;
  final ProfileType selected;
  final ValueChanged<ProfileType> onChanged;

  const _GroupDropdownButton({
    required this.groupLabel,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  bool get _isActive => options.contains(selected);
  ProfileType get _displayType => _isActive ? selected : options.first;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileType>(
      tooltip: '', // Убираем дефолтную подсказку "Show menu"
      offset: const Offset(0, 72),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.divider),
      ),
      elevation: 8,
      shadowColor: Colors.black54,
      itemBuilder: (context) => options
          .map(
            (p) => PopupMenuItem<ProfileType>(
              value: p,
              padding: EdgeInsets.zero,
              child: _DropdownMenuItem(
                type: p,
                isSelected: selected == p,
              ),
            ),
          )
          .toList(),
      onSelected: onChanged,
      child: _ProfileButton(
        type: _displayType,
        label: groupLabel,
        isSelected: _isActive,
        hasDropdown: true,
      ),
    );
  }
}

/// Пункт выпадающего меню
class _DropdownMenuItem extends StatelessWidget {
  final ProfileType type;
  final bool isSelected;

  const _DropdownMenuItem({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.accent : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CustomPaint(
              painter: _ProfilePainter(
                type: type,
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            type.label,
            style: TextStyle(
              color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, size: 16, color: AppTheme.accent),
          ],
        ],
      ),
    );
  }
}

/// Кнопка профиля (обычная или с маркером выпадающего меню)
class _ProfileButton extends StatelessWidget {
  final ProfileType type;
  final String label;
  final bool isSelected;
  final bool hasDropdown;

  const _ProfileButton({
    required this.type,
    required this.label,
    required this.isSelected,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? AppTheme.accent : AppTheme.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CustomPaint(
                    painter: _ProfilePainter(type: type, color: iconColor),
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasDropdown)
            Positioned(
              bottom: 4,
              right: 4,
              child: Icon(
                Icons.arrow_drop_down_rounded,
                size: 11,
                color: iconColor.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
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

    final innerStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case ProfileType.sheet:
        canvas.drawRect(Rect.fromLTWH(3, 7, w - 6, h - 11), stroke);
        canvas.drawLine(const Offset(3, 7), const Offset(1, 4), dim);
        canvas.drawLine(Offset(w - 3, 7), Offset(w - 1, 4), dim);
        canvas.drawLine(const Offset(1, 4), Offset(w - 1, 4), dim);
        break;

      case ProfileType.square:
        canvas.drawRect(Rect.fromLTWH(4, 4, w - 8, h - 8), stroke);
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

      // Труба круглая
      case ProfileType.pipe:
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2 - 1.5, stroke);
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2 - 6.5, innerStroke);
        break;

      // Труба квадратная
      case ProfileType.pipeSquare:
        canvas.drawRect(Rect.fromLTWH(1.5, 1.5, w - 3, h - 3), stroke);
        canvas.drawRect(Rect.fromLTWH(5.5, 5.5, w - 11, h - 11), innerStroke);
        break;

      // Труба прямоугольная
      case ProfileType.pipeRect:
        canvas.drawRect(Rect.fromLTWH(1, 4, w - 2, h - 8), stroke);
        canvas.drawRect(Rect.fromLTWH(4.5, 7.5, w - 9, h - 15), innerStroke);
        break;

      // Уголок равнополочный (L-форма, одинаковые плечи)
      case ProfileType.angle:
        final p = Path()
          ..moveTo(3, 3)
          ..lineTo(3, h - 3)
          ..lineTo(w - 3, h - 3);
        canvas.drawPath(p, stroke); // ignore: no_leading_underscores_for_local_identifiers
        break;

      // Уголок неравнополочный (короткая вертикальная плеча, длинная горизонтальная)
      case ProfileType.angleUnequal:
        final unequalPath = Path()
          ..moveTo(3, 3)
          ..lineTo(3, h - 3)
          ..lineTo(w - 1, h - 3);
        canvas.drawPath(unequalPath, stroke);
        break;

      // Швеллер (С-форма / U-форма в сечении)
      case ProfileType.channel:
        final channelPath = Path()
          ..moveTo(w - 4, 3)
          ..lineTo(3, 3)
          ..lineTo(3, h - 3)
          ..lineTo(w - 4, h - 3);
        canvas.drawPath(channelPath, stroke);
        break;

      // Двутавр (I-форма в сечении)
      case ProfileType.ibeam:
        // верхняя полка
        canvas.drawLine(const Offset(2, 3), Offset(w - 2, 3), stroke);
        // стенка
        canvas.drawLine(Offset(w / 2, 3), Offset(w / 2, h - 3), stroke);
        // нижняя полка
        canvas.drawLine(Offset(2, h - 3), Offset(w - 2, h - 3), stroke);
        break;

      // Тавр (T-форма в сечении)
      case ProfileType.tbeam:
        // верхняя полка
        canvas.drawLine(const Offset(2, 3), Offset(w - 2, 3), stroke);
        // стенка
        canvas.drawLine(Offset(w / 2, 3), Offset(w / 2, h - 3), stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(_ProfilePainter old) =>
      old.color != color || old.type != type;
}
