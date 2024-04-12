extension NiceDouble on double {
  double ceilToNearestTenth() => (this * 10.0).ceilToDouble() / 10.0;
}
