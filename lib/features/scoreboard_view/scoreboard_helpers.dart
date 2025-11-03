import 'package:cric_live/utils/import_exports.dart';

/// Helper class for scoreboard state management and common operations
class ScoreboardHelpers {
  
  /// Generic error handler wrapper
  static Future<T?> handleError<T>({
    required Future<T> Function() operation,
    required String operationName,
    T? fallbackValue,
    Function(String)? onError,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      log('❌ Error in $operationName: $e');
      log('📍 Stack trace: $stackTrace');
      
      onError?.call(e.toString());
      
      if (fallbackValue != null) {
        return fallbackValue;
      }
      
      showAppSnackBar(
        title: 'Error',
        message: 'Failed to $operationName. Please try again.',
        type: AppSnackBarType.error,
      );
      
      return null;
    }
  }

  /// Batch update multiple reactive values
  static void batchUpdateRxValues(Map<RxInterface, dynamic> updates) {
    updates.forEach((rxVar, value) {
      if (rxVar is RxInt && value is int) {
        rxVar.value = value;
      } else if (rxVar is RxString && value is String) {
        rxVar.value = value;
      } else if (rxVar is RxDouble && value is double) {
        rxVar.value = value;
      } else if (rxVar is RxBool && value is bool) {
        rxVar.value = value;
      }
    });
  }

  /// Calculate and update critical match stats immediately
  static void updateCriticalMatchStats({
    required RxInt totalRuns,
    required RxDouble currentOvers,
    required RxDouble crr,
    required int totalOversLimit,
    required int runsToAdd,
    required bool isLegalDelivery,
  }) {
    // Update total runs
    totalRuns.value += runsToAdd;

    // Update overs count for legal deliveries only
    if (isLegalDelivery) {
      double currentOversValue = currentOvers.value;
      double ballsInOver = (currentOversValue % 1) * 10;

      if (currentOversValue < totalOversLimit) {
        if (ballsInOver >= 5) {
          currentOvers.value = (currentOversValue.floor() + 1).toDouble();
        } else {
          currentOvers.value = currentOversValue + 0.1;
        }
      }
    }

    // Update CRR
    if (currentOvers.value > 0) {
      crr.value = totalRuns.value / currentOvers.value;
    }
  }

  /// Update batsman stats immediately (optimistic update)
  static Map<String, double> updateBatsmanStatsOptimistic(
    Map<String, double> currentStats,
    int runs, {
    bool isBye = false,
  }) {
    if (isBye) return currentStats;

    final updatedStats = Map<String, double>.from(currentStats);
    updatedStats['runs'] = (updatedStats['runs'] ?? 0) + runs;
    updatedStats['balls'] = (updatedStats['balls'] ?? 0) + 1;

    if (runs == 4) {
      updatedStats['fours'] = (updatedStats['fours'] ?? 0) + 1;
    } else if (runs == 6) {
      updatedStats['sixes'] = (updatedStats['sixes'] ?? 0) + 1;
    }

    return updatedStats;
  }

  /// Check if match completion conditions are met
  static bool isInningComplete({
    required double currentOvers,
    required int totalOvers,
    required int wickets,
    required int requiredWickets,
    double tolerance = 0.001,
  }) {
    final oversCompleted = currentOvers >= (totalOvers - tolerance);
    final allOut = wickets >= requiredWickets;
    
    if (oversCompleted) {
      log('✅ Overs completed: $currentOvers >= $totalOvers');
    }
    if (allOut) {
      log('✅ All out: $wickets >= $requiredWickets wickets');
    }
    
    return oversCompleted || allOut;
  }

  /// Determine match result based on scores
  static Map<String, dynamic> calculateMatchResult({
    required int secondInningScore,
    required int firstInningScore,
    required int wickets,
    required int currentBattingTeamId,
    required int team1Id,
    required int team2Id,
    required String team1Name,
    required String team2Name,
  }) {
    String result;
    String winnerTeam;
    int winnerTeamId;

    if (secondInningScore > firstInningScore) {
      // Second batting team wins
      winnerTeamId = currentBattingTeamId;
      winnerTeam = currentBattingTeamId == team1Id ? team1Name : team2Name;
      final margin = secondInningScore - firstInningScore;
      result = "$winnerTeam won by $margin runs";
    } else if (firstInningScore > secondInningScore) {
      // First batting team wins
      winnerTeamId = currentBattingTeamId == team1Id ? team2Id : team1Id;
      winnerTeam = winnerTeamId == team1Id ? team1Name : team2Name;
      final margin = 10 - wickets;
      result = "$winnerTeam won by $margin wickets";
    } else {
      // Tie
      winnerTeamId = 0;
      winnerTeam = "Tie";
      result = "Match tied";
    }

    log('🏆 Match result calculated: $result');

    return {
      'result': result,
      'winnerTeam': winnerTeam,
      'winnerTeamId': winnerTeamId,
    };
  }

  /// Check if score should trigger strike rotation
  static bool shouldRotateStrike(int runs, bool isBye) {
    return [1, 3, 5].contains(runs) && !isBye;
  }

  /// Create ball data model from current state
  static ScoreboardModel createBallData({
    required int matchId,
    required int inningNo,
    required int totalOvers,
    required double currentOvers,
    required int strikerBatsmanId,
    required int nonStrikerBatsmanId,
    required int bowlerId,
    required int totalRuns,
    int? isWide,
    int? isNoBall,
    int? isBye,
    int? isWicket,
    String? wicketType,
  }) {
    return ScoreboardModel(
      totalOvers: totalOvers,
      strikerBatsmanId: strikerBatsmanId,
      nonStrikerBatsmanId: nonStrikerBatsmanId,
      bowlerId: bowlerId,
      matchId: matchId,
      inningNo: inningNo,
      runs: totalRuns,
      isWide: isWide,
      isNoBall: isNoBall,
      isBye: isBye,
      isWicket: isWicket,
      wicketType: wicketType,
      currentOvers: currentOvers,
    );
  }

  /// Retry operation with exponential backoff
  static Future<T?> retryOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
    bool Function(T)? validateResult,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log('🔄 Attempt $attempt/$maxRetries: $operationName');
        final result = await operation();
        
        if (validateResult == null || validateResult(result)) {
          log('✅ Success on attempt $attempt: $operationName');
          return result;
        }
        
        log('⚠️ Invalid result on attempt $attempt: $operationName');
      } catch (e) {
        log('❌ Error on attempt $attempt: $operationName - $e');
      }

      if (attempt < maxRetries) {
        final delay = initialDelay * (1 << (attempt - 1)); // Exponential backoff
        await Future.delayed(delay);
      }
    }

    log('❌ All $maxRetries attempts failed for: $operationName');
    return null;
  }

  /// Empty state for bowler
  static Map<String, double> getEmptyBowlerState() {
    return {
      'overs': 0.0,
      'maidens': 0.0,
      'runs': 0.0,
      'wickets': 0.0,
      'ER': 0.0,
    };
  }

  /// Empty state for over
  static Map<String, dynamic> getEmptyOverState() {
    return {
      'ballSequence': [],
      'overDisplay': '',
      'legalBallsCount': 0,
      'isOverComplete': false,
      'runsInOver': 0,
      'wicketsInOver': 0,
      'remainingBalls': 6,
    };
  }

  /// Log match state for debugging
  static void logMatchState({
    required String context,
    required int inningNo,
    required double currentOvers,
    required int totalOvers,
    required int wickets,
    required int totalRuns,
    int? requiredWickets,
    int? targetScore,
  }) {
    log('📊 [$context] Match State:');
    log('  - Inning: $inningNo');
    log('  - Overs: $currentOvers/$totalOvers');
    log('  - Score: $totalRuns/$wickets');
    if (requiredWickets != null) {
      log('  - Required Wickets: $requiredWickets');
    }
    if (targetScore != null) {
      log('  - Target: $targetScore');
    }
  }
}
