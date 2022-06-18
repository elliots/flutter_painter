import 'dart:math';
import 'dart:ui';

class NoiseGenerator {
  static Set<Object> pathPointsToPencilPoints(
    List<Offset> path,
    double range,
  ) {
    if (path.isEmpty) return {[], []};
    path = normalizePath(path);
    Random random = Random(path.first.dx.toInt());

    List<Offset> points = [];
    List<double> opacities = [];
    for (var i in path) {
      var newPoints = generateNoise(i, range/1, random);
      points.addAll(newPoints.first as List<Offset>);
      opacities.addAll(newPoints.last as List<double>);
    }
    return {points, opacities};
  }

  /// Ensures each path point is at most 1 unit apart
  static List<Offset> normalizePath(List<Offset> path) {
  List<Offset> points = [];
  for (int i = 0; i < path.length - 1; i++) {
    var point1 = path[i];
    var point2 = path[i + 1];
    points.add(point1);

    double distanceX = point2.dx - point1.dx;
    double distanceY = point2.dy - point1.dy;
    double maxDistance = max(distanceX.abs(), distanceY.abs());
    int pointsToAdd = maxDistance ~/ 1;
    for (int p = 0; p < pointsToAdd; p++) {
      points.add(
        Offset(
          point1.dx + (distanceX / pointsToAdd) * p,
          point1.dy + (distanceY / pointsToAdd) * p,
        ),
      );
    }
  }
  return points;
  }

  /// Generate Noise
  static Set<Object> generateNoise(
    Offset initialOffset,
    double range,
    Random random,
  ) {
    List<Offset> points = [];
    List<double> opacities = [];
    for (int i = 0; i < 5; i++) {
      var percentOfRange1 = getPercentOfRange(range, random);
      var percentOfRange2 = getPercentOfRange(range, random);
      double opacity = 1 - max(percentOfRange1, percentOfRange2) * 0.4;
      points.add(Offset(addVariance(initialOffset.dx, percentOfRange1, range, random),
          addVariance(initialOffset.dy, percentOfRange2, range, random)));
      opacities.add(opacity);
    }
    return {points, opacities};
  }

  static double getPercentOfRange(double range, Random random) {
    double percentOfRange = random.nextInt(10000) / 10000;
    // convert uniform distribution to quadratic, more values close to 0
    percentOfRange = pow(percentOfRange, 2).toDouble();
    return percentOfRange;
  }

  static double addVariance(
    double source,
    double percentOfRange,
    double range,
    Random random,
  ) {
    // Plus or minus
    if (random.nextBool()) {
      return source + percentOfRange * range;
    } else {
      return source - percentOfRange * range;
    }
  }
}
