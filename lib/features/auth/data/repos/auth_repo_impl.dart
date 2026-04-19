import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'auth_repo.dart';
import '../models/user_model.dart';
import '../../../../core/database/user_dao.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final UserDao userDao;
  final SharedPreferences sharedPreferences;
  final AuthRemoteDataSource remoteDataSource;
  final ProfileRemoteDataSource profileRemoteDataSource;

  AuthRepoImpl(
    this.userDao,
    this.sharedPreferences,
    this.remoteDataSource,
    this.profileRemoteDataSource,
  );

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> login(String email, String password) async {
    // 1. Authenticate with remote API
    final loginResponse = await remoteDataSource.login(email, password);
    final int? userId = loginResponse['id'] ?? loginResponse['user_id'];
    
    if (userId == null) {
      throw Exception('Login failed: Server did not return a user ID');
    }

    // 2. Fetch full profile to ensure we have all data (name, student_id, etc.)
    // This allows us to handle the partial response from /login
    final fullProfile = await profileRemoteDataSource.getProfile(userId);
    
    // 3. Hash password for local storage
    final hashedPassword = _hashPassword(password);
    
    // 4. Cache full user in local database
    final userToCache = UserModel(
      id: fullProfile.id,
      fullName: fullProfile.fullName,
      gender: fullProfile.gender,
      email: fullProfile.email,
      studentId: fullProfile.studentId,
      academicLevel: fullProfile.academicLevel,
      password: hashedPassword,
      profilePhoto: fullProfile.profilePhoto,
    );
    
    await userDao.insertUser(userToCache.toMap());

    // 5. Persistence session
    await sharedPreferences.setInt('user_id', userId);
    return userToCache;
  }

  @override
  Future<UserModel> signup(UserModel user) async {
    // Validate inputs locally for better UX
    final emailRegex = RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');
    if (!emailRegex.hasMatch(user.email)) {
      throw Exception('Invalid email format');
    }
    
    if (!user.email.startsWith(user.studentId)) {
      throw Exception('Student ID must match email prefix');
    }
    
    if (user.password.length < 8 || !user.password.contains(RegExp(r'\d'))) {
      throw Exception('Password must be at least 8 characters and contain a digit');
    }
    
    // 1. Signup with remote API
    final signupResponse = await remoteDataSource.signup(user);
    final int? userId = signupResponse['id'] ?? signupResponse['user_id'];

    if (userId == null) {
      throw Exception('Signup failed: Server did not return a user ID');
    }

    // 2. Fetch full profile to verify and get any server-side defaults
    final fullProfile = await profileRemoteDataSource.getProfile(userId);
    
    // 3. Hash password for local storage
    final hashedPassword = _hashPassword(user.password);
    
    // 4. Cache user in local database
    final userToCache = UserModel(
      id: fullProfile.id,
      fullName: fullProfile.fullName,
      gender: fullProfile.gender,
      email: fullProfile.email,
      studentId: fullProfile.studentId,
      academicLevel: fullProfile.academicLevel,
      password: hashedPassword,
      profilePhoto: fullProfile.profilePhoto,
    );

    await userDao.insertUser(userToCache.toMap());
    
    return userToCache;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove('user_id');
  }

  @override
  Future<int?> getSessionId() async {
    return sharedPreferences.getInt('user_id');
  }
  
  @override
  Future<UserModel?> getSessionUser() async {
    final id = await getSessionId();
    if (id != null) {
      final userMap = await userDao.getUserById(id);
      if (userMap != null) {
        return UserModel.fromMap(userMap);
      }
    }
    return null;
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    if (user.id == null) throw Exception('User ID is null');
    await userDao.updateUser(user.id!, user.toMap());
    return user;
  }
}
