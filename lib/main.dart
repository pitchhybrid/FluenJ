import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Janela frameless (sem a title bar nativa do Windows): a title bar custom
  // está em lib/ui/widgets/title_bar.dart. Ver [[ide-arquitetura]].
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      title: 'FluenJ',
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.show();
    },
  );

  runApp(const ProviderScope(child: MyApp()));
}
