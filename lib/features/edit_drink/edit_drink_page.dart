import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_drink.dart';
import '../common/build_context_extensions.dart';
import 'edit_drink_cubit.dart';
import 'edit_drink_form.dart';
import 'widgets/edit_drink_title.dart';

@RoutePage()
class EditDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final ConsumedDrink drink;

  final _formKey = GlobalKey<FormState>();

  EditDrinkPage({
    required this.drink,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => EditDrinkCubit(context.read(), drink: drink),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildFAB(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.router.pop(),
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
        child: Column(
          children: [
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
      // Name and icon cannot change (as of now at least)
      buildWhen: (previous, current) => previous.drink.gramsOfAlcohol != current.drink.gramsOfAlcohol,
      builder: (context, state) => EditDrinkTitle(
        name: state.drink.name,
        iconPath: state.drink.iconPath,
        gramsOfAlcohol: state.drink.gramsOfAlcohol,
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
