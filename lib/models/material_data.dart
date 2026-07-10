// Типы профилей проката
enum ProfileType {
  sheet,    // Лист
  circle,   // Круг
  square,   // Квадрат сплошной
  hex,      // Шестигранник
  // --- Трубы ---
  pipe,         // Труба круглая
  pipeSquare,   // Труба квадратная
  pipeRect,     // Труба прямоугольная
  // --- Фасонный прокат ---
  angle,        // Уголок равнополочный
  angleUnequal, // Уголок неравнополочный
  channel,      // Швеллер
  ibeam,        // Двутавр
  tbeam,        // Тавр
}

extension ProfileTypeExt on ProfileType {
  String get label {
    switch (this) {
      case ProfileType.sheet:         return 'Лист';
      case ProfileType.circle:        return 'Круг';
      case ProfileType.square:        return 'Квадрат';
      case ProfileType.hex:           return 'Шестигранник';
      case ProfileType.pipe:          return 'Круглая';
      case ProfileType.pipeSquare:    return 'Квадратная';
      case ProfileType.pipeRect:      return 'Прямоугольная';
      case ProfileType.angle:         return 'Равнополочный';
      case ProfileType.angleUnequal:  return 'Неравнополочный';
      case ProfileType.channel:       return 'Швеллер';
      case ProfileType.ibeam:         return 'Двутавр';
      case ProfileType.tbeam:         return 'Тавр';
    }
  }

  /// Признак — подтип трубы
  bool get isPipeVariant =>
      this == ProfileType.pipe ||
      this == ProfileType.pipeSquare ||
      this == ProfileType.pipeRect;

  /// Признак — фасонный прокат (профиль)
  bool get isStructuralVariant =>
      this == ProfileType.angle ||
      this == ProfileType.angleUnequal ||
      this == ProfileType.channel ||
      this == ProfileType.ibeam ||
      this == ProfileType.tbeam;

  /// Индекс поля «Длина (мм)» (оно всегда последнее активное)
  int get lengthParamIndex => fieldLabels.where((l) => l != null).length - 1;

  /// Названия полей ввода (null = поле скрыто); длина всегда 5.
  /// Поля расположены в порядке передачи в calcVolume: a, b, c, d, e
  List<String?> get fieldLabels {
    switch (this) {
      case ProfileType.sheet:
        return ['Толщина (мм)', 'Ширина (мм)', 'Длина (мм)', null, null];
      case ProfileType.circle:
        return ['Ø (мм)', 'Длина (мм)', null, null, null];
      case ProfileType.square:
        return ['Сторона A (мм)', 'Длина (мм)', null, null, null];
      case ProfileType.hex:
        return ['Ключ S (мм)', 'Длина (мм)', null, null, null];
      case ProfileType.pipe:
        return ['Ø нар. (мм)', 'Стенка (мм)', 'Длина (мм)', null, null];
      case ProfileType.pipeSquare:
        return ['Сторона A (мм)', 'Стенка (мм)', 'Длина (мм)', null, null];
      case ProfileType.pipeRect:
        return ['Ширина A (мм)', 'Высота B (мм)', 'Стенка (мм)', 'Длина (мм)', null];
      case ProfileType.angle:
        return ['Полка A (мм)', 'Толщина (мм)', 'Длина (мм)', null, null];
      case ProfileType.angleUnequal:
        return ['Полка A (мм)', 'Полка B (мм)', 'Толщ. (мм)', 'Длина (мм)', null];
      case ProfileType.tbeam:
        // a=B (ширина полки), b=H (высота), c=s (стенка), d=t (полка), e=L
        return ['Ширина B (мм)', 'Высота H (мм)', 'Стенка (мм)', 'Полка (мм)', 'Длина (мм)'];
      case ProfileType.channel:
      case ProfileType.ibeam:
        // a=H, b=B, c=s (стенка), d=t (полка), e=L
        return ['Высота H (мм)', 'Ширина B (мм)', 'Стенка (мм)', 'Полка (мм)', 'Длина (мм)'];
    }
  }

  /// Вычислить объём в мм³.
  /// a..e — до 5 размеров; неиспользуемые = 0.
  double? calcVolume(double a, double b, double c,
      [double d = 0, double e = 0]) {
    const pi = 3.141592653589793;
    switch (this) {

      case ProfileType.sheet:
        // a=толщина, b=ширина, c=длина
        if (a > 0 && b > 0 && c > 0) return a * b * c;
        return null;

      case ProfileType.circle:
        // a=D, b=L
        if (a > 0 && b > 0) return (pi * a * a / 4) * b;
        return null;

      case ProfileType.square:
        // a=A, b=L
        if (a > 0 && b > 0) return (a * a) * b;
        return null;

      case ProfileType.hex:
        // a=S (ключ), b=L
        if (a > 0 && b > 0) return (0.8660254 * a * a) * b;
        return null;

      case ProfileType.pipe:
        // a=D, b=t, c=L
        if (a > 0 && b > 0 && c > 0 && b < a / 2) {
          final inner = a - 2 * b;
          return (pi / 4) * (a * a - inner * inner) * c;
        }
        return null;

      case ProfileType.pipeSquare:
        // a=A (сторона), b=t, c=L
        if (a > 0 && b > 0 && c > 0 && b < a / 2) {
          final inner = a - 2 * b;
          return (a * a - inner * inner) * c;
        }
        return null;

      case ProfileType.pipeRect:
        // a=A, b=B, c=t, d=L
        if (a > 0 && b > 0 && c > 0 && d > 0 && c < a / 2 && c < b / 2) {
          final iA = a - 2 * c;
          final iB = b - 2 * c;
          return (a * b - iA * iB) * d;
        }
        return null;

      case ProfileType.angle:
        // a=A, b=t, c=L
        if (a > 0 && b > 0 && c > 0 && b < a) {
          return (2 * a * b - b * b) * c;
        }
        return null;

      case ProfileType.angleUnequal:
        // a=A, b=B, c=t, d=L
        if (a > 0 && b > 0 && c > 0 && d > 0 && c <= a && c <= b) {
          return (a + b - c) * c * d;
        }
        return null;

      case ProfileType.tbeam:
        // a=B, b=H, c=s (стенка), d=t (полка), e=L
        // Площадь = B*t + s*(H-t)
        if (a > 0 && b > 0 && c > 0 && d > 0 && e > 0 &&
            d < b && c < a) {
          final area = a * d + c * (b - d);
          return area * e;
        }
        return null;

      case ProfileType.channel:
      case ProfileType.ibeam:
        // a=H, b=B, c=s (стенка), d=t (полка), e=L
        // Площадь = s·(H−2t) + 2·B·t
        if (a > 0 && b > 0 && c > 0 && d > 0 && e > 0 &&
            2 * d < a && c < b) {
          final area = c * (a - 2 * d) + 2 * b * d;
          return area * e;
        }
        return null;
    }
  }
}

// Марка материала
class Grade {
  final String name;
  final double density; // г/см³

  const Grade({required this.name, required this.density});
}

// Группа материала
class MaterialGroup {
  final String id;
  final String name;
  final List<Grade> grades;

  const MaterialGroup({
    required this.id,
    required this.name,
    required this.grades,
  });
}
