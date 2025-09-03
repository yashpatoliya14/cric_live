import 'package:cric_live/features/signup_view/signup_model.dart';

class UserModel extends SignupModel {
  int? uid;
  String? userName;
  int? isVerified;
  String? role;

  UserModel({
    this.uid,
    this.userName,
    this.isVerified,
    this.role,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? gender,
    String? profilePhoto,
  }) : super(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          gender: gender,
          profilePhoto: profilePhoto,
        );

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName!;
    } else if (userName != null && userName!.isNotEmpty) {
      return userName!;
    }
    return 'Unknown User';
  }

  String get fullDisplayName {
    String first = firstName?.trim() ?? '';
    String last = lastName?.trim() ?? '';
    String user = userName?.trim() ?? '';
    
    if (first.isNotEmpty || last.isNotEmpty) {
      return '$first $last'.trim();
    }
    return user.isNotEmpty ? user : 'Unknown User';
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['uid'] = uid;
    data['userName'] = userName;
    data['isVerified'] = isVerified;
    data['role'] = role;
    return data;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as int?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      firstName: json['firstName'] as String?,
      gender: json['gender'] as String?,
      lastName: json['lastName'] as String?,
      isVerified: json['isVerified'] as int?,
      role: json['role'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
}
