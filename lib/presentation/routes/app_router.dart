// lib/presentation/routes/app_router.dart

import 'package:flutter/material.dart';
import '../views/home/home_view.dart';
import '../views/map/map_view.dart';
import '../views/alerts/alerts_view.dart';
import '../views/simulation/simulation_view.dart';
import '../views/settings/settings_placeholder.dart';

class AppRouter {
  static const String home = '/';
  static const String map = '/map';
  static const String alerts = '/alerts';
  static const String simulation = '/simulation';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case alerts:
        return MaterialPageRoute(builder: (_) => const AlertsView());
      case simulation:
        return MaterialPageRoute(builder: (_) => const SimulationView());
      case MapRouterName:
      case map:
        return MaterialPageRoute(builder: (_) => const MapView());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPlaceholder());
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeView());
    }
  }

  static Map<String, WidgetBuilder> routesMap() {
    return {
      home: (_) => const HomeView(),
      map: (_) => const MapView(),
      alerts: (_) => const AlertsView(),
      simulation: (_) => const SimulationView(),
      settings: (_) => const SettingsPlaceholder(),
    };
  }
}

const String MapRouterName = '/map';