// lib/presentation/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:major_project/presentation/views/simulation/simulation_view.dart';
import '../views/home/home_view.dart';
import '../views/map/map_placeholder.dart';
import '../views/alerts/alerts_placeholder.dart';
import '../views/map/map_view.dart';
import '../views/simulation/simulation_placeholder.dart';
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
        return MaterialPageRoute(builder: (_) => const AlertsPlaceholder());
      case simulation:
        return MaterialPageRoute(builder: (_) => const SimulationView());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPlaceholder());
      case AppRouter.map:
        return MaterialPageRoute(builder: (_) => const MapView());
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeView());
    }
  }

  /// Optional convenience map for MaterialApp.routes if you prefer named routes map
  static Map<String, WidgetBuilder> routesMap() {
    return {
      home: (_) => const HomeView(),
      map: (_) => const MapPlaceholder(),
      alerts: (_) => const AlertsPlaceholder(),
      simulation: (_) => const SimulationPlaceholder(),
      settings: (_) => const SettingsPlaceholder(),
    };
  }
}
