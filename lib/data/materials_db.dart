import '../models/material_data.dart';

const List<MaterialGroup> materialsDb = [
  MaterialGroup(
    id: 'aluminum',
    name: 'Алюминий и сплавы',
    grades: [
      Grade(name: '1561 / АМг5 / АМг6 / АК12 / АК12М2', density: 2.65),
      Grade(name: 'А5 / А5М / А5Н / АД0 / АД1 / АД31', density: 2.71),
      Grade(name: 'АК4-1 / АК8 / АК8М / Д1 / Д1Т', density: 2.80),
      Grade(name: 'АК6', density: 2.75),
      Grade(name: 'АК7ч / АК9ч / АМг3', density: 2.66),
      Grade(name: 'АМг2', density: 2.69),
      Grade(name: 'АМц', density: 2.73),
      Grade(name: 'В95', density: 2.85),
      Grade(name: 'Д16', density: 2.77),
    ],
  ),
  MaterialGroup(
    id: 'bronze',
    name: 'Бронза',
    grades: [
      Grade(name: 'БрОЦС5-5-5', density: 8.80),
      Grade(name: 'БрАЖ9-4 / БрА9Ж3Л / БрА9Мц2Л', density: 7.60),
      Grade(name: 'БрА9Ж4Н4Мц1 / БрА10Ж3Мц2 / БрА10Ж4Н4Л', density: 7.50),
      Grade(name: 'БрНБТ', density: 8.83),
      Grade(name: 'БрБ2', density: 8.20),
      Grade(name: 'БрКМц3-1', density: 8.47),
    ],
  ),
  MaterialGroup(
    id: 'tungsten',
    name: 'Вольфрам',
    grades: [
      Grade(name: 'ВА / ВЧ', density: 19.30),
      Grade(name: 'ВНЖ7-3', density: 17.60),
    ],
  ),
  MaterialGroup(
    id: 'cadmium',
    name: 'Кадмий',
    grades: [
      Grade(name: 'Кд0 / Кд1', density: 8.65),
    ],
  ),
  MaterialGroup(
    id: 'brass',
    name: 'Латунь',
    grades: [
      Grade(name: 'Л60 / ЛС59-1', density: 8.40),
      Grade(name: 'Л63 / Л68 / ЛСД', density: 8.50),
      Grade(name: 'Л96', density: 8.90),
      Grade(name: 'ЛЖМц59-1-1 / ЛМц58-2', density: 8.30),
    ],
  ),
  MaterialGroup(
    id: 'copper',
    name: 'Медь',
    grades: [
      Grade(name: 'М00к / М1 / М2 / М3', density: 8.94),
    ],
  ),
  MaterialGroup(
    id: 'molybdenum',
    name: 'Молибден',
    grades: [
      Grade(name: 'МЧ / МВ (чистый)', density: 10.22),
    ],
  ),
  MaterialGroup(
    id: 'nickel',
    name: 'Никель',
    grades: [
      Grade(name: 'Н1 / Н2 / НПА', density: 8.90),
    ],
  ),
  MaterialGroup(
    id: 'solder',
    name: 'Припой',
    grades: [
      Grade(name: 'ПОС10', density: 10.80),
      Grade(name: 'ПОС40 / ПОССу40-0,5', density: 9.30),
      Grade(name: 'ПОС61 / ПОССу61-0,5', density: 8.50),
      Grade(name: 'ПОС90', density: 7.60),
      Grade(name: 'ПОСК50-18', density: 8.80),
      Grade(name: 'ПОССу15-2', density: 10.30),
      Grade(name: 'ПОССу18-0,5', density: 10.20),
      Grade(name: 'ПОССу18-2', density: 10.10),
      Grade(name: 'ПОССу25-0,5', density: 10.00),
      Grade(name: 'ПОССу25-2', density: 9.80),
      Grade(name: 'ПОССу30-0,5', density: 9.70),
      Grade(name: 'ПОССу30-2', density: 9.60),
      Grade(name: 'ПОССу35-0,5', density: 9.50),
      Grade(name: 'ПОССу35-2', density: 9.40),
      Grade(name: 'ПОССу4-6 / ПОССу10-2', density: 10.70),
      Grade(name: 'ПОССу40-2', density: 9.20),
      Grade(name: 'ПОССу5-1', density: 11.20),
      Grade(name: 'ПОССу50-0,5', density: 8.90),
      Grade(name: 'ПОССу8-3', density: 10.50),
      Grade(name: 'ПОССу95-5', density: 7.30),
    ],
  ),
  MaterialGroup(
    id: 'lead',
    name: 'Свинец',
    grades: [
      Grade(name: 'С0 / С1 / С2', density: 11.34),
    ],
  ),
  MaterialGroup(
    id: 'titanium',
    name: 'Титан и сплавы',
    grades: [
      Grade(name: 'ВТ20 / ОТ4', density: 4.40),
      Grade(name: 'ВТ6', density: 4.45),
      Grade(name: 'ВТ8', density: 4.48),
      Grade(name: 'ВТ1-0 / ВТ1-00', density: 4.51),
      Grade(name: 'ВТ22', density: 4.55),
    ],
  ),
  MaterialGroup(
    id: 'zinc',
    name: 'Цинк',
    grades: [
      Grade(name: 'Ц0 / ЦВ0', density: 7.13),
      Grade(name: 'ЦАМ4-1', density: 6.70),
    ],
  ),
  MaterialGroup(
    id: 'tin',
    name: 'Олово',
    grades: [
      Grade(name: 'О1 / О1пч', density: 7.30),
    ],
  ),
  MaterialGroup(
    id: 'steel_high_speed',
    name: 'Сталь быстрорежущая',
    grades: [
      Grade(name: 'Р6М5', density: 8.20),
      Grade(name: 'Р18', density: 8.75),
    ],
  ),
  MaterialGroup(
    id: 'steel_tool',
    name: 'Сталь инструментальная',
    grades: [
      Grade(name: 'У8 / У10', density: 7.83),
      Grade(name: 'ХВГ / 9ХС', density: 7.85),
    ],
  ),
  MaterialGroup(
    id: 'steel_alloy',
    name: 'Сталь легированная',
    grades: [
      Grade(name: '40Х / 30ХГСА', density: 7.85),
    ],
  ),
  MaterialGroup(
    id: 'steel_stainless',
    name: 'Сталь нержавеющая',
    grades: [
      Grade(name: '12Х18Н10Т / AISI 321', density: 7.92),
      Grade(name: '08Х18Н10 / AISI 304', density: 7.90),
      Grade(name: '10Х17Н13М2Т / AISI 316Ti', density: 7.96),
      Grade(name: '20Х13 / 40Х13 / 08Х17Т / AISI 430', density: 7.70),
    ],
  ),
  MaterialGroup(
    id: 'steel_low_alloy',
    name: 'Сталь низколегированная',
    grades: [
      Grade(name: '09Г2С / 10ХСНД', density: 7.85),
    ],
  ),
  MaterialGroup(
    id: 'steel_carbon',
    name: 'Сталь углеродистая',
    grades: [
      Grade(name: '65Г / СВ08А / Ст3пс / Ст20 / Ст45', density: 7.85),
    ],
  ),
  MaterialGroup(
    id: 'cast_iron_high_strength',
    name: 'Чугун высокопрочный',
    grades: [
      Grade(name: 'ВЧ40 / ВЧ50', density: 7.20),
    ],
  ),
  MaterialGroup(
    id: 'cast_iron_malleable',
    name: 'Чугун ковкий',
    grades: [
      Grade(name: 'КЧ30 / КЧ35', density: 7.30),
    ],
  ),
  MaterialGroup(
    id: 'cast_iron_grey',
    name: 'Чугун серый',
    grades: [
      Grade(name: 'АСЧ-4 / СЧ15 / СЧ20', density: 7.10),
    ],
  ),
];
