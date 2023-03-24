import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../router.dart';
import '../diary/diary_cubit.dart';
import 'widgets/home_bottom_navigation_bar.dart';

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
      builder: (context, child, animation) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: FadeTransition(
            opacity: animation,
            child: child,
          ),
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
      buildWhen: (previous, current) => !DateUtils.isSameDay(previous.dateTime, current.dateTime),
      builder: (context, state) => FloatingActionButton(
        onPressed: () => context.router.push(AddDrinkRoute(date: state.dateTime)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
