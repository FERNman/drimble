import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/drink/consumed_drink.dart';
import 'consumed_drink_cubit.dart';
import 'widgets/consumed_drink_form.dart';
import 'widgets/consumed_drink_summary.dart';

class ConsumedDrinkPage extends StatefulWidget {
  static Route<void> editDrinkRoute(ConsumedDrink drink) => CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ConsumedDrinkCubit.editDrink(context.read(), drink: drink),
          child: const ConsumedDrinkPage(),
        ),
      );

  static Route<void> createDrinkRoute(ConsumedDrink drink) => CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ConsumedDrinkCubit.createDrink(context.read(), drink: drink),
          child: const ConsumedDrinkPage(),
        ),
      );

  const ConsumedDrinkPage({super.key});

  @override
  State<ConsumedDrinkPage> createState() => _ConsumedDrinkPageState();
}

class _ConsumedDrinkPageState extends State<ConsumedDrinkPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
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
                  ConsumedDrinkSummary(state.drink.beverage),
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
        onPressed: _saveAndNavigate,
      ),
    );
  }

  void _saveAndNavigate() {
    context.read<ConsumedDrinkCubit>().save();
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
