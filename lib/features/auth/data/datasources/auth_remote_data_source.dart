import 'package:injectable/injectable.dart';
import '../../../../core/network/api_service.dart';
import '../models/user_model.dart';

@injectable
class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> signup(UserModel user) async {
    return await apiService.post('/signup', {
      'name': user.fullName,
      'email': user.email,
      'student_id': user.studentId,
      'password': user.password,
      'confirm_password': user.password,
      'gender': user.gender,
      'academic_level': user.academicLevel,
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await apiService.post('/login', {
      'email': email,
      'password': password,
    });
  }
}
