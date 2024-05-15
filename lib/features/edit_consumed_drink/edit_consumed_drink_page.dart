import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../common/build_context_extensions.dart';
import 'edit_consumed_drink_cubit.dart';
import 'edit_consumed_drink_form.dart';
import 'widgets/edit_consumed_drink_title.dart';

@RoutePage()
class EditConsumedDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final DiaryEntry diaryEntry;
  final ConsumedDrink consumedDrink;

  final _formKey = GlobalKey<FormState>();

  EditConsumedDrinkPage({required this.diaryEntry, required this.consumedDrink, super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => EditConsumedDrinkCubit(
          context.read(),
          context.read(),
          context.read(),
          context.read(),
          diaryEntry: diaryEntry,
          consumedDrink: consumedDrink,
        ),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppBar(
            leading: const BackButton(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: Column(
              children: [
                _buildTitle(),
                const SizedBox(height: 24),
                EditConsumedDrinkForm(formKey: _formKey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return BlocBuilder<EditConsumedDrinkCubit, EditDrinkCubitState>(
      // Name and icon cannot change anyways
      buildWhen: (previous, current) => previous.consumedDrink.gramsOfAlcohol != current.consumedDrink.gramsOfAlcohol,
      builder: (context, state) => EditConsumedDrinkTitle(
        name: state.consumedDrink.name,
        iconPath: state.consumedDrink.iconPath,
        gramsOfAlcohol: state.consumedDrink.gramsOfAlcohol,
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(context.l10n.edit_drink_done),
      icon: const Icon(Icons.done),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _saveAndNavigate(context);
        }
      },
    );
  }

  void _saveAndNavigate(BuildContext context) {
    context.read<EditConsumedDrinkCubit>().save();
    context.router.popUntilRoot();
  }
}
