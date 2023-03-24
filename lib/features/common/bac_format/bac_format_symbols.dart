class BacFormatSymbols {
  final String pattern;
  final double multiplier;

  const BacFormatSymbols({
    required this.pattern,
    required this.multiplier,
  });
}

const _byVolumePercent = BacFormatSymbols(pattern: '0.0#\'%\'', multiplier: 1);
const _byVolumePermille = BacFormatSymbols(pattern: '0.0#\'‰\'', multiplier: 10);

const bacFormatSymbols = {
  'en': _byVolumePercent,
  'de': _byVolumePermille,
  'fr': _byVolumePermille,
};
