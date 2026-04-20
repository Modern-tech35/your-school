class UserProfile {
  final String name;
  final String gender;
  final int age;
  final String avatar;
  final String role;

  UserProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.avatar,
    this.role = 'student', // Default role
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'avatar': avatar,
      'role': role,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'man',
      age: map['age'] ?? 16,
      avatar: map['avatar'] ?? 'avatar1',
      role: map['role'] ?? 'student',
    );
  }
}