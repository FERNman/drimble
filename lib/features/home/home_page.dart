import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/widgets/remove_drink_dialog.dart';
import 'home_cubit.dart';
import 'widgets/bac_chart.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/recent_drinks.dart';
import 'widgets/todays_statistics.dart';

class HomePage extends StatelessWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => HomeCubit(context.read(), context.read()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onTapProfile: () {
          context.router.push(const ProfileRoute());
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
                _buildRecentDrinks(state, context)
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(const AddDrinkRoute()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecentDrinks(HomeCubitState state, BuildContext context) {
    return RecentDrinks(
      state.todaysDrinks,
      onEdit: (drink) {
        context.router.push(ConsumedDrinkRoute(drink: drink, isEditing: true));
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
        context.router.push(const TodaysDrinksRoute());
      },
    );
  }
}
