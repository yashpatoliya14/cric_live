class TokenModel {
  String? email;
  int? uid;

  TokenModel({this.email, this.uid});

  // Convert object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {"email": email, "uid": uid};
  }

  // Create object from JSON (Map)
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(email: json["email"], uid: int.parse(json["uid"]));
  }
}
