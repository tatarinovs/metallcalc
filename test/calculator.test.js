import { describe, it, expect } from 'vitest';
import { ProfileType, calcVolume } from '../src/lib/materialData.js';
import { calculateMassKg, calculateLinearMassKg } from '../src/lib/calculator.js';

describe('Profile volume calculation', () => {
  const cases = [
    { profile: ProfileType.sheet, dims: [2, 100, 1000], volume: 200000 },
    {
      profile: ProfileType.circle,
      dims: [10, 1000],
      volume: 78539.81633974482,
    },
    { profile: ProfileType.square, dims: [10, 1000], volume: 100000 },
    { profile: ProfileType.hex, dims: [10, 1000], volume: 86602.54 },
    {
      profile: ProfileType.pipe,
      dims: [10, 1, 1000],
      volume: 28274.33388230814,
    },
    {
      profile: ProfileType.pipeSquare,
      dims: [10, 1, 1000],
      volume: 36000,
    },
    {
      profile: ProfileType.pipeRect,
      dims: [20, 10, 1, 1000],
      volume: 56000,
    },
    { profile: ProfileType.angle, dims: [10, 1, 1000], volume: 19000 },
    {
      profile: ProfileType.angleUnequal,
      dims: [10, 20, 1, 1000],
      volume: 29000,
    },
    {
      profile: ProfileType.channel,
      dims: [20, 10, 1, 2, 1000],
      volume: 56000,
    },
    {
      profile: ProfileType.ibeam,
      dims: [20, 10, 1, 2, 1000],
      volume: 56000,
    },
    {
      profile: ProfileType.tbeam,
      dims: [10, 20, 1, 2, 1000],
      volume: 38000,
    },
  ];

  for (const testCase of cases) {
    it(`calculates volume for ${testCase.profile}`, () => {
      const fullDims = [0, 0, 0, 0, 0];
      testCase.dims.forEach((val, idx) => {
        fullDims[idx] = val;
      });
      const volume = calcVolume(testCase.profile, fullDims);
      expect(volume).toBeCloseTo(testCase.volume, 5);
    });
  }
});

describe('Invalid or incomplete geometry has no volume', () => {
  it('returns null for sheet with zero thickness', () => {
    expect(calcVolume(ProfileType.sheet, [0, 100, 1000, 0, 0])).toBeNull();
  });

  it('returns null for pipe with wall thickness >= radius', () => {
    expect(calcVolume(ProfileType.pipe, [10, 5, 1000, 0, 0])).toBeNull();
  });

  it('returns null for pipeRect with invalid wall thickness', () => {
    expect(calcVolume(ProfileType.pipeRect, [20, 10, 5, 1000, 0])).toBeNull();
  });

  it('returns null for channel with invalid geometry', () => {
    expect(calcVolume(ProfileType.channel, [20, 10, 1, 10, 1000])).toBeNull();
  });

  it('returns null for tbeam with invalid geometry', () => {
    expect(calcVolume(ProfileType.tbeam, [10, 20, 10, 2, 1000])).toBeNull();
  });
});

describe('Mass calculation', () => {
  it('Mass conversion uses millimetres and grams per cubic centimetre', () => {
    const mass = calculateMassKg({ volumeMm3: 1000000, densityGcm3: 7.85 });
    expect(mass).toBeCloseTo(7.85, 7);
  });

  it('Linear mass replaces the profile length with one metre', () => {
    const linearMass = calculateLinearMassKg({
      profile: ProfileType.sheet,
      dimensions: [2, 100, 500, 0, 0],
      densityGcm3: 7.85,
    });
    expect(linearMass).toBeCloseTo(1.57, 7);
  });
});
