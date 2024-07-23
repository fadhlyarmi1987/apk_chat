class UserModel {
  String uid;
  String name;
  String divisi;
  String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.divisi,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'divisi': divisi,
      'email': email,
    };
  }
}
