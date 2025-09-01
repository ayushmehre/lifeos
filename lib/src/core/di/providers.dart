import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../env/env.dart';
import '../../features/chat/state/chat_provider.dart';
import '../../features/chat/state/speech_provider.dart';
import '../../features/contexts/state/contexts_provider.dart';
import '../theme/theme_provider.dart';

List<SingleChildWidget> createGlobalProviders(AppEnvironment env) {
  return <SingleChildWidget>[
    ChangeNotifierProvider(create: (_) => AppThemeProvider()),
    ChangeNotifierProvider(create: (_) => ContextsProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider(environment: env)),
    ChangeNotifierProvider(create: (_) => SpeechProvider()),
  ];
}
