import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/task_controller.dart';
import 'model/task.dart';
import 'routes/app_routes.dart';
import 'services/hive_storage_service.dart';
import 'services/storage_service.dart';
import 'utils/accessibility_theme.dart';
import 'utils/colors.dart'; // Import file colors.dart
import 'views/home_view.dart';


// Palet warna sekarang diimpor dari utils/colors.dart


void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize core services
    await _initializeServices();

    // Run the app
    runApp(const StudentTaskTrackerApp());
  } catch (e) {
    // If initialization fails, run app with error state
    runApp(StudentTaskTrackerApp.withError(e.toString()));
  }
}

/// Initialize all required services before app starts
Future<void> _initializeServices() async {
  try {
    // Initialize date formatting for Indonesian locale
    await initializeDateFormatting('id_ID', null);

    // Initialize Hive database
    await Hive.initFlutter();

    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }

    // Setup dependency injection
    _setupDependencyInjection();
  } catch (e) {
    throw Exception('Failed to initialize services: $e');
  }
}

/// Setup dependency injection for services and controllers
void _setupDependencyInjection() {
  // Register StorageService as singleton
  Get.put<StorageService>(HiveStorageService(), permanent: true);
  // TaskController will be initialized later in AppInitializer
}

class StudentTaskTrackerApp extends StatelessWidget {
  final String? initializationError;

  const StudentTaskTrackerApp({super.key}) : initializationError = null;

  const StudentTaskTrackerApp.withError(this.initializationError, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Student Task Tracker',
      theme: _buildAppTheme(Brightness.light), // Pass brightness
      darkTheme: _buildAppTheme(Brightness.dark), // Use the same builder
      highContrastTheme: AccessibilityTheme.buildHighContrastLightTheme(), // Keep accessibility themes
      highContrastDarkTheme: AccessibilityTheme.buildHighContrastDarkTheme(),
      themeMode: ThemeMode.system, // Respect system theme
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      home: initializationError != null
          ? _buildCriticalErrorScreen()
          : const AppInitializer(),
      debugShowCheckedModeBanner: false,
      // Localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English (fallback)
      ],
      locale: const Locale('id', 'ID'),
      // Accessibility-aware builder
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final isDarkMode = mediaQuery.platformBrightness == Brightness.dark;
        final accessibilityTheme =
            AccessibilityTheme.getAccessibilityAwareTheme(
              context: context,
              lightTheme: _buildAppTheme(Brightness.light),
              darkTheme: _buildAppTheme(Brightness.dark),
            );

        return Theme(
          data: accessibilityTheme,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                AccessibilityTheme.getRecommendedTextScale(context),
              ),
            ),
            child: Semantics(
              label: 'Student Task Tracker - Aplikasi Pencatat Tugas',
              child: child!,
            ),
          ),
        );
      },
    );
  }

  /// Build theme for the app (light or dark) with modern styling
  ThemeData _buildAppTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Define base colors based on brightness - using imported constants
    final Color schemePrimary = primaryColor;
    final Color schemePrimaryContainer = isDark ? primaryColor.withOpacity(0.3) : primaryColorLight.withOpacity(0.1);
    final Color schemeSecondary = primaryColorLight;
    final Color schemeBackground = isDark ? const Color(0xFF121212) : backgroundColor;
    final Color schemeSurface = isDark ? const Color(0xFF1E1E1E) : cardColor; // Use cardColor for light surface
    final Color schemeOnPrimary = Colors.white;
    final Color schemeOnSecondary = Colors.white;
    final Color schemeOnBackground = isDark ? Colors.white.withOpacity(0.9) : textColorPrimary;
    final Color schemeOnSurface = isDark ? Colors.white.withOpacity(0.9) : textColorPrimary;
    final Color schemeError = accentColorRed;
    final Color schemeOnError = Colors.white;

    final baseTextTheme = isDark ? Typography.whiteMountainView : Typography.blackMountainView;

    return ThemeData(
      colorScheme: ColorScheme(
        primary: schemePrimary,
        primaryContainer: schemePrimaryContainer,
        secondary: schemeSecondary,
        background: schemeBackground,
        surface: schemeSurface,
        onPrimary: schemeOnPrimary,
        onSecondary: schemeOnSecondary,
        onBackground: schemeOnBackground,
        onSurface: schemeOnSurface,
        error: schemeError,
        onError: schemeOnError,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: schemeBackground,
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'Inter', // Consider adding a modern font like Inter

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0, // Flat design for AppBar
        scrolledUnderElevation: 1, // Subtle elevation on scroll
        // backgroundColor will use flexibleSpace gradient or schemeSurface
        foregroundColor: isDark ? Colors.white : schemeOnPrimary, // Icon/Text color
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : schemeOnPrimary,
            size: 26), // Adjusted icon size
        titleTextStyle: baseTextTheme.headlineSmall?.copyWith( // Use baseTextTheme
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : schemeOnPrimary,
          fontSize: 20, // Adjusted size
        ),
        systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light // For dark backgrounds
          : SystemUiOverlayStyle.dark, // For light backgrounds
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: schemePrimary,
        foregroundColor: schemeOnPrimary,
        elevation: 4,
        highlightElevation: 8,
        iconSize: 26, // Adjusted icon size
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0, // Flat card design
        color: schemeSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(isDark ? 0.3 : 0.2), width: 1) // Subtle border
            ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100, // Subtle fill
        hintStyle: TextStyle(color: textColorSecondary.withOpacity(0.7)),
        prefixIconColor: primaryColor.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjusted padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: schemePrimary, width: 2), // Primary color border on focus
        ),
        errorBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: schemeError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: schemeError, width: 2),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: schemePrimary,
          foregroundColor: schemeOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Adjusted padding
          minimumSize: const Size(88, 48), // Minimum touch target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2, // Subtle elevation
          shadowColor: schemePrimary.withOpacity(0.3),
          textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600), // Use baseTextTheme
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: schemePrimary, // Primary color for text/icon
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: schemePrimary.withOpacity(0.5), width: 1.5), // Softer border
          textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: schemePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          minimumSize: const Size(64, 48), // Adjusted min width
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Slight rounding
          textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Chip theme (ChoiceChip used in FilterChips)
      chipTheme: ChipThemeData(
        backgroundColor: schemeSurface, // Use surface color
        selectedColor: schemePrimaryContainer, // Use primary container
        disabledColor: Colors.grey.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjusted padding
        labelStyle: baseTextTheme.labelMedium?.copyWith( // Use baseTextTheme
          color: textColorSecondary,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: baseTextTheme.labelMedium?.copyWith(
          color: schemePrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textColorSecondary, size: 18),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(isDark ? 0.4 : 0.3))), // Subtle border
        selectedShadowColor: schemePrimary.withOpacity(0.2),
        elevation: 0, // Flat chips
        pressElevation: 1,
      ),

      // Icon theme
      iconTheme: IconThemeData(
          color: isDark ? Colors.white.withOpacity(0.8) : textColorSecondary,
          size: 24),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return schemePrimary;
          }
          return null; // Use default outline color
        }),
        checkColor: WidgetStateProperty.all(schemeOnPrimary),
        side: BorderSide(color: textColorSecondary.withOpacity(0.6), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
         materialTapTargetSize: MaterialTapTargetSize.padded, // Ensure tap target
      ),

      // Text theme (adjust specific styles if needed)
       textTheme: baseTextTheme.copyWith(
         bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5, color: schemeOnBackground),
         bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5, color: schemeOnBackground.withOpacity(0.8)),
         bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4, color: textColorSecondary),
         // Add other specific adjustments if necessary
       ),

       // Divider theme
       dividerTheme: DividerThemeData(
         color: Colors.grey.withOpacity(isDark ? 0.3 : 0.2),
         thickness: 1,
         space: 1, // Minimal space
       ),

       // Dialog Theme - FIXED: Use DialogThemeData
       dialogTheme: DialogThemeData(
         backgroundColor: schemeSurface,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
         titleTextStyle: baseTextTheme.headlineSmall?.copyWith(color: schemeOnSurface),
         contentTextStyle: baseTextTheme.bodyMedium?.copyWith(color: schemeOnSurface.withOpacity(0.8)),
       ),

       // Snackbar Theme
       snackBarTheme: SnackBarThemeData(
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         elevation: 4,
         contentTextStyle: TextStyle(color: Colors.white),
         // Background colors set dynamically
       ),
    );
  }


  /// Build critical error screen for initialization failures
  Widget _buildCriticalErrorScreen() {
    // Basic error screen, styling will depend on whether theme loads
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 24),
                const Text(
                  'Gagal Memulai Aplikasi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  initializationError ?? 'Terjadi kesalahan yang tidak diketahui',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Attempt to restart (might not work reliably on all platforms)
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart Aplikasi'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget untuk menginisialisasi aplikasi dan dependencies
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (mounted) {
         setState(() {
          _errorMessage = null;
          _isRetrying = false; // Reset retry flag on new attempt
        });
      }

      // Get storage service from dependency injection
      final storageService = Get.find<StorageService>();

      // Initialize storage service
      await storageService.initialize();

      // Register TaskController dengan dependency injection only if not registered
      if (!Get.isRegistered<TaskController>()) {
        Get.put<TaskController>(TaskController(storageService));
      }

      // Initialize controller
      final taskController = Get.find<TaskController>();
      await taskController.initialize(); // Use the public initialize method

      // Verify initialization was successful
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
          _isRetrying = false; // Ensure retry flag is false on error
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is StorageException) {
      return 'Gagal mengakses penyimpanan data: ${error.message}';
    } else if (error.toString().contains('Hive')) {
      return 'Gagal menginisialisasi database lokal. Pastikan aplikasi memiliki izin penyimpanan.';
    } else {
       // Generic error message
      return 'Terjadi kesalahan saat memulai aplikasi. Silakan coba lagi.';
      // Optionally log the full error for debugging:
      // print("Initialization Error: $error");
      // return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

  Future<void> _retryInitialization() async {
     if (!mounted || _isRetrying) return; // Prevent multiple retries at once
    setState(() {
      _isRetrying = true; // Set retry flag
       _errorMessage = null; // Clear previous error
    });

    // Wait a bit before retrying
    await Future.delayed(const Duration(seconds: 1)); // Increased delay

    await _initializeApp();

     // If still mounted after retry attempt, reset retry flag if it failed again
     if (mounted && _errorMessage != null) {
       setState(() {
         _isRetrying = false;
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    // Initialization successful, navigate to HomeView
    // Using WidgetsBinding ensures this runs after the build phase
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //    Get.offAllNamed(AppRoutes.home); // Navigate after init
    // });
    // Directly return HomeView is simpler if AppInitializer is the initial route's home
     return const HomeView();


   // return _buildLoadingScreen(); // Show loading until navigation happens
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _isRetrying ? 'Mencoba lagi...' : 'Menginisialisasi aplikasi...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
             if (_isRetrying) ...[
              const SizedBox(height: 16),
              Text(
                'Mohon tunggu sebentar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded, // Changed icon
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Gagal Memulai Aplikasi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                         fontWeight: FontWeight.w600, // Adjusted weight
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8) // Softer text
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRetrying ? null : _retryInitialization,
                      icon: _isRetrying
                          ? const SizedBox(
                              width: 18, height: 18, // Adjusted size
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, size: 20), // Changed icon and size
                      label: Text(_isRetrying ? 'Mencoba...' : 'Coba Lagi'),
                      style: ElevatedButton.styleFrom( // Use theme button style
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => SystemNavigator.pop(),
                      icon: const Icon(Icons.exit_to_app_rounded, size: 20), // Changed icon and size
                      label: const Text('Keluar'),
                       style: OutlinedButton.styleFrom( // Use theme button style
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                         foregroundColor: textColorSecondary, // Use palette color
                         side: BorderSide(color: Colors.grey.shade400) // Match theme outline button
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

