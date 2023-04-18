import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_drink.dart';
import '../common/build_context_extensions.dart';
import 'edit_drink_cubit.dart';
import 'edit_drink_form.dart';
import 'widgets/create_edit_drink_app_bar.dart';
import 'widgets/edit_drink_title.dart';

@RoutePage()
class EditDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final ConsumedDrink consumedDrink;

  final _formKey = GlobalKey<FormState>();

  EditDrinkPage({required this.consumedDrink, super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => EditDrinkCubit.editConsumedDrink(
          context.read(),
          context.read(),
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
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
        child: Column(
          children: [
            CreateEditDrinkAppBar(
              onBack: () => context.router.pop(),
            ),
            _buildTitle(),
            const SizedBox(height: 24),
            EditDrinkForm(formKey: _formKey),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
      // Name and icon cannot change anyways
      buildWhen: (previous, current) => previous.consumedDrink.gramsOfAlcohol != current.consumedDrink.gramsOfAlcohol,
      builder: (context, state) => EditDrinkTitle(
        name: state.consumedDrink.name,
        iconPath: state.consumedDrink.iconPath,
        gramsOfAlcohol: state.consumedDrink.gramsOfAlcohol,
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(context.l18n.edit_drink_done),
      icon: const Icon(Icons.done),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _saveAndNavigate(context);
        }
      },
    );
  }

  void _saveAndNavigate(BuildContext context) {
    context.read<EditDrinkCubit>().save();
    context.router.popUntilRoot();
  }
}
