class PlayerBattingResultModel {
  int? playerId;
  String? playerName;
  int? runs;
  int? balls;
  int? fours;
  int? sixes;
  double? strikeRate;
  bool? isOut;
  String? dismissalType; // 'bowled', 'caught', 'lbw', 'run-out', 'stumped', etc.
  String? dismissedBy; // bowler name or fielder name
  int? battingOrder; // position in batting order
  bool? isNotOut;
  
  PlayerBattingResultModel({
    this.playerId,
    this.playerName,
    this.runs,
    this.balls,
    this.fours,
    this.sixes,
    this.strikeRate,
    this.isOut,
    this.dismissalType,
    this.dismissedBy,
    this.battingOrder,
    this.isNotOut,
  });

  // Calculate strike rate automatically if not provided
  double get calculatedStrikeRate {
    if (balls == null || balls! == 0) return 0.0;
    return ((runs ?? 0) / balls!) * 100;
  }

  // Get dismissal info for display
  String get dismissalInfo {
    if (isNotOut == true) return "Not Out";
    if (dismissalType == null) return "Out";
    
    switch (dismissalType!.toLowerCase()) {
      case 'bowled':
        return "b $dismissedBy";
      case 'caught':
        return "c $dismissedBy";
      case 'lbw':
        return "lbw b $dismissedBy";
      case 'run-out':
        return "run out ($dismissedBy)";
      case 'stumped':
        return "st $dismissedBy";
      case 'hit-wicket':
        return "hit wicket";
      default:
        return dismissalType!;
    }
  }

  // Convert from database/API response
  factory PlayerBattingResultModel.fromJson(Map<String, dynamic> json) {
    return PlayerBattingResultModel(
      playerId: json['playerId'] as int?,
      playerName: json['playerName'] as String?,
      runs: json['runs'] as int?,
      balls: json['balls'] as int?,
      fours: json['fours'] as int?,
      sixes: json['sixes'] as int?,
      strikeRate: (json['strikeRate'] as num?)?.toDouble(),
      isOut: json['isOut'] as bool?,
      dismissalType: json['dismissalType'] as String?,
      dismissedBy: json['dismissedBy'] as String?,
      battingOrder: json['battingOrder'] as int?,
      isNotOut: json['isNotOut'] as bool?,
    );
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'strikeRate': strikeRate ?? calculatedStrikeRate,
      'isOut': isOut,
      'dismissalType': dismissalType,
      'dismissedBy': dismissedBy,
      'battingOrder': battingOrder,
      'isNotOut': isNotOut,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from database map
  PlayerBattingResultModel fromMap(Map<String, dynamic> map) {
    return PlayerBattingResultModel.fromJson(map);
  }
}
