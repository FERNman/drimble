import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/widgets/consumed_drink_list_item.dart';
import '../common/widgets/remove_drink_dialog.dart';
import '../consumed_drink/consumed_drink_page.dart';
import 'todays_drinks_cubit.dart';

class TodaysDrinksPage extends StatefulWidget {
  static Route<void> route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => TodaysDrinksCubit(context.read()),
          child: const TodaysDrinksPage(),
        ),
      );

  const TodaysDrinksPage({super.key});

  @override
  State<TodaysDrinksPage> createState() => _TodaysDrinksPageState();
}

class _TodaysDrinksPageState extends State<TodaysDrinksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('History'),
      ),
      body: BlocBuilder<TodaysDrinksCubit, TodaysDrinksCubitState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.drinks.length,
            itemBuilder: (context, index) {
              final drink = state.drinks[index];

              return ConsumedDrinkListItem(
                drink,
                onEdit: () {
                  Navigator.push(context, ConsumedDrinkPage.editDrinkRoute(drink));
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
