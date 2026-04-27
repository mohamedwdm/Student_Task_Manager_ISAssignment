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
      id: (map['id'] ?? map['user_id']) as int?,
      fullName: (map['full_name'] ?? map['name'] ?? map['fullName'] ?? '') as String,
      gender: (map['gender'] ?? map['sex']) as String?,
      email: (map['email'] ?? '') as String,
      studentId: (map['student_id'] ?? map['studentId'] ?? map['id_student'] ?? '').toString(),
      academicLevel: (map['academic_level'] ?? map['academicLevel'] ?? map['level']) as int?,
      password: (map['password'] ?? '') as String,
      profilePhoto: (map['profile_photo'] ?? map['profilePhoto'] ?? map['photo']) as String?,
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
