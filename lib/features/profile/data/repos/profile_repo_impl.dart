import 'package:injectable/injectable.dart';

import 'profile_repo.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/database/user_dao.dart';

@Injectable(as: ProfileRepo)
class ProfileRepoImpl implements ProfileRepo {
  final UserDao userDao;

  ProfileRepoImpl(this.userDao);

  @override
  Future<UserModel> getProfile(int userId) async {
    final userMap = await userDao.getUserById(userId);
    if (userMap == null) {
      throw Exception('User profile not found');
    }
    return UserModel.fromMap(userMap);
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    if (user.id == null) return;
    await userDao.updateUser(user.id!, user.toMap());
  }

  @override
  Future<void> updatePhoto(int userId, String photoPath) async {
    final userMap = await userDao.getUserById(userId);
    if (userMap != null) {
      userMap['profile_photo'] = photoPath;
      await userDao.updateUser(userId, userMap);
    }
  }
}
