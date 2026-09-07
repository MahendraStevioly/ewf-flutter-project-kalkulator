import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/views/dashboard_screen.dart';
import '../../features/gold_calculator/presentation/views/gold_calculator_result_view.dart';
import '../../features/gold_calculator/presentation/views/gold_calculator_screen.dart';
import '../../features/history/presentation/views/history_screen.dart';
import '../../features/live_gold/presentation/views/live_gold_screen.dart';
import '../../features/pivot_point/presentation/views/pivot_point_screen.dart';
import '../../features/settings/presentation/views/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String goldCalculator = '/gold-calculator';
  static const String goldCalculatorResult = '/gold-calculator/result';
  static const String pivotPoint = '/pivot-point';
  static const String liveGold = '/live-gold';
  static const String history = '/history';
  static const String settings = '/settings';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );
      case AppRoutes.goldCalculator:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GoldCalculatorScreen(),
        );
      case AppRoutes.goldCalculatorResult:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GoldCalculatorResultView(),
        );
      case AppRoutes.pivotPoint:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PivotPointScreen(),
        );
      case AppRoutes.liveGold:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LiveGoldScreen(),
        );
      case AppRoutes.history:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HistoryScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeShellScreen(),
        );
    }
  }
}

class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <HomeRouteItem>[
      HomeRouteItem(
        title: 'Physical Gold Calculator',
        subtitle: 'Calculation utility',
        routeName: AppRoutes.goldCalculator,
      ),
      HomeRouteItem(
        title: 'Pivot Point',
        subtitle: 'Support and resistance',
        routeName: AppRoutes.pivotPoint,
      ),
      HomeRouteItem(
        title: 'Live Gold',
        subtitle: 'Market snapshot',
        routeName: AppRoutes.liveGold,
      ),
      HomeRouteItem(
        title: 'History',
        subtitle: 'Recent calculations',
        routeName: AppRoutes.history,
      ),
      HomeRouteItem(
        title: 'Settings',
        subtitle: 'App preferences',
        routeName: AppRoutes.settings,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('EWF Utility'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () => Navigator.of(context).pushNamed(item.routeName),
            ),
          );
        },
      ),
    );
  }
}

class HomeRouteItem {
  const HomeRouteItem({
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  final String title;
  final String subtitle;
  final String routeName;
}
