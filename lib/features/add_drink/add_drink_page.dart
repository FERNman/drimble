import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/drink/consumed_drink.dart';
import '../common/widgets/extended_app_bar.dart';
import '../consumed_drink/consumed_drink_page.dart';
import 'add_drink_cubit.dart';
import 'widgets/common_beverages.dart';
import 'widgets/recent_drinks.dart';

class AddDrinkPage extends StatefulWidget {
  static Route<void> route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AddDrinkCubit(context.read(), context.read()),
          child: const AddDrinkPage(),
        ),
      );

  const AddDrinkPage({super.key});

  @override
  State<AddDrinkPage> createState() => _AddDrinkPageState();
}

class _AddDrinkPageState extends State<AddDrinkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExtendedAppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
                  Navigator.push(
                    context,
                    ConsumedDrinkPage.createDrinkRoute(drink.copyWith(startTime: DateTime.now())),
                  );
                },
              ),
              CommonBeverages(
                state.commonBeverages,
                onTap: (beverage) {
                  Navigator.push(context, ConsumedDrinkPage.createDrinkRoute(ConsumedDrink.fromBeverage(beverage)));
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  void _search(String term) {
    final cubit = context.read<AddDrinkCubit>();
    cubit.search(term);
  }
}
