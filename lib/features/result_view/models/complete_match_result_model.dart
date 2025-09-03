import 'over_summary_model.dart';
import 'team_innings_result_model.dart';

class CompleteMatchResultModel {
  int? matchId;
  String? matchTitle;
  String? venue;
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

  // Over by over data
  List<OverSummaryModel>? team1Overs;
  List<OverSummaryModel>? team2Overs;

  // Match statistics
  int? totalOvers;
  int? totalBalls;
  int? totalRuns;
  int? totalWickets;
  int? totalBoundaries;
  int? totalSixes;

  CompleteMatchResultModel({
    this.matchId,
    this.matchTitle,
    this.venue,
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
    this.team1Overs,
    this.team2Overs,
    this.totalOvers,
    this.totalBalls,
    this.totalRuns,
    this.totalWickets,
    this.totalBoundaries,
    this.totalSixes,
  });

  // Get match summary for display
  String get matchSummary {
    if (resultDescription != null) return resultDescription!;

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

  // Get highest team score
  int get highestTeamScore {
    int team1Score = team1Innings?.totalRuns ?? 0;
    int team2Score = team2Innings?.totalRuns ?? 0;
    return team1Score > team2Score ? team1Score : team2Score;
  }

  // Get highest individual score in match
  int get highestIndividualScore {
    int team1Highest = team1Innings?.highestScore ?? 0;
    int team2Highest = team2Innings?.highestScore ?? 0;
    return team1Highest > team2Highest ? team1Highest : team2Highest;
  }

  // Get total boundaries in match
  int get calculatedTotalBoundaries {
    if (totalBoundaries != null) return totalBoundaries!;

    int boundaries = 0;
    if (team1Overs != null) {
      boundaries += team1Overs!.fold(0, (sum, over) => sum + over.boundaries);
    }
    if (team2Overs != null) {
      boundaries += team2Overs!.fold(0, (sum, over) => sum + over.boundaries);
    }
    return boundaries;
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
      venue: json['venue'] as String?,
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
      team1Overs:
          json['team1Overs'] != null
              ? List<OverSummaryModel>.from(
                json['team1Overs'].map((x) => OverSummaryModel.fromJson(x)),
              )
              : null,
      team2Overs:
          json['team2Overs'] != null
              ? List<OverSummaryModel>.from(
                json['team2Overs'].map((x) => OverSummaryModel.fromJson(x)),
              )
              : null,
      totalOvers: toInt(json['totalOvers']),
      totalBalls: toInt(json['totalBalls']),
      totalRuns: toInt(json['totalRuns']),
      totalWickets: toInt(json['totalWickets']),
      totalBoundaries: toInt(json['totalBoundaries']),
      totalSixes: toInt(json['totalSixes']),
    );
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'matchTitle': matchTitle,
      'venue': venue,
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
      'team1Overs': team1Overs?.map((over) => over.toJson()).toList(),
      'team2Overs': team2Overs?.map((over) => over.toJson()).toList(),
      'totalOvers': totalOvers,
      'totalBalls': totalBalls,
      'totalRuns': totalRuns,
      'totalWickets': totalWickets,
      'totalBoundaries': totalBoundaries ?? calculatedTotalBoundaries,
      'totalSixes': totalSixes,
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
