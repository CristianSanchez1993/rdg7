class UserModel {
  final int id;
  final String identification;
  final String passwordHash;
  final String email;
  final String firstName;
  final String secondName;
  final String lastName;
  final String secondLastName;
  final String phone;

  UserModel({
    required this.id,
    required this.identification,
    required this.passwordHash,
    required this.email,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.secondLastName,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'] as int,
    identification: json['identification'] as String,
    passwordHash: json['passwordHash'] as String,
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    secondName: json['secondName'] as String,
    lastName: json['lastName'] as String,
    secondLastName: json['secondLastName'] as String,
    phone: json['phone'] as String,
  );
}


  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'identification': identification,
    'passwordHash': passwordHash,
    'email': email,
    'firstName': firstName,
    'secondName': secondName,
    'lastName': lastName,
    'secondLastName': secondLastName,
    'phone': phone,
  };
}
}