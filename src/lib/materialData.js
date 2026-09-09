// Типы профилей проката — портировано из lib/models/material_data.dart
export const ProfileType = Object.freeze({
  sheet: 'sheet', // Лист
  circle: 'circle', // Круг
  square: 'square', // Квадрат сплошной
  hex: 'hex', // Шестигранник
  pipe: 'pipe', // Труба круглая
  pipeSquare: 'pipeSquare', // Труба квадратная
  pipeRect: 'pipeRect', // Труба прямоугольная
  angle: 'angle', // Уголок равнополочный
  angleUnequal: 'angleUnequal', // Уголок неравнополочный
  channel: 'channel', // Швеллер
  ibeam: 'ibeam', // Двутавр
  tbeam: 'tbeam', // Тавр
});

const PI = Math.PI;

// Каждая запись: label, formula (текст с \n), fieldLabels (длина всегда 5, null = скрыто),
// calcVolume(a,b,c,d,e) -> число (мм³) | null
const META = {
  [ProfileType.sheet]: {
    label: 'Лист',
    formula: 'V = A × B × L\nm = V × ρ / 10⁶',
    fieldLabels: ['Толщина (мм)', 'Ширина (мм)', 'Длина (мм)', null, null],
    calcVolume: (a, b, c) => (a > 0 && b > 0 && c > 0 ? a * b * c : null),
  },
  [ProfileType.circle]: {
    label: 'Круг',
    formula: 'V = π × D² / 4 × L\nm = V × ρ / 10⁶',
    fieldLabels: ['Ø (мм)', 'Длина (мм)', null, null, null],
    calcVolume: (a, b) => (a > 0 && b > 0 ? ((PI * a * a) / 4) * b : null),
  },
  [ProfileType.square]: {
    label: 'Квадрат',
    formula: 'V = A² × L\nm = V × ρ / 10⁶',
    fieldLabels: ['Сторона A (мм)', 'Длина (мм)', null, null, null],
    calcVolume: (a, b) => (a > 0 && b > 0 ? a * a * b : null),
  },
  [ProfileType.hex]: {
    label: 'Шестигранник',
    formula: 'V = (√3/2) × S² × L\nm = V × ρ / 10⁶',
    fieldLabels: ['Ключ S (мм)', 'Длина (мм)', null, null, null],
    calcVolume: (a, b) => (a > 0 && b > 0 ? 0.8660254 * a * a * b : null),
  },
  [ProfileType.pipe]: {
    label: 'Круглая',
    formula: 'V = π/4 × (D² − d²) × L\nd = D − 2t\nm = V × ρ / 10⁶',
    fieldLabels: ['Ø нар. (мм)', 'Стенка (мм)', 'Длина (мм)', null, null],
    calcVolume: (a, b, c) => {
      if (a > 0 && b > 0 && c > 0 && b < a / 2) {
        const inner = a - 2 * b;
        return (PI / 4) * (a * a - inner * inner) * c;
      }
      return null;
    },
  },
  [ProfileType.pipeSquare]: {
    label: 'Квадратная',
    formula: 'V = (A² − a²) × L\na = A − 2t\nm = V × ρ / 10⁶',
    fieldLabels: ['Сторона A (мм)', 'Стенка (мм)', 'Длина (мм)', null, null],
    calcVolume: (a, b, c) => {
      if (a > 0 && b > 0 && c > 0 && b < a / 2) {
        const inner = a - 2 * b;
        return (a * a - inner * inner) * c;
      }
      return null;
    },
  },
  [ProfileType.pipeRect]: {
    label: 'Прямоугольная',
    formula: 'V = (A×B − a×b) × L\na = A−2t,  b = B−2t\nm = V × ρ / 10⁶',
    fieldLabels: ['Ширина A (мм)', 'Высота B (мм)', 'Стенка (мм)', 'Длина (мм)', null],
    calcVolume: (a, b, c, d) => {
      if (a > 0 && b > 0 && c > 0 && d > 0 && c < a / 2 && c < b / 2) {
        const iA = a - 2 * c;
        const iB = b - 2 * c;
        return (a * b - iA * iB) * d;
      }
      return null;
    },
  },
  [ProfileType.angle]: {
    label: 'Равнополочный',
    formula: 'V = (2A·t − t²) × L\nm = V × ρ / 10⁶',
    fieldLabels: ['Полка A (мм)', 'Толщина (мм)', 'Длина (мм)', null, null],
    calcVolume: (a, b, c) => {
      if (a > 0 && b > 0 && c > 0 && b < a) {
        return (2 * a * b - b * b) * c;
      }
      return null;
    },
  },
  [ProfileType.angleUnequal]: {
    label: 'Неравнополочный',
    formula: 'V = (A + B − t) × t × L\nm = V × ρ / 10⁶',
    fieldLabels: ['Полка A (мм)', 'Полка B (мм)', 'Толщ. (мм)', 'Длина (мм)', null],
    calcVolume: (a, b, c, d) => {
      if (a > 0 && b > 0 && c > 0 && d > 0 && c <= a && c <= b) {
        return (a + b - c) * c * d;
      }
      return null;
    },
  },
  [ProfileType.channel]: {
    label: 'Швеллер',
    formula: 'V = [s·(H−2t) + 2·B·t] × L\ns — стенка,  t — полка\nm = V × ρ / 10⁶',
    fieldLabels: ['Высота H (мм)', 'Ширина B (мм)', 'Стенка (мм)', 'Полка (мм)', 'Длина (мм)'],
    calcVolume: (a, b, c, d, e) => {
      if (a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && 2 * d < a && c < b) {
        const area = c * (a - 2 * d) + 2 * b * d;
        return area * e;
      }
      return null;
    },
  },
  [ProfileType.ibeam]: {
    label: 'Двутавр',
    formula: 'V = [s·(H−2t) + 2·B·t] × L\ns — стенка,  t — полка\nm = V × ρ / 10⁶',
    fieldLabels: ['Высота H (мм)', 'Ширина B (мм)', 'Стенка (мм)', 'Полка (мм)', 'Длина (мм)'],
    calcVolume: (a, b, c, d, e) => {
      if (a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && 2 * d < a && c < b) {
        const area = c * (a - 2 * d) + 2 * b * d;
        return area * e;
      }
      return null;
    },
  },
  [ProfileType.tbeam]: {
    label: 'Тавр',
    formula: 'V = [B·t + s·(H−t)] × L\ns — стенка,  t — полка\nm = V × ρ / 10⁶',
    fieldLabels: ['Ширина B (мм)', 'Высота H (мм)', 'Стенка (мм)', 'Полка (мм)', 'Длина (мм)'],
    calcVolume: (a, b, c, d, e) => {
      if (a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && d < b && c < a) {
        const area = a * d + c * (b - d);
        return area * e;
      }
      return null;
    },
  },
};

export function getLabel(profile) {
  return META[profile].label;
}

export function getFormula(profile) {
  return META[profile].formula;
}

/** Список из 5 подписей полей (null = поле скрыто), в порядке a,b,c,d,e */
export function getFieldLabels(profile) {
  return META[profile].fieldLabels;
}

/** Индекс поля «Длина», оно всегда последнее активное */
export function getLengthParamIndex(profile) {
  return getFieldLabels(profile).filter((l) => l != null).length - 1;
}

/** Вычислить объём в мм³. dims — массив из 5 чисел (неиспользуемые = 0). */
export function calcVolume(profile, dims) {
  const [a, b, c, d, e] = dims;
  return META[profile].calcVolume(a, b, c, d, e) ?? null;
}

export const ALL_PROFILE_TYPES = Object.values(ProfileType);
