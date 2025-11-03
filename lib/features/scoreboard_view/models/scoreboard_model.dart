class ScoreboardModel {
  int? id;
  int? matchId; // required
  int? inningNo; // required
  int? totalOvers;
  int? strikerBatsmanId; // player ID
  int? nonStrikerBatsmanId; // player ID
  int? bowlerId; // bowler player ID
  int? runs;
  double? currentOvers;
  int? isWicket; // 1 = true or 0 = false
  String? wicketType;
  int? isNoBall;
  int? isWide;
  int? isBye;
  int? isStored;

  ScoreboardModel({
    this.id,
    this.matchId,
    this.inningNo,
    this.totalOvers,
    this.strikerBatsmanId,
    this.nonStrikerBatsmanId,
    this.bowlerId,
    this.runs,
    this.currentOvers,
    this.isWicket,
    this.wicketType,
    this.isNoBall,
    this.isWide,
    this.isBye,
    this.isStored,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchId': matchId,
      'inningNo': inningNo,
      'totalOvers': totalOvers,
      'strikerBatsmanId': strikerBatsmanId,
      'nonStrikerBatsmanId': nonStrikerBatsmanId,
      'bowlerId': bowlerId,
      'runs': runs,
      'currentOvers': currentOvers,
      'isWicket': isWicket,
      'wicketType': wicketType,
      'isNoBall': isNoBall,
      'isWide': isWide,
      'isBye': isBye,
      'isStored': isStored,
    };
  }

  ScoreboardModel fromMap(Map<String, dynamic> map) {
    return ScoreboardModel(
      id: map['id'] as int?,
      matchId: map['matchId'] as int?,
      inningNo: map['inningNo'] as int?,
      totalOvers: map['totalOvers'] as int?,
      strikerBatsmanId: map['strikerBatsmanId'] as int?,
      nonStrikerBatsmanId: map['nonStrikerBatsmanId'] as int?,
      bowlerId: map['bowlerId'] as int?,
      runs: map['runs'] as int?,
      currentOvers: map['currentOvers'] as double?,
      isWicket: map['isWicket'] as int?,
      wicketType: map['wicketType'] as String?,
      isNoBall: map['isNoBall'] as int?,
      isWide: map['isWide'] as int?,
      isBye: map['isBye'] as int?,
      isStored: map['isStored'] as int?,
    );
  }
}
