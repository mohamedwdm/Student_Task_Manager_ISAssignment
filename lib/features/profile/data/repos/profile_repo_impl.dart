import 'package:injectable/injectable.dart';

import 'profile_repo.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/database/user_dao.dart';
import '../datasources/profile_remote_data_source.dart';

@Injectable(as: ProfileRepo)
class ProfileRepoImpl implements ProfileRepo {
  final UserDao userDao;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepoImpl(this.userDao, this.remoteDataSource);

  @override
  Future<UserModel> getProfile(int userId) async {
    // 1. Sync from remote background
    _syncProfileFromRemote(userId).ignore();

    // 2. Return local data instantly
    final userMap = await userDao.getUserById(userId);
    if (userMap == null) {
      // If none, fetch remote and wait (first time fetch)
      return await _syncProfileFromRemote(userId);
    }
    return UserModel.fromMap(userMap);
  }

  Future<UserModel> _syncProfileFromRemote(int userId) async {
    try {
      final remoteUser = await remoteDataSource.getProfile(userId);
      // Update local cache but keep the password (api doesn't return password usually)
      final localUserMap = await userDao.getUserById(userId);
      final String? existingPassword = localUserMap?['password'];
      
      final userToCache = UserModel(
        id: remoteUser.id,
        fullName: remoteUser.fullName,
        gender: remoteUser.gender,
        email: remoteUser.email,
        studentId: remoteUser.studentId,
        academicLevel: remoteUser.academicLevel,
        password: existingPassword ?? '',
        profilePhoto: remoteUser.profilePhoto,
      );
      
      await userDao.insertUser(userToCache.toMap());
      return remoteUser;
    } catch (e) {
      // Silently fail for background sync
      throw e; // Reraise for direct calls
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    if (user.id == null) return;
    
    // 1. Instantly update local
    await userDao.updateUser(user.id!, user.toMap());
    
    // 2. Fire and forget remote action
    _updateRemoteBackground(user).ignore();
  }

  Future<void> _updateRemoteBackground(UserModel user) async {
    try {
      await remoteDataSource.updateProfile(user.id!, user);
    } catch (e) {}
  }

  @override
  Future<void> updatePhoto(int userId, String photoPath) async {
    // 1. Instantly update local path (might be local file path from ImagePicker)
    final userMap = await userDao.getUserById(userId);
    if (userMap != null) {
      userMap['profile_photo'] = photoPath;
      await userDao.updateUser(userId, userMap);
    }

    // 2. Upload to remote
    try {
      final response = await remoteDataSource.uploadPhoto(userId, photoPath);
      // If API returns a public URL, update local with public URL
      if (response.containsKey('profile_photo')) {
        final publicUrl = response['profile_photo'];
        userMap!['profile_photo'] = publicUrl;
        await userDao.updateUser(userId, userMap);
      }
    } catch (e) {}
  }
}
