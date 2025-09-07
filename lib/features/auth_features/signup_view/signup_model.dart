class SignupModel {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? gender;
  String? profilePhoto;
  int? uid;
  String? username;

  // Corrected Constructor: Name matches the class, and all nullable
  // properties are included as optional named parameters.
  SignupModel({
    this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.gender,
    this.username,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (firstName != null) {
      data['firstName'] = firstName;
    }
    if (uid != null) {
      data['uid'] = uid;
    }
    if (username != null) {
      data['username'] = username;
    }
    if (lastName != null) {
      data['lastName'] = lastName;
    }
    if (email != null) {
      data['email'] = email;
    }
    if (password != null) {
      data['password'] = password;
    }
    if (gender != null) {
      data['gender'] = gender;
    }
    if (profilePhoto != null) {
      data['profilePhoto'] = profilePhoto;
    }
    return data;
  }

  factory SignupModel.fromMap(Map<String, dynamic> map) {
    return SignupModel(
      firstName: map['firstName'],
      lastName: map['lastName'],
      uid: map['uid'],
      email: map['email'],
      password: map['password'],
      gender: map['gender'],
      username: map['username'],
      profilePhoto: map['profilePhoto'],
    );
  }
}
