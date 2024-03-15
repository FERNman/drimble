import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/consumed_drink.dart';
import '../../domain/diary/diary_entry.dart';
import '../../infra/extensions/set_date.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/extended_app_bar.dart';
import 'add_consumed_drink_cubit.dart';
import 'widgets/common_drinks.dart';
import 'widgets/search_field.dart';

@RoutePage()
class AddConsumedDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final DiaryEntry diaryEntry;

  const AddConsumedDrinkPage({required this.diaryEntry, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => AddConsumedDrinkCubit(context.read()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchField(
                onSearch: () => context.router.push(SearchDrinkRoute(forDiaryEntry: diaryEntry)),
              ),
            ),
            const SizedBox(height: 8),
            _buildCommonDrinks(),
          ],
        ),
      ),
    );
  }

  ExtendedAppBar _buildAppBar(BuildContext context) {
    return ExtendedAppBar.medium(
      leading: const CloseButton(),
      title: Text(context.l18n.add_drink_addADrink),
    );
  }

  Widget _buildCommonDrinks() {
    return BlocBuilder<AddConsumedDrinkCubit, AddDrinkCubitState>(
      buildWhen: (previous, current) => previous.commonDrinks != current.commonDrinks,
      builder: (context, state) => CommonDrinks(
        state.commonDrinks,
        onTap: (drink) => context.router.push(
          EditConsumedDrinkRoute(
            diaryEntry: diaryEntry,
            consumedDrink: ConsumedDrink.fromDrink(drink, startTime: DateTime.now().setDate(diaryEntry.date)),
          ),
        ),
      ),
    );
  }
}
