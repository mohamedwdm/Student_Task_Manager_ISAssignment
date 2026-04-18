class UserModel {
  final int? id;
  final String fullName;
  final String? gender;
  final String email;
  final String studentId;
  final int? academicLevel;
  final String password;
  final String? profilePhoto;

  UserModel({
    this.id,
    required this.fullName,
    this.gender,
    required this.email,
    required this.studentId,
    this.academicLevel,
    required this.password,
    this.profilePhoto,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      gender: map['gender'] as String?,
      email: map['email'] as String,
      studentId: map['student_id'] as String,
      academicLevel: map['academic_level'] as int?,
      password: map['password'] as String,
      profilePhoto: map['profile_photo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'full_name': fullName,
      'gender': gender,
      'email': email,
      'student_id': studentId,
      'academic_level': academicLevel,
      'password': password,
      'profile_photo': profilePhoto,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
