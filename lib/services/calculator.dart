import '../models/material_data.dart';

double calculateMassKg({
  required double volumeMm3,
  required double densityGcm3,
}) =>
    volumeMm3 * densityGcm3 / 1000000.0;

double? calculateLinearMassKg({
  required ProfileType profile,
  required List<double> dimensions,
  required double densityGcm3,
}) {
  final oneMeterDimensions = List<double>.generate(
    5,
    (index) => index < dimensions.length ? dimensions[index] : 0.0,
  );
  oneMeterDimensions[profile.lengthParamIndex] = 1000.0;

  final volumeMm3 = profile.calcVolume(
    oneMeterDimensions[0],
    oneMeterDimensions[1],
    oneMeterDimensions[2],
    oneMeterDimensions[3],
    oneMeterDimensions[4],
  );
  if (volumeMm3 == null) return null;

  return calculateMassKg(
    volumeMm3: volumeMm3,
    densityGcm3: densityGcm3,
  );
}
