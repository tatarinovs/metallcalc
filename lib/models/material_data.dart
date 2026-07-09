// Типы профилей проката
enum ProfileType {
  sheet,   // Лист
  circle,  // Круг
  square,  // Квадрат
  hex,     // Шестигранник
  pipe,    // Труба
}

extension ProfileTypeExt on ProfileType {
  String get label {
    switch (this) {
      case ProfileType.sheet:  return 'Лист';
      case ProfileType.circle: return 'Круг';
      case ProfileType.square: return 'Квадрат';
      case ProfileType.hex:    return 'Шестигранник';
      case ProfileType.pipe:   return 'Труба';
    }
  }

  /// Названия полей ввода (null = поле скрыто)
  List<String?> get fieldLabels {
    switch (this) {
      case ProfileType.sheet:
        return ['Толщина (мм)', 'Ширина (мм)', 'Длина (мм)'];
      case ProfileType.circle:
        return ['Диаметр (мм)', 'Длина (мм)', null];
      case ProfileType.square:
        return ['Сторона (мм)', 'Длина (мм)', null];
      case ProfileType.hex:
        return ['Ключ S (мм)', 'Длина (мм)', null];
      case ProfileType.pipe:
        return ['Ø наружный (мм)', 'Стенка (мм)', 'Длина (мм)'];
    }
  }

  /// Вычислить объём в мм³
  double? calcVolume(double a, double b, double c) {
    const pi = 3.141592653589793;
    switch (this) {
      case ProfileType.sheet:
        if (a > 0 && b > 0 && c > 0) return a * b * c;
        return null;
      case ProfileType.circle:
        if (a > 0 && b > 0) return (pi * a * a / 4) * b;
        return null;
      case ProfileType.square:
        if (a > 0 && b > 0) return a * a * b;
        return null;
      case ProfileType.hex:
        // S — ключ (расстояние между гранями), площадь = (√3/2)·S²
        if (a > 0 && b > 0) return (0.8660254 * a * a) * b;
        return null;
      case ProfileType.pipe:
        if (a > 0 && b > 0 && c > 0 && b < a / 2) {
          final inner = a - 2 * b;
          return (pi / 4) * (a * a - inner * inner) * c;
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

// Группа материала (Сталь, Медь и т.д.)
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
