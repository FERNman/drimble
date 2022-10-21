extension NiceDouble on double {
  double ceilToNiceDouble() => (this * 2.0).ceilToDouble() / 2.0;
}
