import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'router/router.dart';

/// App's root
class App extends StatelessWidget {
  /// Init
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'To-Do app',
        theme: _buildThemeData(Brightness.light),
        darkTheme: _buildThemeData(Brightness.dark),
        routerConfig: router,
      );

  ThemeData _buildThemeData(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: brightness,
          seedColor: const Color(0xffF3DE8A),
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.robotoMono().fontFamily,
      );
}
