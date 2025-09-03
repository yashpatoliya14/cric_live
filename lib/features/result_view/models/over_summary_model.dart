import 'ball_detail_model.dart';

class OverSummaryModel {
  int? overId;
  int? matchId;
  int? inningNo;
  int? overNumber; // 1, 2, 3, etc.
  int? bowlerId;
  String? bowlerName;
  int? totalRuns; // total runs scored in this over
  int? wickets; // wickets taken in this over
  bool? isMaiden; // true if no runs were scored
  List<BallDetailModel>? balls; // individual ball details
  List<String>? ballResults; // for quick display: ['1', '4', '0', 'W', '6', '2']
  
  OverSummaryModel({
    this.overId,
    this.matchId,
    this.inningNo,
    this.overNumber,
    this.bowlerId,
    this.bowlerName,
    this.totalRuns,
    this.wickets,
    this.isMaiden,
    this.balls,
    this.ballResults,
  });

  // Calculate total runs from balls if not provided
  int get calculatedTotalRuns {
    if (totalRuns != null) return totalRuns!;
    if (balls == null || balls!.isEmpty) return 0;
    return balls!.fold(0, (sum, ball) => sum + (ball.totalRuns));
  }

  // Calculate wickets from balls if not provided
  int get calculatedWickets {
    if (wickets != null) return wickets!;
    if (balls == null || balls!.isEmpty) return 0;
    return balls!.where((ball) => ball.isWicket == true).length;
  }

  // Check if it's a maiden over
  bool get calculatedIsMaiden {
    if (isMaiden != null) return isMaiden!;
    return calculatedTotalRuns == 0;
  }

  // Get ball results for display
  List<String> get displayBallResults {
    if (ballResults != null && ballResults!.isNotEmpty) {
      return ballResults!;
    }
    if (balls != null && balls!.isNotEmpty) {
      return balls!.map((ball) => ball.displayResult).toList();
    }
    return [];
  }

  // Get number of valid balls bowled (excluding wides and no-balls)
  int get validBalls {
    if (balls == null || balls!.isEmpty) return 0;
    return balls!.where((ball) => ball.countsTowardOver).length;
  }

  // Check if over is complete (6 valid balls)
  bool get isComplete {
    return validBalls >= 6;
  }

  // Get extras in this over
  int get extras {
    if (balls == null || balls!.isEmpty) return 0;
    int extras = 0;
    for (var ball in balls!) {
      if (ball.isWide == true) extras += 1;
      if (ball.isNoBall == true) extras += 1;
    }
    return extras;
  }

  // Get boundaries in this over
  int get boundaries {
    if (balls == null || balls!.isEmpty) return 0;
    return balls!.where((ball) => ball.isBoundary).length;
  }

  // Get dot balls in this over
  int get dotBalls {
    if (balls == null || balls!.isEmpty) return 0;
    return balls!.where((ball) => ball.isDotBall).length;
  }

  // Convert from database/API response
  factory OverSummaryModel.fromJson(Map<String, dynamic> json) {
    return OverSummaryModel(
      overId: json['overId'] as int?,
      matchId: json['matchId'] as int?,
      inningNo: json['inningNo'] as int?,
      overNumber: json['overNumber'] as int?,
      bowlerId: json['bowlerId'] as int?,
      bowlerName: json['bowlerName'] as String?,
      totalRuns: json['totalRuns'] as int?,
      wickets: json['wickets'] as int?,
      isMaiden: json['isMaiden'] as bool?,
      balls: json['balls'] != null 
          ? List<BallDetailModel>.from(
              json['balls'].map((x) => BallDetailModel.fromJson(x)))
          : null,
      ballResults: json['ballResults'] != null
          ? List<String>.from(json['ballResults'])
          : null,
    );
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'overId': overId,
      'matchId': matchId,
      'inningNo': inningNo,
      'overNumber': overNumber,
      'bowlerId': bowlerId,
      'bowlerName': bowlerName,
      'totalRuns': totalRuns ?? calculatedTotalRuns,
      'wickets': wickets ?? calculatedWickets,
      'isMaiden': isMaiden ?? calculatedIsMaiden,
      'balls': balls?.map((ball) => ball.toJson()).toList(),
      'ballResults': ballResults ?? displayBallResults,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from database map
  OverSummaryModel fromMap(Map<String, dynamic> map) {
    return OverSummaryModel.fromJson(map);
  }
}
