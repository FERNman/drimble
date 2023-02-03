import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router.dart';
import 'widgets/home_bottom_navigation_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          floatingActionButton: tabsRouter.activeIndex == 0
              ? FloatingActionButton(
                  onPressed: () => context.router.push(AddDrinkRoute(date: DateTime.now())),
                  child: const Icon(Icons.add),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          bottomNavigationBar: HomeBottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) => tabsRouter.setActiveIndex(index),
          ),
        );
      },
    );
  }
}
