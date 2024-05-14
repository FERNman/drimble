import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/hangover_severity.dart';
import '../../infra/l10n/hangover_severity_translations.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/extended_app_bar.dart';
import 'select_hangover_severity_cubit.dart';
import 'widgets/hangover_severity_slider.dart';

@RoutePage<HangoverSeverity>()
class SelectHangoverSeverityPage extends StatelessWidget implements AutoRouteWrapper {
  const SelectHangoverSeverityPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => SelectHangoverSeverityCubit(),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExtendedAppBar.medium(
        leading: const CloseButton(),
        title: Text(context.l10n.track_hangover_severity_title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 24, right: 16),
        child: Column(
          children: [
            Text(context.l10n.track_hangover_severity_description),
            const SizedBox(height: 32),
            _buildHangoverSeveritySelection(),
            const Spacer(),
            _buildSaveButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHangoverSeveritySelection() {
    return BlocBuilder<SelectHangoverSeverityCubit, SelectHangoverSeverityState>(
      builder: (context, state) {
        final labelTextStyle = context.textTheme.labelLarge?.copyWith(height: 1);

        return HangoverSeveritySlider(
          value: state.hangoverSeverity.index,
          onChanged: (value) {
            final severity = HangoverSeverity.values[value];
            context.read<SelectHangoverSeverityCubit>().setHangoverSeverity(severity);
          },
          height: 400,
          min: 0,
          max: HangoverSeverity.values.length - 1,
          labels: HangoverSeverity.values.map((e) => Text(e.translate(context), style: labelTextStyle)).toList(),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<SelectHangoverSeverityCubit, SelectHangoverSeverityState>(
      builder: (context, state) => FilledButton(
        onPressed: () => context.router.pop(state.hangoverSeverity),
        child: Text(context.l10n.common_save),
      ),
    );
  }
}
