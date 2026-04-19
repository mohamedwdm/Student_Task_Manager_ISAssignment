import 'package:injectable/injectable.dart';
import '../../../../core/network/api_service.dart';
import '../../../auth/data/models/user_model.dart';

@injectable
class ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSource(this.apiService);

  Future<UserModel> getProfile(int userId) async {
    final response = await apiService.get('/profile/$userId');
    return UserModel.fromMap(response);
  }

  Future<UserModel> updateProfile(int userId, UserModel user) async {
    final response = await apiService.put('/profile/$userId', {
      'name': user.fullName,
      'gender': user.gender,
      'email': user.email,
      'student_id': user.studentId,
      'academic_level': user.academicLevel,
    });
    return UserModel.fromMap(response);
  }

  Future<Map<String, dynamic>> uploadPhoto(int userId, String filePath) async {
    return await apiService.postMultipart('/profile/$userId/upload', filePath);
  }
}
