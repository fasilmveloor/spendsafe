import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/theme/app_theme.dart';
import 'main_navigation_scaffold.dart';
import '../core/db/seed_data.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../core/services/preferences_service.dart';
import '../core/providers/theme_provider.dart';
import '../features/splash/splash_screen.dart';

/// Main SpendSafe app configuration
class SpendSafeApp extends ConsumerWidget {
  const SpendSafeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'SpendSafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const AppInitializer(),
    );
  }
}

/// Initialize app and seed database on first run
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _hasError = false;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = PreferencesService();
      _hasCompletedOnboarding = await prefs.hasCompletedOnboarding();
      
      // Seed database with test data ONLY if not previously done
      // For now, we'll skip seeding if onboarding is shown to avoid overwriting user setup
      // In a real app, seeding might handle versioning
      if (!_hasCompletedOnboarding) {
        // Optional: clear any old data if fresh install
      } else {
        // If coming back, ensure data integrity or migrations (placeholder)
      }
      
      // If using explicit seed data during dev, uncomment:
      // final seedData = SeedData();
      // await seedData.seedDatabase();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to initialize app'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const SplashScreen();
    }

    return _hasCompletedOnboarding 
        ? const MainNavigationScaffold() 
        : const OnboardingScreen();
  }
}
