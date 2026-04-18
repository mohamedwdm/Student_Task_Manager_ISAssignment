import '../models/user_model.dart';

abstract class AuthRepo {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<void> logout();
  Future<int?> getSessionId();
  Future<UserModel?> getSessionUser();
}
