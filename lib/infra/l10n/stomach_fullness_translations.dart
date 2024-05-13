import 'package:flutter/material.dart';

import '../../domain/diary/stomach_fullness.dart';
import '../../features/common/build_context_extensions.dart';

extension StomachFullnessTranslations on StomachFullness {
  String translate(BuildContext context) {
    switch (this) {
      case StomachFullness.empty:
        return context.l10n.common_stomachFullnessEmpty;
      case StomachFullness.litte:
        return context.l10n.common_stomachFullnessLittle;
      case StomachFullness.normal:
        return context.l10n.common_stomachFullnessNormal;
      case StomachFullness.full:
        return context.l10n.common_stomachFullnessFull;
    }
  }
}
