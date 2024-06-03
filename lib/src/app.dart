// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:filance/src/views/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:provider/provider.dart';

import 'models/expense.dart';
import 'providers/expense_provider.dart';
import 'views/edit_expense_screen.dart';
import 'views/home_screen.dart';
import 'views/manage_categories_screen.dart';
import 'views/report_screen.dart';
import 'widgets/fade_transition_widget.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// This scenario demonstrates how to set up nested navigation using ShellRoute,
// which is a pattern where an additional Navigator is placed in the widget tree
// to be used instead of the root navigator. This allows deep-links to display
// pages along with other UI components such as a BottomNavigationBar.
//
// This example demonstrates how to display a route within a ShellRoute and also
// push a screen using a different navigator (such as the root Navigator) by
// providing a `parentNavigatorKey`.

/// An example demonstrating how to use [ShellRoute]
class MyApp extends StatelessWidget {
  /// Creates a [MyApp]
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/b',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      /// Application shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AdaptiveNavigationHome(
            child: child,
          );
        },
        routes: <RouteBase>[
          /// The first screen to display in the bottom navigation bar.
          GoRoute(
            path: '/a',
            builder: (BuildContext context, GoRouterState state) {
              return ReportScreen();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen A but not the application shell.
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'A');
                },
              ),
            ],
          ),

          /// Displayed when the second item in the the bottom navigation bar is
          /// selected.
          GoRoute(
            path: '/b',
            builder: (BuildContext context, GoRouterState state) {
              // return const ScreenB();
              return HomeScreen();
            },
            // pageBuilder: (context, state) {
            //   return FadeTransitionPage(
            //       key: state.pageKey,
            //       child: Builder(builder: (context) {
            //         return HomeScreen();
            //       }));
            // },
            routes: <RouteBase>[
              /// Same as "/a/details", but displayed on the root Navigator by
              /// specifying [parentNavigatorKey]. This will cover both screen B
              /// and the application shell.
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return AddExpenseScreen();
                },
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final expense = state.extra as Expense;
                  return EditExpenseScreen(expense);
                },
              ),
              GoRoute(
                path: 'manage-categories',
                builder: (context, state) => ManageCategoriesScreen(),
              ),
            ],
          ),

          /// The third screen to display in the bottom navigation bar.
          GoRoute(
            path: '/c',
            builder: (BuildContext context, GoRouterState state) {
              return const ScreenC();
            },
            routes: <RouteBase>[
              // The details screen to display stacked on the inner Navigator.
              // This will cover screen A but not the application shell.
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'C');
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseProvider()..initializeDB(),
      child: MaterialApp.router(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
    // return MaterialApp.router(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   routerConfig: _router,
    //   debugShowCheckedModeBanner: false,
    // );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'A Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'B Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important_rounded),
            label: 'C Screen',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/a')) {
      return 0;
    }
    if (location.startsWith('/b')) {
      return 1;
    }
    if (location.startsWith('/c')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/a');
      case 1:
        GoRouter.of(context).go('/b');
      case 2:
        GoRouter.of(context).go('/c');
    }
  }
}

/// The first screen in the bottom navigation bar.
class ScreenA extends StatelessWidget {
  /// Constructs a [ScreenA] widget.
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Screen A'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/a/details');
              },
              child: const Text('View A details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The second screen in the bottom navigation bar.
class ScreenB extends StatelessWidget {
  /// Constructs a [ScreenB] widget.
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Screen B'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/b/details');
              },
              child: const Text('View B details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The third screen in the bottom navigation bar.
class ScreenC extends StatelessWidget {
  /// Constructs a [ScreenC] widget.
  const ScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('广告招商'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/c/details');
              },
              child: const Text('View C details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen for either the A, B or C screen.
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    super.key,
  });

  /// The label to display in the center of the screen.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: Center(
        child: Text(
          'Details for $label',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class AdaptiveNavigationHome extends StatelessWidget {
  final Widget child;

  const AdaptiveNavigationHome({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter.of(context);

    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: _calculateSelectedIndex(context),
        body: child,
        onDestinationSelected: (idx) {
          if (idx == 0) goRouter.go('/a');
          if (idx == 1) goRouter.go('/b');
          if (idx == 2) goRouter.go('/c');
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: '报表',
            icon: Icons.pie_chart,
          ),
          AdaptiveScaffoldDestination(
            title: '账单',
            icon: Icons.money,
          ),
          AdaptiveScaffoldDestination(
            title: '我的',
            icon: Icons.person,
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/a')) {
      return 0;
    }
    if (location.startsWith('/b')) {
      return 1;
    }
    if (location.startsWith('/c')) {
      return 2;
    }
    return 0;
  }
}
