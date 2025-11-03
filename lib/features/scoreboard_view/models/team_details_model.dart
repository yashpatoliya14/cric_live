import 'dart:convert';

class TeamDetailsModel {
  final int teamId;
  final String teamName;

  TeamDetailsModel({
    required this.teamId,
    required this.teamName,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'teamName': teamName,
    };
  }

  factory TeamDetailsModel.fromMap(Map<String, dynamic> map) {
    return TeamDetailsModel(
      teamId: map['teamId'] ?? '',
      teamName: map['teamName'] ?? '',
    );
  }
}
