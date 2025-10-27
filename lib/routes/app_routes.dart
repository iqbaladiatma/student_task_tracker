import 'package:get/get.dart';
import '../views/home_view.dart';
import '../views/add_task_view.dart';
import '../views/edit_task_view.dart';
import '../model/task.dart';

/// Kelas untuk mendefinisikan route names sebagai constants
class AppRoutes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
}

/// Konfigurasi routes untuk aplikasi
class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.addTask,
      page: () => const AddTaskView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.editTask,
      page: () {
        // Get task from arguments
        final task = Get.arguments as Task?;
        if (task == null) {
          // If no task provided, navigate back to home
          Get.offAllNamed(AppRoutes.home);
          return const HomeView();
        }
        return EditTaskView(task: task);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
