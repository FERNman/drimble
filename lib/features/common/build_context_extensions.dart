import 'package:flutter/material.dart';

import '../../infra/l18n/l10n.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  AppLocalizations get l18n => AppLocalizations.of(this)!;
}
