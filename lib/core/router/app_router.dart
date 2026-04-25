import 'package:go_router/go_router.dart';
import 'package:student_task_manager/features/auth/presentation/views/signup_view.dart';
import 'package:student_task_manager/features/profile/presentation/views/profile_view.dart';

// Import views
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/tasks/presentation/views/tasks_view.dart';
import '../../features/tasks/presentation/views/add_task_view.dart';
import '../../features/tasks/presentation/views/edit_task_view.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/auth/presentation/views/splash_view.dart';
import '../../features/tasks/presentation/views/favorite_tasks_view.dart';
import '../../features/tasks/presentation/views/deadline_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupView()),
      GoRoute(path: '/tasks', builder: (context, state) => const TasksView()),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => const AddTaskView(),
      ),
      GoRoute(
        path: '/edit-task',
        builder: (context, state) {
          final taskToEdit = state.extra as TaskModel;
          return EditTaskView(taskToEdit: taskToEdit);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoriteTasksView(),
      ),
      GoRoute(
        path: '/deadline',
        builder: (context, state) => const DeadlineView(),
      ),
    ],
  );
}
