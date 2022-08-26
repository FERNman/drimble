extension CopyDuration on Duration {
  Duration copyWith({
    int? year,
    int? month,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? milliseconds,
    int? microseconds,
  }) {
    return Duration(
      days: days ?? inDays,
      hours: hours ?? inHours.remainder(24),
      minutes: minutes ?? inMinutes.remainder(60),
      seconds: seconds ?? inSeconds.remainder(60),
      milliseconds: milliseconds ?? inMilliseconds.remainder(100),
      microseconds: microseconds ?? inMicroseconds.remainder(100),
    );
  }
}
