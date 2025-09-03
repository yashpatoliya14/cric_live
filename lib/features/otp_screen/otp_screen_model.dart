class OtpModel {
  final String email;
  final String otp;
  final DateTime? expiryTime;

  OtpModel({required this.email, required this.otp, this.expiryTime});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': int.parse(otp),
      'expiryTime': expiryTime?.toIso8601String(),
    };
  }

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      email: json['email'] ?? '',
      otp: json['otp'] ?? '',
      expiryTime:
          json['expiryTime'] != null
              ? DateTime.tryParse(json['expiryTime'])
              : null,
    );
  }

  bool isValid() {
    return otp.length == 6 &&
        otp.isNotEmpty &&
        RegExp(r'^[0-9]{6}$').hasMatch(otp);
  }

  bool isExpired() {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  OtpModel copyWith({String? email, String? otp, DateTime? expiryTime}) {
    return OtpModel(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      expiryTime: expiryTime ?? this.expiryTime,
    );
  }
}

class OtpVerificationRequest {
  final String email;
  final String otp;

  OtpVerificationRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}

class ResendOtpRequest {
  final String email;

  ResendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
