import 'package:cric_live/features/signup_view/signup_model.dart';

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
      'startDate': startDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'endDate': endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'format': format ?? '',
      'hostId': hostId ?? 0,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'scorers': scorers?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  factory CreateTournamentModel.fromJson(Map<String, dynamic> json) {
    return CreateTournamentModel(
      tournamentId: json['tournamentId'] as int?,
      name: json['name'] as String?,
      location: json['location'] as String?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      format: json['format'] as String?,
      hostId: json['hostId'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      scorers: json['scorers'] != null
          ? (json['scorers'] as List).map((e) => ScorerModel.fromJson(e)).toList()
          : null,
    );
  }
}

class ScorerModel {
  int? scorerId;
  String? username;

  ScorerModel({
    this.scorerId,
    this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'scorerId': scorerId ?? 0,
      'username': username ?? '',
    };
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

  TournamentTeamModel({
    this.tournamentId,
    this.teamId,
  });

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId ?? 0,
      'teamId': teamId ?? 0,
    };
  }

  factory TournamentTeamModel.fromJson(Map<String, dynamic> json) {
    return TournamentTeamModel(
      tournamentId: json['tournamentId'] as int?,
      teamId: json['teamId'] as int?,
    );
  }
}
