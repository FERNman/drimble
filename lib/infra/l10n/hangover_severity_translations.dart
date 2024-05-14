import 'package:flutter/material.dart';

import '../../domain/diary/hangover_severity.dart';
import '../../features/common/build_context_extensions.dart';

extension HangoverSeverityTranslations on HangoverSeverity {
  String translate(BuildContext context) {
    switch (this) {
      case HangoverSeverity.none:
        return context.l10n.common_hangoverSeverityNone;
      case HangoverSeverity.veryMild:
        return context.l10n.common_hangoverSeverityVeryMild;
      case HangoverSeverity.mild:
        return context.l10n.common_hangoverSeverityMild;
      case HangoverSeverity.moderate:
        return context.l10n.common_hangoverSeverityModerate;
      case HangoverSeverity.prettyBad:
        return context.l10n.common_hangoverSeverityPrettyBad;
      case HangoverSeverity.heavy:
        return context.l10n.common_hangoverSeverityHeavy;
      case HangoverSeverity.severe:
        return context.l10n.common_hangoverSeveritySevere;
    }
  }

  String icon() {
    switch (this) {
      case HangoverSeverity.none:
        return '🙂';
      case HangoverSeverity.veryMild:
        return '🙂';
      case HangoverSeverity.mild:
        return '😐';
      case HangoverSeverity.moderate:
        return '😕';
      case HangoverSeverity.prettyBad:
        return '🙁';
      case HangoverSeverity.heavy:
        return '😖';
      case HangoverSeverity.severe:
        return '🤯';
    }
  }
}
