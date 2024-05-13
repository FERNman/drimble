import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/diary_entry.dart';
import '../../router.gr.dart';
import 'diary_entry_cubit.dart';
import 'widgets/diary_bac_chart.dart';
import 'widgets/diary_consumed_drinks.dart';
import 'widgets/diary_current_bac.dart';
import 'widgets/diary_quick_add_drink.dart';
import 'widgets/diary_statistics.dart';
import 'widgets/diary_water_tracking.dart';
import 'widgets/remove_drink_dialog.dart';

// This could be stateless, but `BlocProvider` doesn't call `create` again if the `diaryEntry` changes.
// The StatefulWidget is my best try to make sure the `DiaryEntryCubit` is updated with the new `diaryEntry`.
class DiaryEntryPage extends StatefulWidget {
  final DiaryEntry diaryEntry;

  const DiaryEntryPage({required this.diaryEntry, super.key});

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  late DiaryEntryCubit _diaryEntryCubit;

  @override
  void initState() {
    super.initState();
    _diaryEntryCubit = DiaryEntryCubit(context.read(), context.read(), widget.diaryEntry);
  }

  @override
  void didUpdateWidget(DiaryEntryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.diaryEntry != oldWidget.diaryEntry) {
      _diaryEntryCubit.close();
      _diaryEntryCubit = DiaryEntryCubit(context.read(), context.read(), widget.diaryEntry);
    }
  }

  @override
  void dispose() {
    _diaryEntryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _diaryEntryCubit,
      child: Column(
        children: [
          _buildCurrentBAC(),
          const SizedBox(height: 24),
          _buildBACChart(),
          const SizedBox(height: 24),
          _buildQuickAdd(),
          const SizedBox(height: 24),
          _buildWaterTracking(),
          const SizedBox(height: 24),
          _buildStatistics(),
          const SizedBox(height: 24),
          _buildConsumedDrinks(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCurrentBAC() {
    return BlocBuilder<DiaryEntryCubit, DiaryEntryCubitState>(
      buildWhen: (previous, current) => previous.calculationResults != current.calculationResults,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DiaryCurrentBAC(
          results: state.calculationResults,
          diaryEntry: state.diaryEntry,
        ),
      ),
    );
  }

  Widget _buildBACChart() {
    return BlocBuilder<DiaryEntryCubit, DiaryEntryCubitState>(
      buildWhen: (previous, current) => previous.calculationResults != current.calculationResults,
      builder: (context, state) => DiaryBACChart(
        results: state.calculationResults,
        date: state.diaryEntry.date,
      ),
    );
  }

  Widget _buildQuickAdd() {
    return BlocBuilder<DiaryEntryCubit, DiaryEntryCubitState>(
      buildWhen: (previous, current) => previous.recentDrinks != current.recentDrinks,
      builder: (context, state) => state.recentDrinks.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DiaryQuickAddDrink(
                recentDrinks: state.recentDrinks,
                onAddDrink: (drink) => context.read<DiaryEntryCubit>().addDrinkFromRecent(drink),
              ),
            ),
    );
  }

  Widget _buildWaterTracking() {
    return BlocBuilder<DiaryEntryCubit, DiaryEntryCubitState>(
      buildWhen: (previous, current) => previous.glassesOfWater != current.glassesOfWater,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DiaryWaterTracking(
          amount: state.glassesOfWater,
          onAdd: () {
            context.read<DiaryEntryCubit>().addGlassOfWater();
          },
          onRemove: () {
            context.read<DiaryEntryCubit>().removeGlassOfWater();
          },
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<DiaryEntryCubit, DiaryEntryCubitState>(
      buildWhen: (previous, current) => previous.drinks != current.drinks,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DiaryStatistics(
          gramsOfAlcohol: state.gramsOfAlcohol,
          calories: state.calories,
        ),
      ),
    );
  }

  Widget _buildConsumedDrinks() {
    return BlocBuilder<DiaryEntryCubit, DiaryEntryCubitState>(
      buildWhen: (previous, current) => previous.drinks != current.drinks,
      builder: (context, state) {
        return DiaryConsumedDrinks(
          state.drinks,
          onEdit: (drink) {
            context.router.push(EditConsumedDrinkRoute(diaryEntry: state.diaryEntry, consumedDrink: drink));
          },
          onDelete: (drink) {
            showDialog(
              context: context,
              builder: (dialogContext) => RemoveDrinkDialog(
                onCancel: () {
                  Navigator.pop(dialogContext);
                },
                onRemove: () async {
                  await context
                      .read<DiaryEntryCubit>()
                      .removeDrink(drink)
                      .then((value) => Navigator.pop(dialogContext));
                },
              ),
            );
          },
        );
      },
    );
  }
}
