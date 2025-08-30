import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app/app.dart';
import 'src/core/env/env.dart';
import 'src/core/di/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appEnv = AppEnvironment.loadFromDartDefine();

  runApp(
    MultiProvider(
      providers: createGlobalProviders(appEnv),
      child: LifeOSApp(environment: appEnv),
    ),
  );
}
