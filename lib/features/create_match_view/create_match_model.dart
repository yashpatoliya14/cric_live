class CreateMatchModel {
  int? id;
  int? team1;
  int? team2;
  int? uid;
  int? matchIdOnline;
  DateTime? matchDate;
  int? inningNo;
  int? overs;
  String? status; // 'live', 'completed', 'scheduled'
  int? tossWon;
  String? decision; // default: 'remain'
  int? tournamentId;
  int wideRun; // default: 0
  int noBallRun; // default: 0
  int? strikerBatsmanId;
  int? nonStrikerBatsmanId;
  int? bowlerId;
  int? currentBattingTeamId;
  String? matchState;
  String? team1Name;
  String? team2Name;

  CreateMatchModel({
    this.id,
    this.team1Name,
    this.team2Name,
    this.matchIdOnline,
    this.team1,
    this.team2,
    this.matchDate,
    this.inningNo,
    this.overs,
    this.status,
    this.tossWon,
    this.decision = 'remain',
    this.tournamentId,
    this.wideRun = 0,
    this.noBallRun = 0,
    this.strikerBatsmanId,
    this.nonStrikerBatsmanId,
    this.bowlerId,
    this.currentBattingTeamId,
    this.matchState,
    this.uid,
  });

  /// Convert object to map for DB insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchIdOnline': matchIdOnline,
      'team1': team1,
      'team2': team2,
      'uid': uid,
      'matchDate': matchDate?.toIso8601String(),
      'inningNo': inningNo,
      'overs': overs,
      'status': status,
      'tossWon': tossWon,
      'decision': decision ?? 'remain',
      'tournamentId': tournamentId,
      'wideRun': wideRun,
      'noBallRun': noBallRun,
      'strikerBatsmanId': strikerBatsmanId,
      'nonStrikerBatsmanId': nonStrikerBatsmanId,
      'bowlerId': bowlerId,
      'currentBattingTeamId': currentBattingTeamId,
      'matchState': matchState,
    };
  }

  /// Create object from map (e.g. from DB/API)
  factory CreateMatchModel.fromMap(Map<String, dynamic> map) {
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return CreateMatchModel(
      id: safeParseInt(map['id']),
      matchIdOnline: safeParseInt(map["matchIdOnline"]),
      team1: safeParseInt(map['team1']),
      team2: safeParseInt(map['team2']),
      matchDate:
          map['matchDate'] == null
              ? null
              : DateTime.tryParse(map['matchDate'].toString()),
      inningNo: safeParseInt(map['inningNo']),
      overs: safeParseInt(map['overs']),
      status: map['status']?.toString(),
      tossWon: safeParseInt(map['tossWon']),
      decision: map['decision']?.toString() ?? 'remain',
      tournamentId: safeParseInt(map['tournamentId']),
      wideRun: safeParseInt(map['wideRun']) ?? 0,
      noBallRun: safeParseInt(map['noBallRun']) ?? 0,
      strikerBatsmanId: safeParseInt(map['strikerBatsmanId']),
      nonStrikerBatsmanId: safeParseInt(map['nonStrikerBatsmanId']),
      bowlerId: safeParseInt(map['bowlerId']),
      currentBattingTeamId: safeParseInt(map['currentBattingTeamId']),
      matchState: map['matchState']?.toString(),
      uid: safeParseInt(map['uid']),
      team1Name: map['team1Name']?.toString(),
      team2Name: map['team2Name']?.toString(),
    );
  }
}
