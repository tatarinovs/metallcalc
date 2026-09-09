import { calcVolume, getLengthParamIndex } from './materialData.js';

/** масса (кг) из объёма (мм³) и плотности (г/см³) */
export function calculateMassKg({ volumeMm3, densityGcm3 }) {
  return (volumeMm3 * densityGcm3) / 1_000_000.0;
}

/** масса 1 погонного метра проката (кг), null если размеры неполны */
export function calculateLinearMassKg({ profile, dimensions, densityGcm3 }) {
  const oneMeterDims = [0, 1, 2, 3, 4].map((i) => dimensions[i] ?? 0);
  oneMeterDims[getLengthParamIndex(profile)] = 1000.0;

  const volumeMm3 = calcVolume(profile, oneMeterDims);
  if (volumeMm3 == null) return null;

  return calculateMassKg({ volumeMm3, densityGcm3 });
}
