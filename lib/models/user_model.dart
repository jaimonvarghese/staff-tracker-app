class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; 
  final String? assignedOfficeId;

  AppUser({required this.uid, required this.name, required this.email, required this.role, this.assignedOfficeId});

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'],
      email: map['email'],
      role: map['role'],
      assignedOfficeId: map['assignedOfficeId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role,
    'assignedOfficeId': assignedOfficeId,
  };
}
