import 'dart:math';
import 'dart:ui';

class DotPoint {
  final Offset position;
  final double size;
  final double opacity;

  DotPoint(this.position, this.size, this.opacity);
}

class NoiseGenerator {
  static List<DotPoint> pathPointsToPencilPoints(
    List<Offset> path,
    double range,
    bool normalizeDistanceBetweenPoints,
    double distributionExponent,
  ) {
    if (path.isEmpty) {
      return [];
    }
    if (normalizeDistanceBetweenPoints) {
      path = normalizePath(path);
    }
    if (path.isEmpty) {
      return [];
    }

    Random random = Random(path.first.dx.toInt());

    List<DotPoint> dotPoints = [];
    for (var point in path) {
      for (int i = 0; i < 5; i++) {
        var percentOfRange1 = getPercentOfRange(range, random, distributionExponent);
        var percentOfRange2 = getPercentOfRange(range, random, distributionExponent);

        double opacity = 1 - max(percentOfRange1, percentOfRange2) * 0.4;
        double size = range / 6 * max(percentOfRange1, percentOfRange2) * 0.4;
        var offset = Offset(addVariance(point.dx, percentOfRange1, range, random),
            addVariance(point.dy, percentOfRange2, range, random));

        dotPoints.add(DotPoint(offset, size, opacity));
      }
    }
    return dotPoints;
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

  static double getPercentOfRange(double range, Random random, double exponent) {
    double percentOfRange = random.nextInt(10000) / 10000;
    // convert uniform distribution to quadratic, more values close to 0
    percentOfRange = pow(percentOfRange, exponent).toDouble();
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
