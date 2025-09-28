class BallDetailModel {
  int? ballId;
  int? overId;
  int? matchId;
  int? inningNo;
  int? ballNumber; // 1-6 for each ball in the over
  int? bowlerId;
  String? bowlerName;
  int? batsmanId;
  String? batsmanName;
  int? runs; // runs scored off this ball
  bool? isWide;
  bool? isNoBall;
  bool? isBye;
  bool? isLegBye;
  bool? isWicket;
  String? wicketType;
  int? wicketPlayerId; // player who got out
  String? wicketPlayerName;
  String? ballResult; // for display: '0', '1', '2', '3', '4', '6', 'W', 'Wd', 'Nb'
  
  BallDetailModel({
    this.ballId,
    this.overId,
    this.matchId,
    this.inningNo,
    this.ballNumber,
    this.bowlerId,
    this.bowlerName,
    this.batsmanId,
    this.batsmanName,
    this.runs,
    this.isWide,
    this.isNoBall,
    this.isBye,
    this.isLegBye,
    this.isWicket,
    this.wicketType,
    this.wicketPlayerId,
    this.wicketPlayerName,
    this.ballResult,
  });

  // Get ball result for display in UI
  String get displayResult {
    if (ballResult != null) return ballResult!;
    
    if (isWicket == true) return 'W';
    if (isWide == true) return 'Wd';
    if (isNoBall == true) return 'Nb';
    
    return (runs ?? 0).toString();
  }

  // Check if it's a boundary (4 or 6)
  bool get isBoundary {
    return runs == 4 || runs == 6;
  }

  // Check if it's a dot ball (no runs and no extras)
  bool get isDotBall {
    return (runs ?? 0) == 0 && 
           !(isWide == true) && 
           !(isNoBall == true) && 
           !(isBye == true) && 
           !(isLegBye == true);
  }

  // Get total runs including extras
  int get totalRuns {
    int baseRuns = runs ?? 0;
    int extraRuns = 0;
    
    if (isWide == true) extraRuns += 1;
    if (isNoBall == true) extraRuns += 1;
    
    return baseRuns + extraRuns;
  }

  // Check if this ball counts towards the over (wides and no-balls don't count)
  bool get countsTowardOver {
    return !(isWide == true) && !(isNoBall == true);
  }

  // Convert from database/API response
  factory BallDetailModel.fromJson(Map<String, dynamic> json) {
    return BallDetailModel(
      ballId: json['ballId'] as int?,
      overId: json['overId'] as int?,
      matchId: json['matchId'] as int?,
      inningNo: json['inningNo'] as int?,
      ballNumber: json['ballNumber'] as int?,
      bowlerId: json['bowlerId'] as int?,
      bowlerName: json['bowlerName'] as String?,
      batsmanId: json['batsmanId'] as int?,
      batsmanName: json['batsmanName'] as String?,
      runs: json['runs'] as int?,
      isWide: _toBool(json['isWide']),
      isNoBall: _toBool(json['isNoBall']),
      isBye: _toBool(json['isBye']),
      isLegBye: _toBool(json['isLegBye']),
      isWicket: _toBool(json['isWicket']),
      wicketType: json['wicketType'] as String?,
      wicketPlayerId: json['wicketPlayerId'] as int?,
      wicketPlayerName: json['wicketPlayerName'] as String?,
      ballResult: json['ballResult'] as String?,
    );
  }

  // Helper method to safely convert various types to bool?
  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'ballId': ballId,
      'overId': overId,
      'matchId': matchId,
      'inningNo': inningNo,
      'ballNumber': ballNumber,
      'bowlerId': bowlerId,
      'bowlerName': bowlerName,
      'batsmanId': batsmanId,
      'batsmanName': batsmanName,
      'runs': runs,
      'isWide': isWide,
      'isNoBall': isNoBall,
      'isBye': isBye,
      'isLegBye': isLegBye,
      'isWicket': isWicket,
      'wicketType': wicketType,
      'wicketPlayerId': wicketPlayerId,
      'wicketPlayerName': wicketPlayerName,
      'ballResult': ballResult ?? displayResult,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from database map
  BallDetailModel fromMap(Map<String, dynamic> map) {
    return BallDetailModel.fromJson(map);
  }
}
