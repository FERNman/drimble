import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/drink.dart';
import '../common/build_context_extensions.dart';
import 'edit_drink_cubit.dart';
import 'edit_drink_form.dart';
import 'widgets/edit_drink_summary.dart';

class EditDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final Drink drink;
  final bool isEditing;

  const EditDrinkPage({
    required this.drink,
    this.isEditing = false,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    if (isEditing) {
      return BlocProvider(
        create: (context) => EditDrinkCubit.editDrink(context.read(), drink: drink),
        child: this,
      );
    } else {
      return BlocProvider(
        create: (context) => EditDrinkCubit.createDrink(context.read(), drink: drink),
        child: this,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.router.pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
          child: Column(
            children: [
              BlocBuilder<EditDrinkCubit, EditDrinkCubitState>(
                buildWhen: (previous, current) => previous.drink != current.drink,
                builder: (context, state) => EditDrinkSummary(state.drink),
              ),
              const EditDrinkForm(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(context.l18n.edit_drink_done),
        icon: const Icon(Icons.done),
        onPressed: () => _saveAndNavigate(context),
      ),
    );
  }

  void _saveAndNavigate(BuildContext context) {
    context.read<EditDrinkCubit>().save();
    context.router.popUntilRoot();
  }
}
