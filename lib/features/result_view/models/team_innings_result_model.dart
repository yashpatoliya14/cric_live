import 'player_batting_result_model.dart';
import 'player_bowling_result_model.dart';

class TeamInningsResultModel {
  int? teamId;
  String? teamName;
  int? inningNo; // 1 or 2
  int? totalRuns;
  int? wickets;
  double? overs; // e.g., 19.4
  double? runRate; // current run rate
  double? requiredRunRate; // if chasing
  int? target; // target runs if chasing
  bool? isAllOut;
  bool? isDeclared;
  List<PlayerBattingResultModel>? battingResults;
  List<PlayerBowlingResultModel>? bowlingResults; // opposition bowlers
  int? extras;
  int? wides;
  int? noBalls;
  int? byes;
  int? legByes;
  int? penalties;
  int? totalBoundaries; // total 4s hit by team
  int? totalSixes; // total 6s hit by team
  
  TeamInningsResultModel({
    this.teamId,
    this.teamName,
    this.inningNo,
    this.totalRuns,
    this.wickets,
    this.overs,
    this.runRate,
    this.requiredRunRate,
    this.target,
    this.isAllOut,
    this.isDeclared,
    this.battingResults,
    this.bowlingResults,
    this.extras,
    this.wides,
    this.noBalls,
    this.byes,
    this.legByes,
    this.penalties,
    this.totalBoundaries,
    this.totalSixes,
  });

  // Calculate run rate automatically if not provided
  double get calculatedRunRate {
    if (runRate != null) return runRate!;
    if (overs == null || overs! == 0.0) return 0.0;
    return (totalRuns ?? 0) / overs!;
  }

  // Calculate total extras
  int get calculatedExtras {
    if (extras != null) return extras!;
    return (wides ?? 0) + (noBalls ?? 0) + (byes ?? 0) + (legByes ?? 0) + (penalties ?? 0);
  }

  // Format score for display (e.g., "150/4")
  String get scoreDisplay {
    String score = "${totalRuns ?? 0}";
    
    if (isAllOut == true) {
      score += " all out";
    } else if (isDeclared == true) {
      score += " declared";
    } else {
      score += "/${wickets ?? 0}";
    }
    
    return score;
  }

  // Format overs for display (e.g., "19.4")
  String get oversDisplay {
    if (overs == null) return "0.0";
    return overs!.toStringAsFixed(1);
  }

  // Get runs needed (if chasing)
  int get runsNeeded {
    if (target == null) return 0;
    return target! - (totalRuns ?? 0);
  }

  // Get balls remaining (assuming 20 overs max)
  int get ballsRemaining {
    if (overs == null) return 120; // 20 overs = 120 balls
    double maxOvers = 20.0; // You can make this configurable
    double remainingOvers = maxOvers - overs!;
    if (remainingOvers <= 0) return 0;
    
    int fullOvers = remainingOvers.floor();
    double remainder = remainingOvers - fullOvers;
    int extraBalls = ((1.0 - remainder) * 6).round();
    return (fullOvers * 6) + extraBalls;
  }

  // Check if innings is complete
  bool get isInningsComplete {
    return isAllOut == true || 
           isDeclared == true || 
           (target != null && (totalRuns ?? 0) >= target!) ||
           overs! >= 20.0; // assuming 20 over format
  }

  // Get highest individual score
  int get highestScore {
    if (battingResults == null || battingResults!.isEmpty) return 0;
    return battingResults!
        .map((player) => player.runs ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  // Get highest partnership
  // This would need more complex logic to calculate partnerships
  // For now, just return 0
  int get highestPartnership {
    // TODO: Implement partnership calculation
    return 0;
  }

  // Convert from database/API response
  factory TeamInningsResultModel.fromJson(Map<String, dynamic> json) {
    return TeamInningsResultModel(
      teamId: json['teamId'] as int?,
      teamName: json['teamName'] as String?,
      inningNo: json['inningNo'] as int?,
      totalRuns: json['totalRuns'] as int?,
      wickets: json['wickets'] as int?,
      overs: (json['overs'] as num?)?.toDouble(),
      runRate: (json['runRate'] as num?)?.toDouble(),
      requiredRunRate: (json['requiredRunRate'] as num?)?.toDouble(),
      target: json['target'] as int?,
      isAllOut: json['isAllOut'] as bool?,
      isDeclared: json['isDeclared'] as bool?,
      battingResults: json['battingResults'] != null
          ? List<PlayerBattingResultModel>.from(
              json['battingResults'].map((x) => PlayerBattingResultModel.fromJson(x)))
          : null,
      bowlingResults: json['bowlingResults'] != null
          ? List<PlayerBowlingResultModel>.from(
              json['bowlingResults'].map((x) => PlayerBowlingResultModel.fromJson(x)))
          : null,
      extras: json['extras'] as int?,
      wides: json['wides'] as int?,
      noBalls: json['noBalls'] as int?,
      byes: json['byes'] as int?,
      legByes: json['legByes'] as int?,
      penalties: json['penalties'] as int?,
      totalBoundaries: json['totalBoundaries'] as int?,
      totalSixes: json['totalSixes'] as int?,
    );
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'inningNo': inningNo,
      'totalRuns': totalRuns,
      'wickets': wickets,
      'overs': overs,
      'runRate': runRate ?? calculatedRunRate,
      'requiredRunRate': requiredRunRate,
      'target': target,
      'isAllOut': isAllOut,
      'isDeclared': isDeclared,
      'battingResults': battingResults?.map((player) => player.toJson()).toList(),
      'bowlingResults': bowlingResults?.map((bowler) => bowler.toJson()).toList(),
      'extras': extras ?? calculatedExtras,
      'wides': wides,
      'noBalls': noBalls,
      'byes': byes,
      'legByes': legByes,
      'penalties': penalties,
      'totalBoundaries': totalBoundaries,
      'totalSixes': totalSixes,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from database map
  TeamInningsResultModel fromMap(Map<String, dynamic> map) {
    return TeamInningsResultModel.fromJson(map);
  }
}
