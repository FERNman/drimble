import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/alcohol/beverage.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../infra/extensions/set_date.dart';
import '../../router.dart';
import '../common/widgets/extended_app_bar.dart';
import 'add_drink_cubit.dart';
import 'widgets/common_beverages.dart';
import 'widgets/recent_drinks.dart';

class AddDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final DateTime date;

  const AddDrinkPage({required this.date, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => AddDrinkCubit(context.read()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExtendedAppBar.medium(
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(Icons.close),
        ),
        title: const Text('Add a drink'),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<AddDrinkCubit, AddDrinkCubitState>(builder: (context, state) {
          return Column(
            children: [
              // TODO: Search functionality
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: SearchField(onChange: _search),
              // ),
              RecentDrinks(
                state.recentlyAddedDrinks,
                onTap: (drink) => _addRecentDrink(context, drink),
              ),
              CommonBeverages(
                state.commonBeverages,
                onTap: (beverage) => _addCommonBeverage(context, beverage),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _addRecentDrink(BuildContext context, ConsumedDrink drink) {
    context.router.push(
      ConsumedDrinkRoute(drink: drink.copyWith(startTime: DateTime.now().setDate(date))),
    );
  }

  void _addCommonBeverage(BuildContext context, Beverage beverage) {
    final drink = ConsumedDrink.fromBeverage(beverage).copyWith(startTime: DateTime.now().setDate(date));
    context.router.push(ConsumedDrinkRoute(drink: drink));
  }
}
