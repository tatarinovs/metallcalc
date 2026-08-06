import 'package:flutter_test/flutter_test.dart';
import 'package:metallcalc/models/material_data.dart';
import 'package:metallcalc/services/calculator.dart';

void main() {
  group('Profile volume', () {
    final cases = <({ProfileType profile, List<double> dims, double volume})>[
      (profile: ProfileType.sheet, dims: [2, 100, 1000], volume: 200000),
      (
        profile: ProfileType.circle,
        dims: [10, 1000],
        volume: 78539.81633974482,
      ),
      (profile: ProfileType.square, dims: [10, 1000], volume: 100000),
      (profile: ProfileType.hex, dims: [10, 1000], volume: 86602.54),
      (
        profile: ProfileType.pipe,
        dims: [10, 1, 1000],
        volume: 28274.33388230814,
      ),
      (
        profile: ProfileType.pipeSquare,
        dims: [10, 1, 1000],
        volume: 36000,
      ),
      (
        profile: ProfileType.pipeRect,
        dims: [20, 10, 1, 1000],
        volume: 56000,
      ),
      (profile: ProfileType.angle, dims: [10, 1, 1000], volume: 19000),
      (
        profile: ProfileType.angleUnequal,
        dims: [10, 20, 1, 1000],
        volume: 29000,
      ),
      (
        profile: ProfileType.channel,
        dims: [20, 10, 1, 2, 1000],
        volume: 56000,
      ),
      (
        profile: ProfileType.ibeam,
        dims: [20, 10, 1, 2, 1000],
        volume: 56000,
      ),
      (
        profile: ProfileType.tbeam,
        dims: [10, 20, 1, 2, 1000],
        volume: 38000,
      ),
    ];

    for (final testCase in cases) {
      test(testCase.profile.name, () {
        final dims = [...testCase.dims, 0.0, 0.0, 0.0, 0.0].take(5).toList();
        final volume = testCase.profile.calcVolume(
          dims[0],
          dims[1],
          dims[2],
          dims[3],
          dims[4],
        );

        expect(volume, closeTo(testCase.volume, 0.000001));
      });
    }
  });

  test('Invalid or incomplete geometry has no volume', () {
    expect(ProfileType.sheet.calcVolume(0, 100, 1000), isNull);
    expect(ProfileType.pipe.calcVolume(10, 5, 1000), isNull);
    expect(ProfileType.pipeRect.calcVolume(20, 10, 5, 1000), isNull);
    expect(ProfileType.channel.calcVolume(20, 10, 1, 10, 1000), isNull);
    expect(ProfileType.tbeam.calcVolume(10, 20, 10, 2, 1000), isNull);
  });

  test('Mass conversion uses millimetres and grams per cubic centimetre', () {
    expect(
      calculateMassKg(volumeMm3: 1000000, densityGcm3: 7.85),
      closeTo(7.85, 0.0000001),
    );
  });

  test('Linear mass replaces the profile length with one metre', () {
    expect(
      calculateLinearMassKg(
        profile: ProfileType.sheet,
        dimensions: [2, 100, 500],
        densityGcm3: 7.85,
      ),
      closeTo(1.57, 0.0000001),
    );
  });
}
