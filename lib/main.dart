import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/task_controller.dart';
import 'model/task.dart';
import 'routes/app_routes.dart';
import 'services/hive_storage_service.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskAdapter());
  }

  runApp(const StudentTaskTrackerApp());
}

class StudentTaskTrackerApp extends StatelessWidget {
  const StudentTaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Student Task Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        cardTheme: const CardThemeData(elevation: 2),
      ),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      home: const AppInitializer(),
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize storage service
      final storageService = HiveStorageService();
      await storageService.initialize();

      // Register TaskController dengan dependency injection
      Get.put<TaskController>(TaskController(storageService));

      // Initialize controller
      final taskController = Get.find<TaskController>();
      await taskController.initialize();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
              'Menginisialisasi aplikasi...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Gagal Menginisialisasi Aplikasi',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
