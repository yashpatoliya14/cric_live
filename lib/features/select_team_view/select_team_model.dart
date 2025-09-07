class SelectTeamModel {
  int? id;
  int? teamId;
  String? teamName; // Changed to String as per TBL_TEAMS schema
  int? tournamentId;

  SelectTeamModel({this.id, this.teamId, this.teamName, this.tournamentId});

  // Converts a ScoreboardModel object into a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'tournamentId': tournamentId,
    };
  }

  // Creates a ScoreboardModel object from a Map retrieved from the database
  factory SelectTeamModel.fromMap(Map<String, dynamic> map) {
    return SelectTeamModel(
      id: map['id'] as int?,
      teamId: map['teamId'] as int?,
      teamName: map['teamName'] as String?, // Cast to String
      tournamentId: map['tournamentId'] as int?,
    );
  }
}
