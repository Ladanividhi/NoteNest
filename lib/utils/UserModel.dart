class UserModel {
  final String fullName;
  final String email;
  final String mobile;

  UserModel({
    required this.fullName,
    required this.email,
    required this.mobile,
  });

  Map<String, dynamic> toMap(String password) {
    return {
      'Name': fullName,
      'Email': email,
      'Mobile': mobile,
      'Password': password,
    };
  }
}
