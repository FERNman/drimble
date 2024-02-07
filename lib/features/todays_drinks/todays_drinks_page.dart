import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/drink_list_item.dart';
import '../common/widgets/remove_drink_dialog.dart';
import 'todays_drinks_cubit.dart';

@RoutePage()
class TodaysDrinksPage extends StatelessWidget implements AutoRouteWrapper {
  final Date date;

  const TodaysDrinksPage({required this.date, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => TodaysDrinksCubit(context.read(), date: date),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(context.l18n.todays_drinks_history),
      ),
      body: BlocBuilder<TodaysDrinksCubit, TodaysDrinksCubitState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.drinks.length,
            itemBuilder: (context, index) {
              final drink = state.drinks[index];

              return DrinkListItem(
                drink,
                onEdit: () {
                  context.router.push(EditConsumedDrinkRoute(consumedDrink: drink));
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => RemoveDrinkDialog(
                      onCancel: () {
                        Navigator.pop(dialogContext);
                      },
                      onRemove: () {
                        context.read<TodaysDrinksCubit>().removeDrink(drink);
                        Navigator.pop(dialogContext);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
