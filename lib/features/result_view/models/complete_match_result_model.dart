import 'team_innings_result_model.dart';

class CompleteMatchResultModel {
  int? matchId;
  String? matchTitle;
  String? location;
  DateTime? date;
  String? matchType; // 'T20', 'ODI', 'Test'
  String? status; // 'completed', 'scheduled', 'live'
  int? winnerTeamId;
  String? winnerTeamName;
  String? resultDescription; // 'Team A won by 5 wickets', 'Match tied', etc.
  int? tossWinnerTeamId;
  String? tossWinnerTeamName;
  String? tossDecision; // 'bat', 'bowl'
  String? playerOfTheMatch;
  int? playerOfTheMatchId;

  // Team innings data
  TeamInningsResultModel? team1Innings;
  TeamInningsResultModel? team2Innings;

  // Match statistics
  int? totalOvers;
  int? totalBalls;
  int? totalRuns;
  int? totalWickets;
  int? totalBoundaries;
  int? totalSixes;
  int? highestIndividualScore;
  int? highestTeamScore;
  
  // Live match specific data
  String? currentOverDisplay; // Current over balls display
  int? currentInning; // 1 or 2
  double? team1RunRate;
  double? team2RunRate;
  double? team2RequiredRunRate;
  int? ballsRemaining;
  int? runsToWin;
  
  // Team names for easier access
  String? team1Name;
  String? team2Name;

  CompleteMatchResultModel({
    this.matchId,
    this.matchTitle,
    this.location,
    this.date,
    this.matchType,
    this.status,
    this.winnerTeamId,
    this.winnerTeamName,
    this.resultDescription,
    this.tossWinnerTeamId,
    this.tossWinnerTeamName,
    this.tossDecision,
    this.playerOfTheMatch,
    this.playerOfTheMatchId,
    this.team1Innings,
    this.team2Innings,
    this.totalOvers,
    this.totalBalls,
    this.totalRuns,
    this.totalWickets,
    this.totalBoundaries,
    this.totalSixes,
    this.highestIndividualScore,
    this.highestTeamScore,
    this.currentOverDisplay,
    this.currentInning,
    this.team1RunRate,
    this.team2RunRate,
    this.team2RequiredRunRate,
    this.ballsRemaining,
    this.runsToWin,
    this.team1Name,
    this.team2Name,
  });

  // Get match summary for display
  String get matchSummary {
    if (resultDescription != null) return resultDescription!;

    // If match is live, show live status
    if (status?.toLowerCase() == 'live') {
      if (currentInning == 1) {
        String team1Score = team1Innings != null 
            ? "${team1Innings!.totalRuns ?? 0}/${team1Innings!.wickets ?? 0}"
            : "0/0";
        String team1OversText = team1Innings != null 
            ? " (${team1Innings!.oversDisplay})" 
            : "";
        return "$team1Name: $team1Score$team1OversText - Live";
      } else {
        String team1Score = team1Innings != null 
            ? "${team1Innings!.totalRuns ?? 0}/${team1Innings!.wickets ?? 0}"
            : "0/0";
        String team2Score = team2Innings != null 
            ? "${team2Innings!.totalRuns ?? 0}/${team2Innings!.wickets ?? 0}"
            : "0/0";
        String team2OversText = team2Innings != null 
            ? " (${team2Innings!.oversDisplay})" 
            : "";
        
        if (runsToWin != null && runsToWin! > 0) {
          return "$team2Name: $team2Score$team2OversText - Need $runsToWin runs - Live";
        } else {
          return "$team2Name: $team2Score$team2OversText - Live";
        }
      }
    }

    if (winnerTeamName != null) {
      // Try to calculate margin of victory
      if (team2Innings?.target != null && team2Innings?.totalRuns != null) {
        if (team2Innings!.totalRuns! >= team2Innings!.target!) {
          // Team 2 won by wickets
          int wicketsRemaining = 10 - (team2Innings!.wickets ?? 0);
          return "$winnerTeamName won by $wicketsRemaining wickets";
        } else {
          // Team 1 won by runs
          int runsMargin = team2Innings!.target! - team2Innings!.totalRuns! - 1;
          return "$winnerTeamName won by $runsMargin runs";
        }
      }
      return "$winnerTeamName won";
    }

    return "Match completed";
  }

  // Get toss summary
  String get tossSummary {
    if (tossWinnerTeamName == null) return "";
    String decision =
        tossDecision == 'bat' ? 'elected to bat' : 'elected to bowl';
    return "$tossWinnerTeamName won the toss and $decision";
  }

  // Check if match was a tie
  bool get isTie {
    return team1Innings?.totalRuns == team2Innings?.totalRuns;
  }

  // Check if match had a super over
  bool get hasSuperOver {
    // This would need more complex logic to determine super over
    return false;
  }

  // Get highest team score (override getter to use stored value or calculate)
  int get calculatedHighestTeamScore {
    if (highestTeamScore != null) return highestTeamScore!;
    int team1Score = team1Innings?.totalRuns ?? 0;
    int team2Score = team2Innings?.totalRuns ?? 0;
    return team1Score > team2Score ? team1Score : team2Score;
  }

  // Get highest individual score in match (override getter to use stored value or calculate)
  int get calculatedHighestIndividualScore {
    if (highestIndividualScore != null) return highestIndividualScore!;
    int team1Highest = team1Innings?.highestScore ?? 0;
    int team2Highest = team2Innings?.highestScore ?? 0;
    return team1Highest > team2Highest ? team1Highest : team2Highest;
  }

  // Check if match is live
  bool get isLive {
    return status?.toLowerCase() == 'live';
  }

  // Check if match is completed
  bool get isCompleted {
    return status?.toLowerCase() == 'completed';
  }

  // Get current batting team name
  String get currentBattingTeam {
    if (currentInning == 1) return team1Name ?? 'Team 1';
    if (currentInning == 2) return team2Name ?? 'Team 2';
    return 'Unknown';
  }

  // Get current bowling team name
  String get currentBowlingTeam {
    if (currentInning == 1) return team2Name ?? 'Team 2';
    if (currentInning == 2) return team1Name ?? 'Team 1';
    return 'Unknown';
  }

  // Get match total boundaries (both teams)
  int get calculatedMatchBoundaries {
    if (totalBoundaries != null) return totalBoundaries!;
    return (team1Innings?.totalBoundaries ?? 0) + (team2Innings?.totalBoundaries ?? 0);
  }

  // Get match total sixes (both teams)
  int get calculatedMatchSixes {
    if (totalSixes != null) return totalSixes!;
    return (team1Innings?.totalSixes ?? 0) + (team2Innings?.totalSixes ?? 0);
  }

  // Get total boundaries in match (simplified - removed overs dependency)
  int get calculatedTotalBoundaries {
    return calculatedMatchBoundaries;
  }

  // Get match format display
  String get formatDisplay {
    switch (matchType?.toLowerCase()) {
      case 't20':
        return 'T20';
      case 'odi':
        return 'One Day International';
      case 'test':
        return 'Test Match';
      default:
        return matchType ?? 'Cricket Match';
    }
  }

  // Get match date formatted
  DateTime? get formattedDate {
    if (date == null) return null;
    // You can add date formatting logic here
    return date!;
  }

  // Get all batting performances sorted by runs
  List<dynamic> get topBattingPerformances {
    List<dynamic> allBatsmen = [];

    if (team1Innings?.battingResults != null) {
      allBatsmen.addAll(team1Innings!.battingResults!);
    }
    if (team2Innings?.battingResults != null) {
      allBatsmen.addAll(team2Innings!.battingResults!);
    }

    allBatsmen.sort((a, b) => (b.runs ?? 0).compareTo(a.runs ?? 0));
    return allBatsmen;
  }

  // Get all bowling performances sorted by wickets
  List<dynamic> get topBowlingPerformances {
    List<dynamic> allBowlers = [];

    if (team1Innings?.bowlingResults != null) {
      allBowlers.addAll(team1Innings!.bowlingResults!);
    }
    if (team2Innings?.bowlingResults != null) {
      allBowlers.addAll(team2Innings!.bowlingResults!);
    }

    allBowlers.sort((a, b) {
      int wicketCompare = (b.wickets ?? 0).compareTo(a.wickets ?? 0);
      if (wicketCompare != 0) return wicketCompare;
      return (a.economyRate ?? double.infinity).compareTo(
        b.economyRate ?? double.infinity,
      );
    });
    return allBowlers;
  }

  int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  // Convert from database/API response
  CompleteMatchResultModel fromJson(Map<String, dynamic> json) {
    return CompleteMatchResultModel(
      matchId: toInt(json['matchId']),
      matchTitle: json['matchTitle'] as String?,
      location: json['venue'] as String?,
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      matchType: json['matchType'] as String?,
      status: json['status'] as String?,
      winnerTeamId: toInt(json['winnerTeamId']),
      winnerTeamName: json['winnerTeamName'] as String?,
      resultDescription: json['resultDescription'] as String?,
      tossWinnerTeamId: toInt(json['tossWinnerTeamId']),
      tossWinnerTeamName: json['tossWinnerTeamName'] as String?,
      tossDecision: json['tossDecision'] as String?,
      playerOfTheMatch: json['playerOfTheMatch'] as String?,
      playerOfTheMatchId: toInt(json['playerOfTheMatchId']),
      team1Innings:
          json['team1Innings'] != null
              ? TeamInningsResultModel.fromJson(json['team1Innings'])
              : null,
      team2Innings:
          json['team2Innings'] != null
              ? TeamInningsResultModel.fromJson(json['team2Innings'])
              : null,
      totalOvers: toInt(json['totalOvers']),
      totalBalls: toInt(json['totalBalls']),
      totalRuns: toInt(json['totalRuns']),
      totalWickets: toInt(json['totalWickets']),
      totalBoundaries: toInt(json['totalBoundaries']),
      totalSixes: toInt(json['totalSixes']),
      highestIndividualScore: toInt(json['highestIndividualScore']),
      highestTeamScore: toInt(json['highestTeamScore']),
      currentOverDisplay: json['currentOverDisplay'] as String?,
      currentInning: toInt(json['currentInning']),
      team1RunRate: (json['team1RunRate'] as num?)?.toDouble(),
      team2RunRate: (json['team2RunRate'] as num?)?.toDouble(),
      team2RequiredRunRate: (json['team2RequiredRunRate'] as num?)?.toDouble(),
      ballsRemaining: toInt(json['ballsRemaining']),
      runsToWin: toInt(json['runsToWin']),
      team1Name: json['team1Name'] as String?,
      team2Name: json['team2Name'] as String?,
    );
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'matchTitle': matchTitle,
      'location': location,
      'date': date.toString(),
      'matchType': matchType,
      'status': status,
      'winnerTeamId': winnerTeamId,
      'winnerTeamName': winnerTeamName,
      'resultDescription': resultDescription ?? matchSummary,
      'tossWinnerTeamId': tossWinnerTeamId,
      'tossWinnerTeamName': tossWinnerTeamName,
      'tossDecision': tossDecision,
      'playerOfTheMatch': playerOfTheMatch,
      'playerOfTheMatchId': playerOfTheMatchId,
      'team1Innings': team1Innings?.toJson(),
      'team2Innings': team2Innings?.toJson(),
      'totalOvers': totalOvers,
      'totalBalls': totalBalls,
      'totalRuns': totalRuns,
      'totalWickets': totalWickets,
      'totalBoundaries': totalBoundaries ?? calculatedMatchBoundaries,
      'totalSixes': totalSixes ?? calculatedMatchSixes,
      'highestIndividualScore': highestIndividualScore ?? calculatedHighestIndividualScore,
      'highestTeamScore': highestTeamScore ?? calculatedHighestTeamScore,
      'currentOverDisplay': currentOverDisplay,
      'currentInning': currentInning,
      'team1RunRate': team1RunRate,
      'team2RunRate': team2RunRate,
      'team2RequiredRunRate': team2RequiredRunRate,
      'ballsRemaining': ballsRemaining,
      'runsToWin': runsToWin,
      'team1Name': team1Name,
      'team2Name': team2Name,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from database map
  CompleteMatchResultModel fromMap(Map<String, dynamic> map) {
    return CompleteMatchResultModel().fromJson(map);
  }
}
