import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/env/env.dart';
import '../core/theme/theme_provider.dart';
import '../features/shell/app_shell.dart';

class LifeOSApp extends StatelessWidget {
  final AppEnvironment environment;

  const LifeOSApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();

    return MaterialApp(
      title: environment.appName,
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      home: const AppShell(),
    );
  }
}
