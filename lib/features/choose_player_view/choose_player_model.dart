/// Data model for a player.
class PlayerModel {
  int? teamPlayerId; // Primary ID
  int? teamId;
  String? playerName;
  int? tournamentId;

  PlayerModel({
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
  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      teamPlayerId: map['teamPlayerId'] as int?,
      teamId: map['teamId'] as int?,
      playerName: map['playerName'] as String?,
      tournamentId: map['tournamentId'] as int?,
    );
  }
}
