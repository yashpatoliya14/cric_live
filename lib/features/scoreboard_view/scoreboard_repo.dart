// lib/features/scoreboard/repository/scoreboard_repository.dart

import 'package:cric_live/utils/import_exports.dart';

class ScoreboardRepository {
  final SyncFeature _syncFeature = SyncFeature();
  // region functions name(addBallEntry, undoBall)  Ball-by-Ball Actions whenever call these block of functions then we need to update State
  //=============================================================================================

  /// Add ball data entry to the local database.
  Future<int> addBallEntry(ScoreboardModel data) async {
    try {
      /// add ball entry in local database
      final Database db = await MyDatabase().database;
      final id = await db.insert(TBL_BALL_BY_BALL, data.toMap());

      /// update json object (match state)
      await _updateMatchState(data.matchId ?? 0);
      return id;
    } catch (e, st) {
      log(
        "Error at add ball entry :::: $e "
        "\n stacktrace ::: $st",
      );
      return -1;
    }
  }

  /// Undo the last ball entry from the database.
  Future<ScoreboardModel?> undoBall() async {
    final Database db = await MyDatabase().database;
    final lastBall = await _getLastBallEntry();
    if (lastBall != null) {
      await db.delete(
        TBL_BALL_BY_BALL,
        where: 'id = ?',
        whereArgs: [lastBall.id],
      );
      await _updateMatchState(lastBall.matchId ?? 0);
    }
    return _getLastBallEntry();
  }

  /// Get the most recent ball entry.
  Future<ScoreboardModel?> _getLastBallEntry() async {
    final Database db = await MyDatabase().database;
    final data = await db.query(TBL_BALL_BY_BALL, orderBy: 'id DESC', limit: 1);
    return data.isNotEmpty ? ScoreboardModel().fromMap(data.first) : null;
  }
  //endregion

  // region functions name (findMatch,getTeamName,getPlayerName) Match & Team Data Retrieval
  //================================================================================

  /// Find a match by its ID.
  Future<MatchModel> findMatch(int matchId) async {
    Database db = await MyDatabase().database;
    final result = await db.query(
      TBL_MATCHES,
      where: 'id = ?',
      whereArgs: [matchId],
    );
    if (result.isEmpty) {
      throw Exception("Match not found with id: $matchId");
    }
    return MatchModel.fromMap(result.first);
  }

  /// Get a team's name by its ID.
  Future<String> getTeamName(int teamId) async {
    Database db = await MyDatabase().database;
    final result = await db.query(
      TBL_TEAMS,
      where: 'teamId = ?',
      whereArgs: [teamId],
    );
    return result.isNotEmpty
        ? result.first['teamName'].toString()
        : "Unknown Team";
  }

  /// Get a player's name by their ID.
  Future<String> getPlayerName(int playerId) async {
    Database db = await MyDatabase().database;
    final result = await db.query(
      TBL_TEAM_PLAYERS,
      where: 'teamPlayerId = ?',
      whereArgs: [playerId],
    );
    return result.isNotEmpty
        ? result.first['playerName'].toString()
        : "Unknown Player";
  }

  /// Get the total number of players in a team using precise database count.
  /// This count is used to determine when to show tie/win dialogs (when wickets = playerCount - 1).
  Future<int> getTeamSize(int teamId) async {
    try {
      Database db = await MyDatabase().database;
      
      // Use COUNT query for better performance and accuracy
      log('💾 EXECUTING DATABASE QUERY: SELECT COUNT(*) FROM $TBL_TEAM_PLAYERS WHERE teamId = $teamId');
      final result = await db.rawQuery(
        'SELECT COUNT(*) as player_count FROM $TBL_TEAM_PLAYERS WHERE teamId = ?',
        [teamId],
      );
      
      log('💾 RAW QUERY RESULT: $result');
      final playerCount = Sqflite.firstIntValue(result) ?? 0;
      
      log('🔢 Database query for team $teamId: Found $playerCount players');
      
      if (playerCount == 0) {
        log('⚠️ Warning: No players found for team $teamId, using default of 10');
        return 10; // Default to 10 if no players found
      }
      
      log('✅ Team $teamId has $playerCount players. Match end condition: ${playerCount - 1} wickets');
      return playerCount;
      
    } catch (e) {
      log('❌ Error getting team player count for team $teamId: $e');
      return 10; // Default fallback
    }
  }

  /// DEBUG METHOD: List all players for a team to verify database contents
  Future<void> debugListTeamPlayers(int teamId) async {
    try {
      Database db = await MyDatabase().database;
      
      log('🔍 DEBUG: Listing all players for team $teamId');
      final result = await db.query(
        TBL_TEAM_PLAYERS,
        where: 'teamId = ?',
        whereArgs: [teamId],
      );
      
      log('🔍 DEBUG: Found ${result.length} players in database:');
      for (int i = 0; i < result.length; i++) {
        final player = result[i];
        log('🔍   Player ${i + 1}: ID=${player['teamPlayerId']}, Name=${player['playerName']}');
      }
      
    } catch (e) {
      log('🔍 DEBUG ERROR: $e');
    }
  }

  Future<String?> getTeamNameOnline(int teamId) async {
    ApiServices apiServices = ApiServices();
    try {
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Teams/GetTeamsById/$teamId",
      );

      return data["data"]["teamName"];
    } catch (e) {
      log("from team name from online ");
      log(e.toString());
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error");
      }
      return null;
    }
  }
  //endregion

  //region functions name (updateMatch(for local),shiftInning,endMatch) Match State & Inning Management
  //================================================================================

  /// Update match details in locally (e.g., status, current players).
  Future<void> updateMatch(MatchModel model) async {
    Database db = await MyDatabase().database;
    await db.update(
      TBL_MATCHES,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
    SyncFeature().checkConnectivity(
      () async => await SyncFeature().updateMatch(matchId: model.id ?? 0),
    );
  }

  /// Shift to the second inning with new players.
  Future<void> shiftInning({
    required int matchId,
    required int nextBattingTeamId,
    required int strikerId,
    required int nonStrikerId,
    required int bowlerId,
  }) async {
    Database db = await MyDatabase().database;
    await db.update(
      TBL_MATCHES,
      {
        'inningNo': 2,
        'currentBattingTeamId': nextBattingTeamId,
        'strikerBatsmanId': strikerId,
        'nonStrikerBatsmanId': nonStrikerId,
        'bowlerId': bowlerId,
      },
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  /// Mark the match as 'completed' with proper result calculation.
  Future<void> endMatch(int matchId) async {
    Database db = await MyDatabase().database;

    try {
      // Get current match data
      final match = await findMatch(matchId);

      // Calculate final scores
      final firstInningScore = await calculateRuns(matchId, 1);
      final secondInningScore = await calculateRuns(matchId, 2);
      final secondInningWickets = await calculateWicket(matchId, 2);

      // Get team sizes for accurate wicket calculation
      final secondInningTeamId = match.currentBattingTeamId ?? 0;
      final secondInningTeamSize = await getTeamSize(secondInningTeamId);
      final totalWickets =
          secondInningTeamSize - 1; // All wickets down = teamSize - 1

      // Calculate winner and result
      String result;
      int? winnerTeamId;

      if (secondInningScore > firstInningScore) {
        // Second batting team wins by runs
        winnerTeamId = match.currentBattingTeamId;
        final margin = secondInningScore - firstInningScore;
        final winnerTeamName = await getTeamName(winnerTeamId!);
        result = "$winnerTeamName won by $margin runs";
      } else if (firstInningScore > secondInningScore) {
        // First batting team wins by wickets
        winnerTeamId =
            match.currentBattingTeamId == match.team1
                ? match.team2
                : match.team1;
        final margin =
            totalWickets - secondInningWickets; // Use dynamic total wickets
        final winnerTeamName = await getTeamName(winnerTeamId!);
        result = "$winnerTeamName won by $margin wickets";
        log(
          '🏆 Winner calculation: $winnerTeamName won by $margin wickets (totalWickets: $totalWickets, secondInningWickets: $secondInningWickets)',
        );
      } else {
        // Match tied
        winnerTeamId = null;
        result = "Match tied";
      }

      // Update the local MatchModel with complete result first
      match.status = 'completed';
      match.result = result;
      match.winnerTeamId = winnerTeamId;
      match.firstInningScore = firstInningScore;

      // Update match database using the MatchModel's toMap method
      await db.update(
        TBL_MATCHES,
        match.toMap(),
        where: 'id = ?',
        whereArgs: [matchId],
      );

      // Update match state with final result
      await _updateMatchState(matchId);

      // Sync with backend
      SyncFeature().checkConnectivity(
        () async => await SyncFeature().updateMatch(matchId: matchId),
      );

      log('✅ Match $matchId ended successfully: $result');
    } catch (e, stackTrace) {
      log('❌ Error ending match $matchId: $e');
      log('Stack trace: $stackTrace');

      // Fallback: Just mark as completed without detailed result
      await db.update(
        TBL_MATCHES,
        {
          'status': 'completed',
          'completedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [matchId],
      );

      rethrow;
    }
  }

  /// Private helper to up date the serialized match state after any change.
  Future<void> _updateMatchState(int matchId) async {
    final db = await MyDatabase().database;
    // Create ResultRepo instance locally to avoid circular dependency during initialization
    final resultRepo = ResultRepo();
    CompleteMatchResultModel? matchState = await resultRepo
        .getCompleteMatchResult(matchId);
    await db.update(
      TBL_MATCHES,
      {'matchState': jsonEncode(matchState?.toJson() ?? {})},
      where: 'id = ?',
      whereArgs: [matchId],
    );
    _syncFeature.checkConnectivity(
      () => _syncFeature.updateMatch(matchId: matchId),
    );
  }
  //endregion

  //(calculateRuns, getFirstInningValue, calculateWicket,
  // calculateCurrentOvers, calculateCRR, calculateBatsman,
  // calculateBowler, getDetailedOverState, getLegalBallsInCurrentOver , isOverCompleted) Calculations
  //region ================================================================================

  /// Calculate total runs for a given inning.
  Future<int> calculateRuns(int matchId, int inningNo) async {
    final db = await MyDatabase().database;
    final result = await db.rawQuery(CALCULATE_RUNS, [matchId, inningNo]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Fetch the first inning's score to set a target.
  Future<int> getFirstInningScore(int matchId) async {
    return await calculateRuns(matchId, 1);
  }

  /// Calculate total wickets for a given inning.
  Future<int> calculateWicket(int matchId, int inningNo) async {
    final db = await MyDatabase().database;
    final result = await db.rawQuery(CALCULATE_WICKET, [matchId, inningNo]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Calculate the current overs in the X.Y format.
  Future<double> calculateCurrentOvers(int matchId, int inningNo) async {
    final db = await MyDatabase().database;
    final result = await db.rawQuery(CALCULATE_CURRENT_OVERS, [
      matchId,
      inningNo,
    ]);
    final int legalBalls = Sqflite.firstIntValue(result) ?? 0;
    final int completedOvers = legalBalls ~/ 6;
    final int ballsInCurrentOver = legalBalls % 6;
    return completedOvers + (ballsInCurrentOver / 10.0);
  }

  /// Calculate the current run rate (CRR).
  Future<double> calculateCRR(int matchId, int inningNo) async {
    int totalRuns = await calculateRuns(matchId, inningNo);
    double overs = await calculateCurrentOvers(matchId, inningNo);
    if (overs == 0.0) return 0.0;
    return totalRuns / overs;
  }

  /// Calculate batsman stats (runs, balls, 4s, 6s, strike rate) by ID.
  Future<Map<String, double>> calculateBatsman(
    int batsmanId,
    int matchId,
  ) async {
    final Database db = await MyDatabase().database;
    final result = await db.rawQuery(CALCULATE_BATSMAN, [batsmanId, matchId]);
    final row = result.first;
    return {
      'runs': (row['runs'] as num?)?.toDouble() ?? 0.0,
      'balls': (row['balls'] as num?)?.toDouble() ?? 0.0,
      'fours': (row['fours'] as num?)?.toDouble() ?? 0.0,
      'sixes': (row['sixes'] as num?)?.toDouble() ?? 0.0,
      'strikeRate': (row['strikeRate'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// Calculate bowler stats (overs, maidens, runs, wickets, ER) by ID.
  Future<Map<String, double>> calculateBowler({
    required int bowlerId,
    required int matchId,
    required int inningNo,
    required int noBallRun,
    required int wideRun,
  }) async {
    final Database db = await MyDatabase().database;
    final result = await db.rawQuery(CALCULATE_BOWLER, [
      wideRun,
      noBallRun,
      matchId,
      inningNo,
      bowlerId,
    ]);

    if (result.isEmpty) {
      return {
        'overs': 0.0,
        'maidens': 0.0,
        'runs': 0.0,
        'wickets': 0.0,
        'ER': 0.0,
      };
    }

    final row = result.first;
    final legalBalls = (row['legal_balls'] as num?)?.toInt() ?? 0;
    final completedOvers = legalBalls ~/ 6;
    final ballsInOver = legalBalls % 6;
    final totalRuns = (row['runs'] as num?)?.toDouble() ?? 0.0;

    // Calculate maidens with proper parameters
    final maidenQuery = await db.rawQuery(CALCULATE_MAIDEN, [
      wideRun,
      noBallRun,
      matchId,
      inningNo,
      bowlerId,
    ]);
    final maidens = (maidenQuery.first['maidens'] as num?)?.toDouble() ?? 0.0;

    double overs = completedOvers + (ballsInOver / 10.0);
    return {
      'overs': overs,
      'maidens': maidens,
      'runs': totalRuns,
      'wickets': (row['wickets'] as num?)?.toDouble() ?? 0.0,
      'ER': overs > 0 ? totalRuns / overs : 0.0,
    };
  }

  /// Get legal balls count for current bowler's over
  Future<int> getLegalBallsInCurrentOver({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    final Database db = await MyDatabase().database;
    final result = await db.rawQuery(COUNT_LEGAL_BALLS_IN_OVER, [
      matchId,
      inningNo,
      bowlerId,
    ]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if current over is complete (6 legal balls bowled)
  Future<bool> isCurrentOverComplete({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    final legalBalls = await getLegalBallsInCurrentOver(
      matchId: matchId,
      inningNo: inningNo,
      bowlerId: bowlerId,
    );
    return legalBalls >= 6;
  }

  /// NEW: Get legal balls count for CURRENT SESSION only (since bowler selection)
  Future<int> getCurrentSessionBallCount({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    final Database db = await MyDatabase().database;
    final result = await db.rawQuery(COUNT_CURRENT_SESSION_BALLS, [
      matchId,
      inningNo,
      bowlerId,
      matchId, // For subquery
      inningNo, // For subquery
      bowlerId, // For subquery (different bowler)
    ]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// NEW: Check if current SESSION over is complete (6 legal balls since selection)
  Future<bool> isCurrentSessionOverComplete({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    final sessionBalls = await getCurrentSessionBallCount(
      matchId: matchId,
      inningNo: inningNo,
      bowlerId: bowlerId,
    );
    return sessionBalls >= 6;
  }

  /// NEW: Get current session over state (balls since bowler selection)
  Future<Map<String, dynamic>> getCurrentSessionOverState({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    final Database db = await MyDatabase().database;

    try {
      final ballData = await db.rawQuery(GET_CURRENT_SESSION_BALLS, [
        matchId,
        inningNo,
        bowlerId,
        matchId, // For subquery
        inningNo, // For subquery
        bowlerId, // For subquery (different bowler)
      ]);

      List<String> ballSequence = [];
      int legalBallsCount = 0;
      int runsInOver = 0;
      int wicketsInOver = 0;

      for (var ball in ballData) {
        bool wide = (ball['isWide'] ?? 0) == 1;
        bool nb = (ball['isNoBall'] ?? 0) == 1;
        bool wkt = (ball['isWicket'] ?? 0) == 1;
        int runs = (ball['runs'] as int? ?? 0);

        String ballDisplay;
        if (wide) {
          ballDisplay = runs > 1 ? "WD+${runs - 1}" : "WD";
        } else if (nb) {
          ballDisplay = runs > 1 ? "NB+${runs - 1}" : "NB";
        } else if (wkt) {
          ballDisplay = runs > 0 ? "${runs}W" : "W";
          legalBallsCount++;
        } else {
          ballDisplay = runs == 0 ? "•" : "$runs";
          legalBallsCount++;
        }

        ballSequence.add(ballDisplay);
        runsInOver += runs;
        if (wkt) wicketsInOver++;

        // Stop after 6 legal balls
        if (legalBallsCount >= 6) break;
      }

      return {
        'ballSequence': ballSequence,
        'overDisplay': ballSequence.join(' '),
        'legalBallsCount': legalBallsCount,
        'isOverComplete': legalBallsCount >= 6,
        'runsInOver': runsInOver,
        'wicketsInOver': wicketsInOver,
        'remainingBalls': 6 - legalBallsCount,
      };
    } catch (e) {
      log('Error getting current session over state: $e');
      return {
        'ballSequence': [],
        'overDisplay': '',
        'legalBallsCount': 0,
        'isOverComplete': false,
        'runsInOver': 0,
        'wicketsInOver': 0,
        'remainingBalls': 6,
        'error': e.toString(),
      };
    }
  }

  /// Get detailed over information for UI display
  Future<Map<String, dynamic>> getDetailedOverState({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    final Database db = await MyDatabase().database;

    try {
      final ballData = await db.rawQuery(GET_CURRENT_OVER_BALLS, [
        matchId,
        inningNo,
        bowlerId,
      ]);

      List<String> ballSequence = [];
      int legalBallsCount = 0;
      int runsInOver = 0;
      int wicketsInOver = 0;

      for (var ball in ballData) {
        bool wide = (ball['isWide'] ?? 0) == 1;
        bool nb = (ball['isNoBall'] ?? 0) == 1;
        bool wkt = (ball['isWicket'] ?? 0) == 1;
        int runs = (ball['runs'] as int? ?? 0);

        String ballDisplay;
        if (wide) {
          ballDisplay = runs > 1 ? "WD+${runs - 1}" : "WD";
        } else if (nb) {
          ballDisplay = runs > 1 ? "NB+${runs - 1}" : "NB";
        } else if (wkt) {
          ballDisplay = runs > 0 ? "${runs}W" : "W";
          legalBallsCount++;
        } else {
          ballDisplay = runs == 0 ? "•" : "$runs";
          legalBallsCount++;
        }

        ballSequence.add(ballDisplay);
        runsInOver += runs;
        if (wkt) wicketsInOver++;

        // Stop after 6 legal balls
        if (legalBallsCount >= 6) break;
      }

      return {
        'ballSequence': ballSequence,
        'overDisplay': ballSequence.join(' '),
        'legalBallsCount': legalBallsCount,
        'isOverComplete': legalBallsCount >= 6,
        'runsInOver': runsInOver,
        'wicketsInOver': wicketsInOver,
        'remainingBalls': 6 - legalBallsCount,
      };
    } catch (e) {
      log('Error getting detailed over state: $e');
      return {
        'ballSequence': [],
        'overDisplay': 'Error loading over',
        'legalBallsCount': 0,
        'isOverComplete': false,
        'runsInOver': 0,
        'wicketsInOver': 0,
        'remainingBalls': 6,
        'error': e.toString(),
      };
    }
  }

  //endregion
}
