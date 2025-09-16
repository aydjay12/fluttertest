import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/posts/views/posts_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a more vibrant and modern color scheme
    final ColorScheme customColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE), // Deep Purple for primary
      brightness: Brightness.light,
      primary: const Color(0xFF6200EE),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFBB86FC),
      onPrimaryContainer: Colors.black,
      secondary: const Color(0xFF03DAC6), // Teal for secondary
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF66FAF1),
      onSecondaryContainer: Colors.black,
      surface: const Color(0xFFF0F2F5), // Use surface instead of deprecated background
      onSurface: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: customColorScheme,
      textTheme: GoogleFonts.ralewayTextTheme().apply(
        bodyColor: customColorScheme.onSurface,
        displayColor: customColorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: customColorScheme.primary,
        foregroundColor: customColorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: customColorScheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColorScheme.primary,
          foregroundColor: customColorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: customColorScheme.primary,
          foregroundColor: customColorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );

    return ProviderScope(
      child: MaterialApp(
        title: 'Modern Flutter Posts',
        theme: theme,
        // Remove the blue glow on scroll for a cleaner look
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const NoGlowScrollBehavior(),
            child: child!,
          );
        },
        home: const PostsPage(),
      ),
    );
  }
}

// Custom scroll behavior to remove the Android glow effect
class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}