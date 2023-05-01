class BacFormatSymbols {
  final String pattern;
  final double multiplier;

  const BacFormatSymbols({
    required this.pattern,
    required this.multiplier,
  });
}

const _byVolumePercent = BacFormatSymbols(pattern: '0.00\'%\'', multiplier: 0.1);
const _byVolumePermille = BacFormatSymbols(pattern: '0.00\'‰\'', multiplier: 1);

const bacFormatSymbols = {
  'en': _byVolumePermille,
  'de': _byVolumePermille,
  'fr': _byVolumePermille,
  'es': _byVolumePermille,
  'en_US': _byVolumePercent,
};
