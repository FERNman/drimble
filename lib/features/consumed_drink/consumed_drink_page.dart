import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_drink.dart';
import 'consumed_drink_cubit.dart';
import 'widgets/consumed_drink_form.dart';
import 'widgets/consumed_drink_summary.dart';

class ConsumedDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final ConsumedDrink drink;
  final bool isEditing;

  final _formKey = GlobalKey<FormState>();

  ConsumedDrinkPage({
    required this.drink,
    this.isEditing = false,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    if (isEditing) {
      return BlocProvider(
        create: (context) => ConsumedDrinkCubit.editDrink(context.read(), drink: drink),
        child: this,
      );
    } else {
      return BlocProvider(
        create: (context) => ConsumedDrinkCubit.createDrink(context.read(), drink: drink),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<ConsumedDrinkCubit, ConsumedDrinkCubitState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
              child: Column(
                children: [
                  ConsumedDrinkSummary(state.beverage),
                  ConsumedDrinkForm(
                    formKey: _formKey,
                    initialValue: state.drink,
                    onChanged: (drink) {
                      context.read<ConsumedDrinkCubit>().update(drink);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Done'),
        icon: const Icon(Icons.done),
        onPressed: () => _saveAndNavigate(context),
      ),
    );
  }

  void _saveAndNavigate(BuildContext context) {
    context.read<ConsumedDrinkCubit>().save();
    context.router.popUntilRoot();
  }
}
