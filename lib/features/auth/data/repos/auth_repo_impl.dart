import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'auth_repo.dart';
import '../models/user_model.dart';
import '../../../../core/database/user_dao.dart';

@Injectable(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  final UserDao userDao;
  final SharedPreferences sharedPreferences;

  AuthRepoImpl(this.userDao, this.sharedPreferences);

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final userMap = await userDao.getUserByEmail(email);
    if (userMap == null) {
      throw Exception('User not found');
    }
    
    final user = UserModel.fromMap(userMap);
    final hashedPassword = _hashPassword(password);
    
    if (user.password != hashedPassword) {
      throw Exception('Invalid password');
    }

    await sharedPreferences.setInt('user_id', user.id!);
    return user;
  }

  @override
  Future<UserModel> signup(UserModel user) async {
    // Validate inputs
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
    
    // Hash password
    final hashedPassword = _hashPassword(user.password);
    final userToSave = UserModel(
      fullName: user.fullName,
      gender: user.gender,
      email: user.email,
      studentId: user.studentId,
      academicLevel: user.academicLevel,
      password: hashedPassword,
    );

    try {
      final id = await userDao.insertUser(userToSave.toMap());
      return UserModel.fromMap({...userToSave.toMap(), 'id': id});
    } catch (e) {
      throw Exception('Failed to create account (might already exist)');
    }
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
