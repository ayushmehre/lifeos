import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app/app.dart';
import 'src/core/env/env.dart';
import 'src/core/di/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load local env file for DX; ignored by git
  try {
    await dotenv.load(fileName: 'assets/env/.env.local');
  } catch (_) {
    // ignore: avoid_print
    print('No local .env found, continuing with dart-define defaults');
  }

  final appEnv = AppEnvironment.loadFromDartDefine();

  runApp(
    MultiProvider(
      providers: createGlobalProviders(appEnv),
      child: LifeOSApp(environment: appEnv),
    ),
  );
}
