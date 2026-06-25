import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'ui/ide_shell.dart';

/// Root shadcn_ui: `ShadApp` (sem `MaterialApp`) — ver ADR-0004.
/// Usa `WidgetsApp` por baixo (zero Material na UI).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'FluenJ',
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(brightness: Brightness.light),
      darkTheme: ShadThemeData(brightness: Brightness.dark),
      home: const IdeShell(),
    );
  }
}
