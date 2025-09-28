class TokenModel {
  String? email;
  int? uid;
  String? username;
  String? firstName;
  String? lastName;
  String? gender;
  String? profilePhoto;

  TokenModel({
    this.email,
    this.uid,
    this.username,
    this.firstName,
    this.lastName,
    this.gender,
    this.profilePhoto,
  });

  // Convert object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "uid": uid,
      "username": username,
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender,
      "profilePhoto": profilePhoto,
    };
  }

  // Create object from JSON (Map)
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      email: json["email"],
      uid: json["uid"] is String ? int.parse(json["uid"]) : json["uid"],
      username: json["username"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      gender: json["gender"],
      profilePhoto: json["profilePhoto"],
    );
  }

  // Helper method to get display name
  String get displayName {
    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    } else if (firstName != null) {
      return firstName!;
    } else if (username != null) {
      return username!;
    } else {
      return email ?? "User";
    }
  }
}
