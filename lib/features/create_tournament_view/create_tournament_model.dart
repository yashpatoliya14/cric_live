import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentModel {
  int? tournamentId;
  String? name;
  String? location;
  DateTime? startDate;
  DateTime? endDate;
  String? format;
  int? hostId;
  DateTime? createdAt;
  List<ScorerModel>? scorers;

  CreateTournamentModel({
    this.tournamentId,
    this.name,
    this.location,
    this.startDate,
    this.endDate,
    this.format,
    this.hostId,
    this.createdAt,
    this.scorers,
  });

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId ?? 0,
      'name': name ?? '',
      'location': location ?? '',
      'startDate':
          startDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'endDate': endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'format': format ?? '',
      'hostId': hostId ?? 0,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'scorers': scorers?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  static DateTime? _parseDate(String dateString) {
    if (dateString is String) {
      try {
        final format = DateFormat('dd-MM-yyyy');
        return format.parse(dateString);
      } catch (e) {
        // If the custom format fails, you can optionally try the default parser
        // or just return null. Returning null is often the safest.
        // print('Could not parse date: $dateString'); // Optional: for debugging
        return null;
      }
    }
    return null;
  }

  factory CreateTournamentModel.fromJson(Map<String, dynamic> json) {
    return CreateTournamentModel(
      tournamentId: json['tournamentId'] as int?,
      name: json['name'] as String?,
      location: json['location'] as String?,
      startDate:
          json['startDate'] != null
              ? _parseDate(json['startDate'] as String)
              : null,
      endDate:
          json['endDate'] != null
              ? _parseDate(json['endDate'] as String)
              : null,
      format: json['format'] as String?,
      hostId: json['hostId'] as int?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      scorers:
          json['scorers'] != null
              ? (json['scorers'] as List)
                  .map((e) => ScorerModel.fromJson(e))
                  .toList()
              : null,
    );
  }
}

class ScorerModel {
  int? scorerId;
  String? username;

  ScorerModel({this.scorerId, this.username});

  Map<String, dynamic> toJson() {
    return {'scorerId': scorerId ?? 0, 'username': username ?? ''};
  }

  factory ScorerModel.fromJson(Map<String, dynamic> json) {
    return ScorerModel(
      scorerId: json['scorerId'] as int?,
      username: json['username'] as String?,
    );
  }
}

class TournamentTeamModel {
  int? tournamentId;
  int? teamId;

  TournamentTeamModel({this.tournamentId, this.teamId});

  Map<String, dynamic> toJson() {
    return {'tournamentId': tournamentId ?? 0, 'teamId': teamId ?? 0};
  }

  factory TournamentTeamModel.fromJson(Map<String, dynamic> json) {
    return TournamentTeamModel(
      tournamentId: json['tournamentId'] as int?,
      teamId: json['teamId'] as int?,
    );
  }
}

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