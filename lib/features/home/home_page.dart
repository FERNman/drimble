import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../add_drink/add_drink_page.dart';
import '../common/widgets/remove_drink_dialog.dart';
import '../consumed_drink/consumed_drink_page.dart';
import '../profile/profile_page.dart';
import '../todays_drinks/todays_drinks_page.dart';
import 'home_cubit.dart';
import 'widgets/bac_chart.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/recent_drinks.dart';
import 'widgets/todays_statistics.dart';

class HomePage extends StatefulWidget {
  static Widget create(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(context.read(), context.read()),
      child: const HomePage(),
    );
  }

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onTapProfile: () {
          Navigator.push(context, ProfilePage.route());
        },
      ),
      body: BlocBuilder<HomeCubit, HomeCubitState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                BACChart(results: state.calculationResults),
                const SizedBox(height: 24),
                TodaysStatistics(
                  consumedDrinks: state.todaysDrinks,
                  unitsOfAlcohol: state.unitsOfAlcohol,
                  calories: state.calories,
                ),
                const SizedBox(height: 24),
                RecentDrinks(
                  state.todaysDrinks,
                  onEdit: (drink) {
                    Navigator.push(context, ConsumedDrinkPage.editDrinkRoute(drink));
                  },
                  onDelete: (drink) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => RemoveDrinkDialog(
                        onCancel: () {
                          Navigator.pop(dialogContext);
                        },
                        onRemove: () {
                          context.read<HomeCubit>().deleteDrink(drink);
                          Navigator.pop(dialogContext);
                        },
                      ),
                    );
                  },
                  onViewAll: () {
                    Navigator.push(context, TodaysDrinksPage.route());
                  },
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, AddDrinkPage.route()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

