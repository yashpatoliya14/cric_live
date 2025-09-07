class PlayersModel {
  int? teamPlayerId; // Primary ID
  int? teamId;
  String? playerName;
  int? tournamentId;

  PlayersModel({
    this.teamPlayerId,
    this.teamId,
    this.playerName,
    this.tournamentId,
  });

  // Convert object to Map
  Map<String, dynamic> toMap() {
    return {
      'teamPlayerId': teamPlayerId,
      'teamId': teamId,
      'playerName': playerName,
      if (tournamentId != null) 'tournamentId': tournamentId,
    };
  }

  // Create object from Map
  PlayersModel fromMap(Map<String, dynamic> map) {
    return PlayersModel(
      teamPlayerId: map['teamPlayerId'] as int?,
      teamId: map['teamId'] as int?,
      playerName: map['playerName'] as String?,
      tournamentId: map['tournamentId'] as int?,
    );
  }
}
