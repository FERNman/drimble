import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../common/build_context_extensions.dart';

@RoutePage()
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(context.l18n.faq_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l18n.faq_howIsTheBloodAlcoholLevelEstimated, style: context.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(context.l18n.faq_howIsTheBloodAlcoholLevelEstimatedText),
              const SizedBox(height: 24),
              Text(context.l18n.faq_doesTheEstimatedBACCorrespondToTheActualBAC, style: context.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(context.l18n.faq_doesTheEstimatedBACCorrespondToTheActualBACText),
              const SizedBox(height: 24),
              Text(context.l18n.faq_canTheAppReplaceABreathalyzer, style: context.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(context.l18n.faq_canTheAppReplaceABreathalyzerText),
            ],
          ),
        ),
      ),
    );
  }
}
