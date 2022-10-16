import 'package:flutter/material.dart';

import '../../domain/user/body_composition.dart';
import '../../features/common/build_context_extensions.dart';

extension BodyCompositionTranslations on BodyComposition {
  String translate(BuildContext context) {
    switch (this) {
      case BodyComposition.lean:
        return context.l18n.common_bodyCompositionLean;
      case BodyComposition.athletic:
        return context.l18n.common_bodyCompositionAthletic;
      case BodyComposition.average:
        return context.l18n.common_bodyCompositionAverage;
      case BodyComposition.overweight:
        return context.l18n.common_bodyCompositionOverweight;
    }
  }
}
