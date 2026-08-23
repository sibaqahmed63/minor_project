// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/routes/app_router.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);
    return MaterialApp(
      title: 'Self‑Healing AdHoc',
      theme: theme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
