import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/drink/consumed_drink.dart';
import '../../router.dart';
import '../common/widgets/extended_app_bar.dart';
import 'add_drink_cubit.dart';
import 'widgets/common_beverages.dart';
import 'widgets/recent_drinks.dart';

class AddDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  const AddDrinkPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => AddDrinkCubit(context.read(), context.read()),
      child: const AddDrinkPage(),
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
                onTap: (drink) {
                  context.router.push(
                    ConsumedDrinkRoute(drink: drink.copyWith(startTime: DateTime.now())),
                  );
                },
              ),
              CommonBeverages(
                state.commonBeverages,
                onTap: (beverage) {
                  context.router.push(ConsumedDrinkRoute(drink: ConsumedDrink.fromBeverage(beverage)));
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  void _search(BuildContext context, String term) {
    final cubit = context.read<AddDrinkCubit>();
    cubit.search(term);
  }
}
