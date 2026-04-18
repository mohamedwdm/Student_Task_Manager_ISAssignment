import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepo {
  Future<UserModel> getProfile(int userId);
  Future<void> updateProfile(UserModel user);
  Future<void> updatePhoto(int userId, String photoPath);
}
