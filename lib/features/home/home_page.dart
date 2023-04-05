import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.gr.dart';
import '../diary/diary_cubit.dart';
import 'widgets/home_bottom_navigation_bar.dart';

@RoutePage()
class HomePage extends StatelessWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  // This is needed because the FAB depends on the date...
  // There might be a better way, and it would be preferrable to host this at the level of the diary page IMO
  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => DiaryCubit(context.read(), context.read(), context.read()),
        child: this,
      );

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [DiaryRoute(), AnalyticsRoute()],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          floatingActionButton: tabsRouter.activeIndex == 0 ? _buildFAB() : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: HomeNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) => tabsRouter.setActiveIndex(index),
          ),
        );
      },
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<DiaryCubit, DiaryCubitState>(
      buildWhen: (previous, current) => previous.date != current.date,
      builder: (context, state) => FloatingActionButton(
        onPressed: () => context.router.push(AddDrinkRoute(date: state.date)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
