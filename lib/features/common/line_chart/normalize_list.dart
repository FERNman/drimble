extension NormalizeList on List<double> {
  normalize(double range) => map((e) => e / range).toList();
}
