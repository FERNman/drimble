import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/diary/drink.dart';
import '../../infra/extensions/set_date.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import '../common/widgets/extended_app_bar.dart';
import 'add_drink_cubit.dart';
import 'widgets/common_drinks.dart';
import 'widgets/recent_drinks.dart';

@RoutePage()
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
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TODO: Search functionality
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: SearchField(onChange: _search),
            // ),
            _buildRecentDrinks(),
            _buildCommonDrinks(),
          ],
        ),
      ),
    );
  }

  ExtendedAppBar _buildAppBar(BuildContext context) {
    return ExtendedAppBar.medium(
      leading: IconButton(
        onPressed: () => context.router.pop(),
        icon: const Icon(Icons.close),
      ),
      title: Text(context.l18n.add_drink_addADrink),
    );
  }

  Widget _buildRecentDrinks() {
    return BlocBuilder<AddDrinkCubit, AddDrinkCubitState>(
      buildWhen: (previous, current) => previous.recentDrinks != current.recentDrinks,
      builder: (context, state) {
        if (state.recentDrinks.isNotEmpty) {
          return RecentDrinks(
            state.recentDrinks,
            onTap: (drink) => _addDrink(context, drink),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildCommonDrinks() {
    return BlocBuilder<AddDrinkCubit, AddDrinkCubitState>(
      buildWhen: (previous, current) => previous.commonDrinks != current.commonDrinks,
      builder: (context, state) => CommonDrinks(
        state.commonDrinks,
        onTap: (drink) => _addDrink(context, drink),
      ),
    );
  }

  void _addDrink(BuildContext context, Drink drink) {
    final newDrink = Drink.fromExistingDrink(drink, startTime: DateTime.now().setDate(date));
    context.router.push(EditDrinkRoute(drink: newDrink));
  }
}
