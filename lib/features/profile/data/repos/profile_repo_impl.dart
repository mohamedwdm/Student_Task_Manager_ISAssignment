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
    // 1. Sync from remote background with logging
    _syncProfileFromRemote(userId).catchError((e) {
      print('DEBUG SYNC ERROR: Failed to sync profile from remote: $e');
    });

    // 2. Return local data instantly
    final userMap = await userDao.getUserById(userId);
    if (userMap == null) {
      return await _syncProfileFromRemote(userId);
    }
    return UserModel.fromMap(userMap);
  }

  Future<UserModel> _syncProfileFromRemote(int userId) async {
    try {
      final remoteUser = await remoteDataSource.getProfile(userId);
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
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    if (user.id == null) return;
    
    // 1. Instantly update local
    await userDao.updateUser(user.id!, user.toMap());
    
    // 2. Remote action
    try {
      print('DEBUG SYNC: Attempting Profile UPDATE for ID ${user.id}');
      final response = await remoteDataSource.updateProfile(user.id!, user);
      print('DEBUG: SERVER PROFILE RESPONSE: $response');
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to update profile on remote: $e');
    }
  }

  @override
  Future<void> updatePhoto(int userId, String photoPath) async {
    // 1. Log action
    print('DEBUG: Starting photo upload for User $userId Path $photoPath');

    // 2. Upload to remote first to get the URL
    try {
      final response = await remoteDataSource.uploadPhoto(userId, photoPath);
      print('DEBUG: Photo upload response: $response');

      // 3. Update local cache with public URL from server
      if (response != null && response.containsKey('profile_photo')) {
        final publicUrl = response['profile_photo'];
        final userMap = await userDao.getUserById(userId);
        if (userMap != null) {
          userMap['profile_photo'] = publicUrl;
          await userDao.updateUser(userId, userMap);
          print('DEBUG: Local profile updated with remote URL: $publicUrl');
        }
      }
    } catch (e) {
      print('DEBUG SYNC ERROR: Failed to upload photo to remote: $e');
      // Update local with local path for immediate UI feedback even if offline
      final userMap = await userDao.getUserById(userId);
      if (userMap != null) {
        userMap['profile_photo'] = photoPath;
        await userDao.updateUser(userId, userMap);
      }
    }
  }
}
