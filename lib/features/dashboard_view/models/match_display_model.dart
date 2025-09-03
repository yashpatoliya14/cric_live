import 'package:cric_live/features/create_match_view/create_match_model.dart';
import 'package:cric_live/features/result_view/models/complete_match_result_model.dart';

class MatchDisplayModel {
  final CreateMatchModel matchData;
  final CompleteMatchResultModel? matchResult;

  MatchDisplayModel({
    required this.matchData,
    this.matchResult,
  });

  // Get team names from match result or fallback
  String get team1Name => matchResult?.team1Innings?.teamName ?? 'Team ${matchData.team1 ?? 1}';
  String get team2Name => matchResult?.team2Innings?.teamName ?? 'Team ${matchData.team2 ?? 2}';
  
  String get matchStatus {
    switch (matchData.status?.toLowerCase()) {
      case 'live':
        return 'LIVE';
      case 'completed':
        return 'COMPLETED';
      case 'scheduled':
        return 'UPCOMING';
      default:
        return 'UNKNOWN';
    }
  }

  String get statusDescription {
    if (matchData.status?.toLowerCase() == 'live') {
      // For live matches, show current inning info
      if (matchData.inningNo == 1) {
        return '1st Innings';
      } else if (matchData.inningNo == 2) {
        return '2nd Innings';
      }
      return 'Match in progress';
    } else if (matchData.status?.toLowerCase() == 'completed') {
      return _getMatchResultText();
    } else if (matchData.status?.toLowerCase() == 'scheduled') {
      return 'Match scheduled';
    }
    return 'Status unknown';
  }

  // Get team 1 score and wickets
  String get team1DisplayScore {
    if (matchResult?.team1Innings?.totalRuns != null) {
      int runs = matchResult!.team1Innings!.totalRuns!;
      int wickets = matchResult!.team1Innings!.wickets ?? 0;
      return '$runs/$wickets';
    }
    return '-';
  }

  // Get team 2 score and wickets  
  String get team2DisplayScore {
    if (matchResult?.team2Innings?.totalRuns != null) {
      int runs = matchResult!.team2Innings!.totalRuns!;
      int wickets = matchResult!.team2Innings!.wickets ?? 0;
      return '$runs/$wickets';
    }
    return '-';
  }

  // Get team 1 overs
  String get team1DisplayOvers {
    if (matchResult?.team1Innings?.overs != null) {
      return '(${matchResult!.team1Innings!.overs!.toStringAsFixed(1)})';
    }
    return '-';
  }

  // Get team 2 overs
  String get team2DisplayOvers {
    if (matchResult?.team2Innings?.overs != null) {
      return '(${matchResult!.team2Innings!.overs!.toStringAsFixed(1)})';
    }
    return '-';
  }

  // Private method to get match result text
  String _getMatchResultText() {
    if (matchResult == null) return 'Match completed';
    
    var team1Runs = matchResult!.team1Innings?.totalRuns ?? 0;
    var team2Runs = matchResult!.team2Innings?.totalRuns ?? 0;
    
    if (team1Runs > team2Runs) {
      int margin = team1Runs - team2Runs;
      return '$team1Name won by $margin runs';
    } else if (team2Runs > team1Runs) {
      int wicketsRemaining = 10 - (matchResult!.team2Innings?.wickets ?? 0);
      return '$team2Name won by $wicketsRemaining wickets';
    } else {
      return 'Match tied';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'matchData': matchData.toMap(),
      'matchResult': matchResult?.toMap(),
    };
  }
}
