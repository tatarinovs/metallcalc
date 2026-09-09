// Портировано 1:1 из lib/data/materials_db.dart
export const materialsDb = [
  {
    id: 'aluminum',
    name: 'Алюминий и сплавы',
    grades: [
      { name: '1561 / АМг5 / АМг6 / АК12 / АК12М2', density: 2.65 },
      { name: 'А5 / А5М / А5Н / АД0 / АД1 / АД31', density: 2.71 },
      { name: 'АК4-1 / АК8 / АК8М / Д1 / Д1Т', density: 2.80 },
      { name: 'АК6', density: 2.75 },
      { name: 'АК7ч / АК9ч / АМг3', density: 2.66 },
      { name: 'АМг2', density: 2.69 },
      { name: 'АМц', density: 2.73 },
      { name: 'В95', density: 2.85 },
      { name: 'Д16', density: 2.77 },
    ],
  },
  {
    id: 'bronze',
    name: 'Бронза',
    grades: [
      { name: 'БрОЦС5-5-5', density: 8.80 },
      { name: 'БрАЖ9-4 / БрА9Ж3Л / БрА9Мц2Л', density: 7.60 },
      { name: 'БрА9Ж4Н4Мц1 / БрА10Ж3Мц2 / БрА10Ж4Н4Л', density: 7.50 },
      { name: 'БрНБТ', density: 8.83 },
      { name: 'БрБ2', density: 8.20 },
      { name: 'БрКМц3-1', density: 8.47 },
    ],
  },
  {
    id: 'tungsten',
    name: 'Вольфрам',
    grades: [
      { name: 'ВА / ВЧ', density: 19.30 },
      { name: 'ВНЖ7-3', density: 17.60 },
    ],
  },
  {
    id: 'cadmium',
    name: 'Кадмий',
    grades: [{ name: 'Кд0 / Кд1', density: 8.65 }],
  },
  {
    id: 'brass',
    name: 'Латунь',
    grades: [
      { name: 'Л60 / ЛС59-1', density: 8.40 },
      { name: 'Л63 / Л68 / ЛСД', density: 8.50 },
      { name: 'Л96', density: 8.90 },
      { name: 'ЛЖМц59-1-1 / ЛМц58-2', density: 8.30 },
    ],
  },
  {
    id: 'copper',
    name: 'Медь',
    grades: [{ name: 'М00к / М1 / М2 / М3', density: 8.94 }],
  },
  {
    id: 'molybdenum',
    name: 'Молибден',
    grades: [{ name: 'МЧ / МВ (чистый)', density: 10.22 }],
  },
  {
    id: 'nickel',
    name: 'Никель',
    grades: [{ name: 'Н1 / Н2 / НПА', density: 8.90 }],
  },
  {
    id: 'solder',
    name: 'Припой',
    grades: [
      { name: 'ПОС10', density: 10.80 },
      { name: 'ПОС40 / ПОССу40-0,5', density: 9.30 },
      { name: 'ПОС61 / ПОССу61-0,5', density: 8.50 },
      { name: 'ПОС90', density: 7.60 },
      { name: 'ПОСК50-18', density: 8.80 },
      { name: 'ПОССу15-2', density: 10.30 },
      { name: 'ПОССу18-0,5', density: 10.20 },
      { name: 'ПОССу18-2', density: 10.10 },
      { name: 'ПОССу25-0,5', density: 10.00 },
      { name: 'ПОССу25-2', density: 9.80 },
      { name: 'ПОССу30-0,5', density: 9.70 },
      { name: 'ПОССу30-2', density: 9.60 },
      { name: 'ПОССу35-0,5', density: 9.50 },
      { name: 'ПОССу35-2', density: 9.40 },
      { name: 'ПОССу4-6 / ПОССу10-2', density: 10.70 },
      { name: 'ПОССу40-2', density: 9.20 },
      { name: 'ПОССу5-1', density: 11.20 },
      { name: 'ПОССу50-0,5', density: 8.90 },
      { name: 'ПОССу8-3', density: 10.50 },
      { name: 'ПОССу95-5', density: 7.30 },
    ],
  },
  {
    id: 'lead',
    name: 'Свинец',
    grades: [{ name: 'С0 / С1 / С2', density: 11.34 }],
  },
  {
    id: 'titanium',
    name: 'Титан и сплавы',
    grades: [
      { name: 'ВТ20 / ОТ4', density: 4.40 },
      { name: 'ВТ6', density: 4.45 },
      { name: 'ВТ8', density: 4.48 },
      { name: 'ВТ1-0 / ВТ1-00', density: 4.51 },
      { name: 'ВТ22', density: 4.55 },
    ],
  },
  {
    id: 'zinc',
    name: 'Цинк',
    grades: [
      { name: 'Ц0 / ЦВ0', density: 7.13 },
      { name: 'ЦАМ4-1', density: 6.70 },
    ],
  },
  {
    id: 'tin',
    name: 'Олово',
    grades: [{ name: 'О1 / О1пч', density: 7.30 }],
  },
  {
    id: 'steel_high_speed',
    name: 'Сталь быстрорежущая',
    grades: [
      { name: 'Р6М5', density: 8.20 },
      { name: 'Р18', density: 8.75 },
    ],
  },
  {
    id: 'steel_tool',
    name: 'Сталь инструментальная',
    grades: [
      { name: 'У8 / У10', density: 7.83 },
      { name: 'ХВГ / 9ХС', density: 7.85 },
    ],
  },
  {
    id: 'steel_alloy',
    name: 'Сталь легированная',
    grades: [{ name: '40Х / 30ХГСА', density: 7.85 }],
  },
  {
    id: 'steel_stainless',
    name: 'Сталь нержавеющая',
    grades: [
      { name: '12Х18Н10Т / AISI 321', density: 7.92 },
      { name: '08Х18Н10 / AISI 304', density: 7.90 },
      { name: '10Х17Н13М2Т / AISI 316Ti', density: 7.96 },
      { name: '20Х13 / 40Х13 / 08Х17Т / AISI 430', density: 7.70 },
    ],
  },
  {
    id: 'steel_low_alloy',
    name: 'Сталь низколегированная',
    grades: [{ name: '09Г2С / 10ХСНД', density: 7.85 }],
  },
  {
    id: 'steel_carbon',
    name: 'Сталь углеродистая',
    grades: [{ name: '65Г / СВ08А / Ст3пс / Ст20 / Ст45', density: 7.85 }],
  },
  {
    id: 'cast_iron_high_strength',
    name: 'Чугун высокопрочный',
    grades: [{ name: 'ВЧ40 / ВЧ50', density: 7.20 }],
  },
  {
    id: 'cast_iron_malleable',
    name: 'Чугун ковкий',
    grades: [{ name: 'КЧ30 / КЧ35', density: 7.30 }],
  },
  {
    id: 'cast_iron_grey',
    name: 'Чугун серый',
    grades: [{ name: 'АСЧ-4 / СЧ15 / СЧ20', density: 7.10 }],
  },
];
