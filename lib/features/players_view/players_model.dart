class PlayersModel {
  int? teamPlayerId; // Primary ID
  int? teamId;
  int? playerId;
  String? playerName;
  int? tournamentId;

  PlayersModel({
    this.teamPlayerId,
    this.teamId,
    this.playerId,
    this.playerName,
    this.tournamentId,
  });

  // Convert object to Map
  Map<String, dynamic> toMap() {
    return {
      'teamPlayerId': teamPlayerId,
      'teamId': teamId,
      'playerId': playerId,
      'playerName': playerName,
      if (tournamentId != null) 'tournamentId': tournamentId,
    };
  }

  // Create object from Map
  PlayersModel fromMap(Map<String, dynamic> map) {
    return PlayersModel(
      teamPlayerId: map['teamPlayerId'] as int?,
      teamId: map['teamId'] as int?,
      playerId: map['playerId'] as int?,
      playerName: map['playerName'] as String?,
      tournamentId: map['tournamentId'] as int?,
    );
  }
}
