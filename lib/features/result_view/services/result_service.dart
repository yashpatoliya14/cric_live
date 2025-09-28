import 'package:cric_live/features/result_view/models/index.dart';

class ResultService {
  
  /// Calculate match statistics from complete match result
  static Map<String, dynamic> calculateMatchStatistics(CompleteMatchResultModel matchResult) {
    Map<String, dynamic> stats = {};
    
    // Basic match stats
    stats['totalRuns'] = (matchResult.team1Innings?.totalRuns ?? 0) + (matchResult.team2Innings?.totalRuns ?? 0);
    stats['totalWickets'] = (matchResult.team1Innings?.wickets ?? 0) + (matchResult.team2Innings?.wickets ?? 0);
    stats['totalOvers'] = (matchResult.team1Innings?.overs ?? 0.0) + (matchResult.team2Innings?.overs ?? 0.0);
    stats['totalBoundaries'] = _calculateTotalBoundaries(matchResult);
    stats['totalSixes'] = _calculateTotalSixes(matchResult);
    
    // Match result analysis
    stats['winMargin'] = _calculateWinMargin(matchResult);
    stats['winType'] = _determineWinType(matchResult);
    
    // Performance highlights
    stats['topBatsman'] = _getTopBatsman(matchResult);
    stats['topBowler'] = _getTopBowler(matchResult);
    stats['playerOfMatch'] = matchResult.playerOfTheMatch;
    
    return stats;
  }
  
  /// Calculate team performance comparison
  static Map<String, dynamic> compareTeamPerformances(
    TeamInningsResultModel? team1, 
    TeamInningsResultModel? team2
  ) {
    if (team1 == null || team2 == null) {
      return {'error': 'Missing team data'};
    }
    
    return {
      'runRate': {
        'team1': team1.calculatedRunRate,
        'team2': team2.calculatedRunRate,
        'difference': (team1.calculatedRunRate - team2.calculatedRunRate).abs(),
      },
      'boundaries': {
        'team1': _countTeamBoundaries(team1),
        'team2': _countTeamBoundaries(team2),
      },
      'extras': {
        'team1': team1.calculatedExtras,
        'team2': team2.calculatedExtras,
      },
      'wickets': {
        'team1': team1.wickets ?? 0,
        'team2': team2.wickets ?? 0,
      },
      'partnership': {
        'team1': _calculateHighestPartnership(team1),
        'team2': _calculateHighestPartnership(team2),
      }
    };
  }
  
  /// Analyze bowling performance across the match
  static Map<String, dynamic> analyzeBowlingPerformance(CompleteMatchResultModel matchResult) {
    List<PlayerBowlingResultModel> allBowlers = [];
    
    if (matchResult.team1Innings?.bowlingResults != null) {
      allBowlers.addAll(matchResult.team1Innings!.bowlingResults!);
    }
    if (matchResult.team2Innings?.bowlingResults != null) {
      allBowlers.addAll(matchResult.team2Innings!.bowlingResults!);
    }
    
    if (allBowlers.isEmpty) {
      return {'error': 'No bowling data available'};
    }
    
    // Sort by wickets, then by economy rate
    allBowlers.sort((a, b) {
      int wicketCompare = (b.wickets ?? 0).compareTo(a.wickets ?? 0);
      if (wicketCompare != 0) return wicketCompare;
      return (a.economyRate ?? double.infinity).compareTo(b.economyRate ?? double.infinity);
    });
    
    return {
      'bestBowler': allBowlers.first,
      'mostWickets': allBowlers.first.wickets ?? 0,
      'bestEconomy': allBowlers.where((b) => (b.overs ?? 0.0) >= 2.0)
          .fold<double>(double.infinity, (prev, b) => 
              (b.economyRate ?? double.infinity) < prev ? (b.economyRate ?? double.infinity) : prev),
      'totalMaidens': allBowlers.fold<int>(0, (sum, b) => sum + (b.maidens ?? 0)),
      'averageEconomy': allBowlers.fold<double>(0.0, (sum, b) => sum + (b.economyRate ?? 0.0)) / allBowlers.length,
    };
  }
  
  /// Analyze batting performance across the match
  static Map<String, dynamic> analyzeBattingPerformance(CompleteMatchResultModel matchResult) {
    List<PlayerBattingResultModel> allBatsmen = [];
    
    if (matchResult.team1Innings?.battingResults != null) {
      allBatsmen.addAll(matchResult.team1Innings!.battingResults!);
    }
    if (matchResult.team2Innings?.battingResults != null) {
      allBatsmen.addAll(matchResult.team2Innings!.battingResults!);
    }
    
    if (allBatsmen.isEmpty) {
      return {'error': 'No batting data available'};
    }
    
    // Sort by runs scored
    allBatsmen.sort((a, b) => (b.runs ?? 0).compareTo(a.runs ?? 0));
    
    return {
      'topScorer': allBatsmen.first,
      'highestScore': allBatsmen.first.runs ?? 0,
      'totalBoundaries': allBatsmen.fold<int>(0, (sum, b) => sum + (b.fours ?? 0) + (b.sixes ?? 0)),
      'averageStrikeRate': allBatsmen.fold<double>(0.0, (sum, b) => sum + (b.strikeRate ?? 0.0)) / allBatsmen.length,
      'totalNotOut': allBatsmen.where((b) => b.isNotOut == true).length,
      'totalDucks': allBatsmen.where((b) => (b.runs ?? 0) == 0 && b.isOut == true).length,
    };
  }
  
  /// Calculate match momentum (simplified without over-by-over data)
  static List<Map<String, dynamic>> calculateMatchMomentum(CompleteMatchResultModel matchResult) {
    List<Map<String, dynamic>> momentum = [];
    
    // Since over-by-over data is not available, provide team-level momentum
    if (matchResult.team1Innings != null) {
      momentum.add({
        'inning': 1,
        'teamName': matchResult.team1Name ?? 'Team 1',
        'totalRuns': matchResult.team1Innings!.totalRuns ?? 0,
        'totalWickets': matchResult.team1Innings!.wickets ?? 0,
        'runRate': matchResult.team1Innings!.calculatedRunRate,
        'momentum': 'steady', // Could be enhanced based on other factors
      });
    }
    
    if (matchResult.team2Innings != null) {
      momentum.add({
        'inning': 2,
        'teamName': matchResult.team2Name ?? 'Team 2',
        'totalRuns': matchResult.team2Innings!.totalRuns ?? 0,
        'totalWickets': matchResult.team2Innings!.wickets ?? 0,
        'runRate': matchResult.team2Innings!.calculatedRunRate,
        'momentum': 'steady', // Could be enhanced based on other factors
      });
    }
    
    return momentum;
  }
  
  // Private helper methods
  
  static int _calculateTotalBoundaries(CompleteMatchResultModel matchResult) {
    int boundaries = 0;
    
    if (matchResult.team1Innings?.battingResults != null) {
      boundaries += matchResult.team1Innings!.battingResults!
          .fold<int>(0, (sum, b) => sum + (b.fours ?? 0));
    }
    if (matchResult.team2Innings?.battingResults != null) {
      boundaries += matchResult.team2Innings!.battingResults!
          .fold<int>(0, (sum, b) => sum + (b.fours ?? 0));
    }
    
    return boundaries;
  }
  
  static int _calculateTotalSixes(CompleteMatchResultModel matchResult) {
    int sixes = 0;
    
    if (matchResult.team1Innings?.battingResults != null) {
      sixes += matchResult.team1Innings!.battingResults!
          .fold<int>(0, (sum, b) => sum + (b.sixes ?? 0));
    }
    if (matchResult.team2Innings?.battingResults != null) {
      sixes += matchResult.team2Innings!.battingResults!
          .fold<int>(0, (sum, b) => sum + (b.sixes ?? 0));
    }
    
    return sixes;
  }
  
  static Map<String, dynamic> _calculateWinMargin(CompleteMatchResultModel matchResult) {
    if (matchResult.team1Innings == null || matchResult.team2Innings == null) {
      return {'type': 'unknown', 'margin': 0};
    }
    
    int team1Score = matchResult.team1Innings!.totalRuns ?? 0;
    int team2Score = matchResult.team2Innings!.totalRuns ?? 0;
    
    if (team1Score > team2Score) {
      return {'type': 'runs', 'margin': team1Score - team2Score};
    } else if (team2Score > team1Score) {
      int wicketsRemaining = 10 - (matchResult.team2Innings!.wickets ?? 0);
      return {'type': 'wickets', 'margin': wicketsRemaining};
    } else {
      return {'type': 'tie', 'margin': 0};
    }
  }
  
  static String _determineWinType(CompleteMatchResultModel matchResult) {
    Map<String, dynamic> margin = _calculateWinMargin(matchResult);
    
    switch (margin['type']) {
      case 'runs':
        if (margin['margin'] > 50) return 'dominant_runs';
        if (margin['margin'] > 20) return 'comfortable_runs';
        return 'close_runs';
      case 'wickets':
        if (margin['margin'] >= 7) return 'dominant_wickets';
        if (margin['margin'] >= 4) return 'comfortable_wickets';
        return 'close_wickets';
      case 'tie':
        return 'tie';
      default:
        return 'unknown';
    }
  }
  
  static PlayerBattingResultModel? _getTopBatsman(CompleteMatchResultModel matchResult) {
    List<PlayerBattingResultModel> allBatsmen = [];
    
    if (matchResult.team1Innings?.battingResults != null) {
      allBatsmen.addAll(matchResult.team1Innings!.battingResults!);
    }
    if (matchResult.team2Innings?.battingResults != null) {
      allBatsmen.addAll(matchResult.team2Innings!.battingResults!);
    }
    
    if (allBatsmen.isEmpty) return null;
    
    allBatsmen.sort((a, b) => (b.runs ?? 0).compareTo(a.runs ?? 0));
    return allBatsmen.first;
  }
  
  static PlayerBowlingResultModel? _getTopBowler(CompleteMatchResultModel matchResult) {
    List<PlayerBowlingResultModel> allBowlers = [];
    
    if (matchResult.team1Innings?.bowlingResults != null) {
      allBowlers.addAll(matchResult.team1Innings!.bowlingResults!);
    }
    if (matchResult.team2Innings?.bowlingResults != null) {
      allBowlers.addAll(matchResult.team2Innings!.bowlingResults!);
    }
    
    if (allBowlers.isEmpty) return null;
    
    allBowlers.sort((a, b) {
      int wicketCompare = (b.wickets ?? 0).compareTo(a.wickets ?? 0);
      if (wicketCompare != 0) return wicketCompare;
      return (a.economyRate ?? double.infinity).compareTo(b.economyRate ?? double.infinity);
    });
    
    return allBowlers.first;
  }
  
  static int _countTeamBoundaries(TeamInningsResultModel team) {
    if (team.battingResults == null) return 0;
    return team.battingResults!.fold<int>(0, (sum, b) => sum + (b.fours ?? 0) + (b.sixes ?? 0));
  }
  
  static int _calculateHighestPartnership(TeamInningsResultModel team) {
    // This is a simplified version - in reality, you'd need ball-by-ball data
    // to calculate actual partnerships between consecutive batsmen
    if (team.battingResults == null || team.battingResults!.length < 2) return 0;
    
    // For now, return the sum of the top 2 scores as an approximation
    var sortedBatsmen = List.from(team.battingResults!)..sort((a, b) => (b.runs ?? 0).compareTo(a.runs ?? 0));
    if (sortedBatsmen.length >= 2) {
      return (sortedBatsmen[0].runs ?? 0) + (sortedBatsmen[1].runs ?? 0);
    }
    
    return sortedBatsmen.first.runs ?? 0;
  }
  
}
