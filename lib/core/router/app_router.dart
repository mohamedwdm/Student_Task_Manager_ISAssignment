import 'package:go_router/go_router.dart';
import 'package:student_task_manager/features/auth/presentation/views/signup_view.dart';

// Import views
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/tasks/presentation/views/tasks_view.dart';
import '../../features/tasks/presentation/views/add_task_view.dart';
import '../../features/tasks/presentation/views/edit_task_view.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/profile/presentation/views/profile_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginView(),
        // Redirect logic should happen in the UI wrapper based on AuthCubit state
      ),
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
    ],
  );
}
