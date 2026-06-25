import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

import 'ui/ide_shell.dart';

/// Shell `MaterialApp` (necessário ao Hux) — ver ADR-0001.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluenJ',
      theme: HuxTheme.lightTheme,
      darkTheme: HuxTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const IdeShell(),
    );
  }
}
