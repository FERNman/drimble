import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/date.dart';
import '../../domain/diary/consumed_drink.dart';
import '../../infra/extensions/set_date.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';
import 'search_drink_cubit.dart';
import 'widgets/search_drink_app_bar.dart';

@RoutePage()
class SearchDrinkPage extends StatelessWidget implements AutoRouteWrapper {
  final Date date;

  const SearchDrinkPage({
    required this.date,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => SearchDrinkCubit(context.read()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchDrinkAppBar(
        onSearchChanged: (value) {
          context.read<SearchDrinkCubit>().setSearch(value);
        },
      ),
      body: BlocBuilder<SearchDrinkCubit, SearchDrinkState>(
        builder: (context, state) {
          if (state.results.isEmpty) {
            return _buildNoResults(context);
          }

          return _buildResults(state);
        },
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 24, right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🙁', style: context.textTheme.displayMedium),
          const SizedBox(height: 24),
          Text(
            context.l18n.search_drink_noResults,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchDrinkState state) {
    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final drink = state.results[index];

        return ListTile(
          leading: Image.asset(drink.iconPath, height: 38),
          title: Text(drink.name),
          trailing: const Icon(Icons.add),
          onTap: () => context.router.push(
            EditConsumedDrinkRoute(
              consumedDrink: ConsumedDrink.fromDrink(drink, startTime: DateTime.now().setDate(date)),
            ),
          ),
        );
      },
    );
  }
}
