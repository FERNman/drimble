import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/filled_button.dart';
import '../common/widgets/remove_drink_dialog.dart';
import '../diary_calendar/diary_calendar.dart';
import 'diary_cubit.dart';
import 'widgets/bac_chart.dart';
import 'widgets/diary_app_bar.dart';
import 'widgets/todays_drinks.dart';
import 'widgets/todays_statistics.dart';

class DiaryPage extends StatelessWidget implements AutoRouteWrapper {
  const DiaryPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => DiaryCubit(context.read(), context.read(), context.read()),
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
      body: BlocBuilder<DiaryCubit, DiaryCubitState>(
        builder: (context, state) => SingleChildScrollView(
          child: Column(
            children: [
              DiaryCalendar(
                selectedDay: state.date,
                onSelectedDayChanged: (value) {
                  context.read<DiaryCubit>().switchDate(value);
                },
              ),
              state.diaryEntry == null
                  ? _buildEmptyPage(context)
                  : state.diaryEntry!.isDrinkFreeDay
                      ? _buildDrinkFreePage(context)
                      : _buildDrunkPage(state, context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(const AddDrinkRoute()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 56),
        Text(context.l18n.diary_notDrinkingToday, style: context.textTheme.headlineSmall),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            context.read<DiaryCubit>().markAsDrinkFreeDay();
          },
          child: Text(context.l18n.diary_markAsDrinkFreeDay),
        ),
      ],
    );
  }

  Widget _buildDrinkFreePage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 56),
        Text(context.l18n.diary_drinkFreeDay, style: context.textTheme.headlineSmall),
        const SizedBox(height: 14),
        Text(context.l18n.diary_drinkFreeDayGreatJob, style: context.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDrunkPage(DiaryCubitState state, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        BACChart(results: state.calculationResults),
        const SizedBox(height: 24),
        TodaysStatistics(
          consumedDrinks: state.drinks,
          unitsOfAlcohol: state.unitsOfAlcohol,
          calories: state.calories,
        ),
        const SizedBox(height: 24),
        _buildRecentDrinks(state, context),
      ],
    );
  }

  Widget _buildRecentDrinks(DiaryCubitState state, BuildContext context) {
    return TodaysDrinks(
      state.drinks,
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
              context.read<DiaryCubit>().deleteDrink(drink);
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
