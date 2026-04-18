import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repos/auth_repo.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart' as auth_state;

@injectable
class AuthCubit extends Cubit<auth_state.AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(auth_state.AuthInitial());

  Future<void> login(String email, String password) async {
    emit(auth_state.AuthLoading());
    try {
      final user = await authRepo.login(email, password);
      emit(auth_state.AuthSuccess(user));
    } catch (e) {
      emit(auth_state.AuthFailure(e.toString()));
    }
  }

  Future<void> signup(UserModel user) async {
    emit(auth_state.AuthLoading());
    try {
      final createdUser = await authRepo.signup(user);
      emit(auth_state.AuthSuccess(createdUser));
    } catch (e) {
      emit(auth_state.AuthFailure(e.toString()));
    }
  }

  Future<void> checkSession() async {
    emit(auth_state.AuthLoading());
    try {
      final user = await authRepo.getSessionUser();
      if (user != null) {
        emit(auth_state.AuthSuccess(user));
      } else {
        emit(auth_state.AuthInitial());
      }
    } catch (e) {
      emit(auth_state.AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await authRepo.logout();
    emit(auth_state.AuthInitial());
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      emit(auth_state.AuthLoading());
      final user = await authRepo.updateUser(updatedUser);
      emit(auth_state.AuthSuccess(user));
    } catch (e) {
      if (state is auth_state.AuthSuccess) {
        emit(auth_state.AuthFailure(e.toString()));
        emit(state); // fallback
      }
    }
  }
}
