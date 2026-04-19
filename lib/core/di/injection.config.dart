// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repos/auth_repo.dart' as _i507;
import '../../features/auth/data/repos/auth_repo_impl.dart' as _i152;
import '../../features/auth/presentation/manager/auth_cubit.dart' as _i888;
import '../../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i847;
import '../../features/profile/data/repos/profile_repo.dart' as _i687;
import '../../features/profile/data/repos/profile_repo_impl.dart' as _i1072;
import '../../features/profile/presentation/manager/profile_cubit.dart'
    as _i735;
import '../../features/tasks/data/datasources/task_remote_data_source.dart'
    as _i864;
import '../../features/tasks/data/repos/task_repo.dart' as _i712;
import '../../features/tasks/data/repos/task_repo_impl.dart' as _i1033;
import '../../features/tasks/presentation/manager/task_cubit.dart' as _i121;
import '../database/db_helper.dart' as _i880;
import '../database/task_dao.dart' as _i695;
import '../database/user_dao.dart' as _i24;
import '../network/api_service.dart' as _i921;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.singleton<_i880.DbHelper>(() => _i880.DbHelper());
  gh.factory<_i921.ApiService>(() => _i921.ApiService(gh<_i519.Client>()));
  gh.factory<_i695.TaskDao>(() => _i695.TaskDao(gh<_i880.DbHelper>()));
  gh.factory<_i24.UserDao>(() => _i24.UserDao(gh<_i880.DbHelper>()));
  gh.factory<_i107.AuthRemoteDataSource>(
    () => _i107.AuthRemoteDataSource(gh<_i921.ApiService>()),
  );
  gh.factory<_i847.ProfileRemoteDataSource>(
    () => _i847.ProfileRemoteDataSource(gh<_i921.ApiService>()),
  );
  gh.factory<_i864.TaskRemoteDataSource>(
    () => _i864.TaskRemoteDataSource(gh<_i921.ApiService>()),
  );
  gh.factory<_i507.AuthRepo>(
    () => _i152.AuthRepoImpl(
      gh<_i24.UserDao>(),
      gh<_i460.SharedPreferences>(),
      gh<_i107.AuthRemoteDataSource>(),
      gh<_i847.ProfileRemoteDataSource>(),
      gh<_i695.TaskDao>(),
    ),
  );
  gh.factory<_i888.AuthCubit>(() => _i888.AuthCubit(gh<_i507.AuthRepo>()));
  gh.factory<_i712.TaskRepo>(
    () => _i1033.TaskRepoImpl(
      gh<_i695.TaskDao>(),
      gh<_i864.TaskRemoteDataSource>(),
    ),
  );
  gh.factory<_i687.ProfileRepo>(
    () => _i1072.ProfileRepoImpl(
      gh<_i24.UserDao>(),
      gh<_i847.ProfileRemoteDataSource>(),
    ),
  );
  gh.factory<_i121.TaskCubit>(() => _i121.TaskCubit(gh<_i712.TaskRepo>()));
  gh.factory<_i735.ProfileCubit>(
    () => _i735.ProfileCubit(gh<_i687.ProfileRepo>(), gh<_i507.AuthRepo>()),
  );
  return getIt;
}
