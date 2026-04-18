import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/manager/auth_cubit.dart';
import 'features/tasks/presentation/manager/task_cubit.dart';
import 'features/profile/presentation/manager/profile_cubit.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set Bloc observer
  Bloc.observer = AppBlocObserver();
  
  // Initialize dependency injection
  await configureDependencies();

  runApp(const StudentTaskManagerApp());
}

class StudentTaskManagerApp extends StatelessWidget {
  const StudentTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthCubit>()..checkSession(),
        ),
        BlocProvider(
          create: (_) => getIt<TaskCubit>(),
        ),
        BlocProvider(
          create: (_) => getIt<ProfileCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Student Task Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
