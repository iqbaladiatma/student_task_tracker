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
import 'views/home_view.dart';

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
}

class StudentTaskTrackerApp extends StatelessWidget {
  final String? initializationError;

  const StudentTaskTrackerApp({super.key}) : initializationError = null;

  const StudentTaskTrackerApp.withError(this.initializationError, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Student Task Tracker',
      theme: _buildAppTheme(),
      darkTheme: _buildDarkTheme(),
      highContrastTheme: AccessibilityTheme.buildHighContrastLightTheme(),
      highContrastDarkTheme: AccessibilityTheme.buildHighContrastDarkTheme(),
      themeMode: ThemeMode.system,
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
        // Get accessibility-aware theme
        final mediaQuery = MediaQuery.of(context);
        final accessibilityTheme =
            AccessibilityTheme.getAccessibilityAwareTheme(
              context: context,
              lightTheme: _buildAppTheme(),
              darkTheme: _buildDarkTheme(),
            );

        return Theme(
          data: accessibilityTheme,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              // Respect user's text scale preference
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

  /// Build light theme for the app with accessibility improvements
  ThemeData _buildAppTheme() {
    const primaryColor = Colors.blue;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,

      // AppBar theme dengan accessibility improvements
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        scrolledUnderElevation: 4,
        iconTheme: IconThemeData(size: 28), // Larger icons
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        highlightElevation: 8,
        iconSize: 28, // Larger icon
      ),

      // Card theme dengan better contrast
      cardTheme: const CardThemeData(
        elevation: 3, // Slightly higher elevation
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Input decoration theme dengan accessibility improvements
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 16, height: 1.2),
        hintStyle: TextStyle(fontSize: 16, height: 1.2),
      ),

      // Elevated button theme dengan minimum touch target
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48), // Minimum touch target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, height: 1.2),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, height: 1.2),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(88, 48),
          textStyle: const TextStyle(fontSize: 16, height: 1.2),
        ),
      ),

      // Chip theme dengan better accessibility
      chipTheme: const ChipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(fontSize: 14, height: 1.2),
      ),

      // Icon theme dengan larger icons
      iconTheme: const IconThemeData(size: 24),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Text theme dengan better readability
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, height: 1.4),
        labelMedium: TextStyle(fontSize: 12, height: 1.4),
        labelSmall: TextStyle(fontSize: 11, height: 1.4),
      ),
    );
  }

  /// Build dark theme for the app with accessibility improvements
  ThemeData _buildDarkTheme() {
    const primaryColor = Colors.blue;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,

      // AppBar theme dengan accessibility improvements
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        scrolledUnderElevation: 4,
        iconTheme: IconThemeData(size: 28), // Larger icons
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        highlightElevation: 8,
        iconSize: 28, // Larger icon
      ),

      // Card theme dengan better contrast
      cardTheme: const CardThemeData(
        elevation: 3, // Slightly higher elevation
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Input decoration theme dengan accessibility improvements
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 16, height: 1.2),
        hintStyle: TextStyle(fontSize: 16, height: 1.2),
      ),

      // Elevated button theme dengan minimum touch target
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48), // Minimum touch target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, height: 1.2),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, height: 1.2),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(88, 48),
          textStyle: const TextStyle(fontSize: 16, height: 1.2),
        ),
      ),

      // Chip theme dengan better accessibility
      chipTheme: const ChipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(fontSize: 14, height: 1.2),
      ),

      // Icon theme dengan larger icons
      iconTheme: const IconThemeData(size: 24),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Text theme dengan better readability
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, height: 1.4),
        labelMedium: TextStyle(fontSize: 12, height: 1.4),
        labelSmall: TextStyle(fontSize: 11, height: 1.4),
      ),
    );
  }

  /// Build critical error screen for initialization failures
  Widget _buildCriticalErrorScreen() {
    return Scaffold(
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
                  // Restart the app
                  SystemNavigator.pop();
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restart Aplikasi'),
              ),
            ],
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
      setState(() {
        _errorMessage = null;
        _isRetrying = false;
      });

      // Get storage service from dependency injection
      final storageService = Get.find<StorageService>();

      // Initialize storage service
      await storageService.initialize();

      // Register TaskController dengan dependency injection
      if (!Get.isRegistered<TaskController>()) {
        Get.put<TaskController>(TaskController(storageService));
      }

      // Initialize controller
      final taskController = Get.find<TaskController>();
      await taskController.initialize();

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
          _isRetrying = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is StorageException) {
      return 'Gagal mengakses penyimpanan data: ${error.message}';
    } else if (error.toString().contains('Hive')) {
      return 'Gagal menginisialisasi database lokal. Pastikan aplikasi memiliki izin penyimpanan.';
    } else if (error.toString().contains('network') ||
        error.toString().contains('internet')) {
      return 'Tidak dapat terhubung ke layanan. Periksa koneksi internet Anda.';
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _isRetrying = true;
    });

    // Wait a bit before retrying
    await Future.delayed(const Duration(milliseconds: 500));

    await _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    return const HomeView();
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
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
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Gagal Menginisialisasi Aplikasi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
                  style: Theme.of(context).textTheme.bodyMedium,
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
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isRetrying ? 'Mencoba...' : 'Coba Lagi'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => SystemNavigator.pop(),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Keluar'),
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

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
