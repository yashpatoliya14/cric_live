import 'package:cric_live/utils/import_exports.dart';

class ResultRepo {
  /// Enhanced match result with live data support
  Future<CompleteMatchResultModel?> getCompleteMatchResult(int matchId) async {
    try {
      MatchModel match = await _findMatch(matchId);
      if (match.id == null) {
        throw Exception("Match not found");
      }

      // Team names
      String team1Name = await _getTeamName(match.team1 ?? 0);
      String team2Name = await _getTeamName(match.team2 ?? 0);

      // Get enhanced innings results with bowling data
      TeamInningsResultModel? team1Innings = await getEnhancedTeamInningsResult(
        matchId,
        1,
        match.team1 ?? 0,
      );
      TeamInningsResultModel? team2Innings = await getEnhancedTeamInningsResult(
        matchId,
        2,
        match.team2 ?? 0,
      );

      // Calculate match statistics
      Map<String, int> matchStats = await calculateMatchStatistics(matchId);

      // Get current over state for live matches
      String? currentOverDisplay;
      int? currentInning = await _getCurrentInning(matchId);

      if (match.status?.toLowerCase() == 'live') {
        currentOverDisplay = await _getCurrentOverSimplified(matchId);
      }

      // Calculate live match data
      Map<String, dynamic> liveData = await calculateLiveMatchData(
        matchId,
        team1Innings,
        team2Innings,
        currentInning,
      );

      // Calculate result if completed
      String? winnerTeamName;
      String? resultDescription;
      bool isCompleted = match.status?.toLowerCase() == "completed";

      if (isCompleted && team1Innings != null && team2Innings != null) {
        int team1Score = team1Innings.totalRuns ?? 0;
        int team2Score = team2Innings.totalRuns ?? 0;

        if (team2Score > team1Score) {
          winnerTeamName = team2Name;
          int wicketsRemaining = 10 - (team2Innings.wickets ?? 0);
          resultDescription = "$team2Name won by $wicketsRemaining wickets";
        } else if (team1Score > team2Score) {
          winnerTeamName = team1Name;
          int runsMargin = team1Score - team2Score;
          resultDescription = "$team1Name won by $runsMargin runs";
        } else {
          resultDescription = "Match tied";
        }
      }

      return CompleteMatchResultModel(
        matchId: matchId,
        matchTitle: "$team1Name vs $team2Name",
        // location: match.venue,
        date: match.matchDate,
        // matchType: match.matchType ?? 'T20',
        status: match.status,
        // winnerTeamId: match.winnerTeamId,
        winnerTeamName: winnerTeamName,
        resultDescription: resultDescription,
        tossWinnerTeamId: match.tossWon,
        tossWinnerTeamName:
            match.tossWon != null ? await _getTeamName(match.tossWon!) : null,
        tossDecision: match.decision,
        // playerOfTheMatch: match.playerOfTheMatch,
        team1Innings: team1Innings,
        team2Innings: team2Innings,
        totalRuns: matchStats['totalRuns'],
        totalWickets: matchStats['totalWickets'],
        totalBoundaries: matchStats['totalBoundaries'],
        totalSixes: matchStats['totalSixes'],
        highestIndividualScore: matchStats['highestIndividualScore'],
        highestTeamScore: matchStats['highestTeamScore'],
        currentOverDisplay: currentOverDisplay,
        currentInning: currentInning,
        team1RunRate: liveData['team1RunRate'],
        team2RunRate: liveData['team2RunRate'],
        team2RequiredRunRate: liveData['team2RequiredRunRate'],
        ballsRemaining: liveData['ballsRemaining'],
        runsToWin: liveData['runsToWin'],
        team1Name: team1Name,
        team2Name: team2Name,
      );
    } catch (e) {
      log("Error getting match result: $e");
      return null;
    }
  }



  /// Calculate team boundaries and sixes
  Future<Map<String, int>> calculateTeamBoundaries(
    int matchId,
    int inningNo,
  ) async {
    try {
      Database db = await MyDatabase().database;

      List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT 
          SUM(CASE WHEN runs = 4 THEN 1 ELSE 0 END) as boundaries,
          SUM(CASE WHEN runs = 6 THEN 1 ELSE 0 END) as sixes
        FROM $TBL_BALL_BY_BALL
        WHERE matchId = ? AND inningNo = ?
        ''',
        [matchId, inningNo],
      );

      if (result.isNotEmpty) {
        return {
          'boundaries': (result.first['boundaries'] as num?)?.toInt() ?? 0,
          'sixes': (result.first['sixes'] as num?)?.toInt() ?? 0,
        };
      }

      return {'boundaries': 0, 'sixes': 0};
    } catch (e) {
      log('Error calculating team boundaries: $e');
      return {'boundaries': 0, 'sixes': 0};
    }
  }

  /// Public method to get simplified current over display
  Future<String?> getCurrentOverSimplified(int matchId) async {
    return await _getCurrentOverSimplified(matchId);
  }


  /// Calculate extras for an innings
  Future<Map<String, int>> calculateExtras(int matchId, int inningNo) async {
    try {
      Database db = await MyDatabase().database;

      List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT 
          SUM(CASE WHEN isWide = 1 THEN 1 ELSE 0 END) as wides,
          SUM(CASE WHEN isNoBall = 1 THEN 1 ELSE 0 END) as noBalls,
          SUM(CASE WHEN isBye = 1 THEN runs ELSE 0 END) as byes
        FROM $TBL_BALL_BY_BALL
        WHERE matchId = ? AND inningNo = ?
        ''',
        [matchId, inningNo],
      );

      if (result.isNotEmpty) {
        int wides = (result.first['wides'] as num?)?.toInt() ?? 0;
        int noBalls = (result.first['noBalls'] as num?)?.toInt() ?? 0;
        int byes = (result.first['byes'] as num?)?.toInt() ?? 0;

        return {
          'wides': wides,
          'noBalls': noBalls,
          'byes': byes,
          'total': wides + noBalls + byes,
        };
      }

      return {'wides': 0, 'noBalls': 0, 'byes': 0, 'total': 0};
    } catch (e) {
      log('Error calculating extras: $e');
      return {'wides': 0, 'noBalls': 0, 'byes': 0, 'total': 0};
    }
  }

  /// Get simplified current over display for match summary
  Future<String?> _getCurrentOverSimplified(int matchId) async {
    try {
      Database db = await MyDatabase().database;

      // Get the most recent over's balls for current match state
      List<Map<String, dynamic>> recentBalls = await db.rawQuery(
        '''
        SELECT runs, isWicket, isWide, isNoBall 
        FROM $TBL_BALL_BY_BALL 
        WHERE matchId = ?
        ORDER BY id DESC 
        LIMIT 6
        ''',
        [matchId],
      );

      if (recentBalls.isEmpty) return 'No balls bowled';

      List<String> ballsDisplay = [];
      for (var ball in recentBalls.reversed) {
        bool wide = (ball['isWide'] ?? 0) == 1;
        bool nb = (ball['isNoBall'] ?? 0) == 1;
        bool wkt = (ball['isWicket'] ?? 0) == 1;
        int runs = (ball['runs'] as num?)?.toInt() ?? 0;

        if (wide) {
          ballsDisplay.add('WD');
        } else if (nb) {
          ballsDisplay.add('NB');
        } else if (wkt) {
          ballsDisplay.add('W');
        } else {
          ballsDisplay.add(runs == 0 ? '•' : runs.toString());
        }
      }

      return ballsDisplay.isNotEmpty ? ballsDisplay.join(' ') : 'No over data';
    } catch (e) {
      log('Error getting simplified current over: $e');
      return 'Error loading over';
    }
  }

  /// Get detailed current over state for live scoring
  Future<Map<String, dynamic>> getCurrentOverState({
    required int matchId,
    required int inningNo,
    required int bowlerId,
  }) async {
    try {
      final db = await MyDatabase().database;
      final ballData = await db.rawQuery(
        '''
        SELECT * FROM $TBL_BALL_BY_BALL
        WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
        ORDER BY id
      ''',
        [matchId, inningNo, bowlerId],
      );

      if (ballData.isNotEmpty) {
        log('  First ball data: ${ballData.first}');
        log('  Last ball data: ${ballData.last}');
      }

      List<String> seq = [];
      int legalBallsCount = 0;
      int runsInOver = 0;
      int wicketsInOver = 0;

      for (var ball in ballData) {
        bool wide = (ball['isWide'] ?? 0) == 1;
        bool nb = (ball['isNoBall'] ?? 0) == 1;
        bool wkt = (ball['isWicket'] ?? 0) == 1;
        int r = (ball['runs'] as int? ?? 0);

        if (wide) {
          seq.add(r > 1 ? "WD+${r - 1}" : "WD");
        } else if (nb) {
          seq.add(r > 1 ? "NB+${r - 1}" : "NB");
        } else if (wkt) {
          seq.add(r > 0 ? "${r}W" : "W");
          legalBallsCount++;
        } else {
          seq.add(r == 0 ? "•" : "$r");
          legalBallsCount++;
        }

        runsInOver += r;
        if (wkt) wicketsInOver++;

        // Stop adding balls after 6 legal balls.
        if (legalBallsCount == 6) break;
      }

      final result = {
        'ballSequence': seq,
        'overDisplay': seq.join(' '),
        'ballCount': legalBallsCount,
        'isOverComplete': legalBallsCount >= 6,
        'runsInOver': runsInOver,
        'wicketsInOver': wicketsInOver,
      };

      // Update match state

      return result;
    } catch (e) {
      log('Error in getCurrentOverState: $e');
      log(' StackTrace: ${StackTrace.current}');
      // Return default state on error
      return {
        'ballSequence': [],
        'overDisplay': 'Error loading over',
        'ballCount': 0,
        'isOverComplete': false,
        'runsInOver': 0,
        'wicketsInOver': 0,
        'error': e.toString(),
      };
    }
  }

  /// Get enhanced team innings result with bowling data
  Future<TeamInningsResultModel?> getEnhancedTeamInningsResult(
    int matchId,
    int inningNo,
    int teamId,
  ) async {
    try {
      // Basic innings stats
      int totalRuns = await _calculateRuns(matchId, inningNo);
      int wickets = await _calculateWicket(matchId, inningNo);
      double overs = await _calculateCurrentOvers(matchId, inningNo);

      if (totalRuns == 0 && wickets == 0 && overs == 0.0) {
        return null;
      }

      String teamName = await _getTeamName(teamId);

      // Get enhanced batting stats (all players who batted)
      List<PlayerBattingResultModel> battingStats =
          await getEnhancedBattingStats(matchId, inningNo, teamId);

      // Get bowling stats from opposition
      List<PlayerBowlingResultModel> bowlingStats =
          await getEnhancedBowlingStats(matchId, inningNo, teamId);

      // Calculate extras
      Map<String, int> extras = await calculateExtras(matchId, inningNo);

      // Calculate team boundaries and sixes
      Map<String, int> teamBoundaries = await calculateTeamBoundaries(
        matchId,
        inningNo,
      );

      // Calculate run rate
      double runRate = overs > 0 ? totalRuns / overs : 0.0;

      // Calculate target if this is second innings
      int? target;
      double? requiredRunRate;
      if (inningNo == 2) {
        int firstInningsRuns = await _calculateRuns(matchId, 1);
        target = firstInningsRuns + 1;
        int runsNeeded = target - totalRuns;
        double oversRemaining = 20.0 - overs; // Assuming T20 format
        requiredRunRate =
            oversRemaining > 0 ? runsNeeded / oversRemaining : 0.0;
      }

      return TeamInningsResultModel(
        teamId: teamId,
        teamName: teamName,
        inningNo: inningNo,
        totalRuns: totalRuns,
        wickets: wickets,
        overs: overs,
        runRate: runRate,
        requiredRunRate: requiredRunRate,
        target: target,
        isAllOut: wickets >= 10,
        battingResults: battingStats,
        bowlingResults: bowlingStats,
        extras: extras['total'],
        wides: extras['wides'],
        noBalls: extras['noBalls'],
        byes: extras['byes'],
        totalBoundaries: teamBoundaries['boundaries'],
        totalSixes: teamBoundaries['sixes'],
      );
    } catch (e) {
      log('Error getting enhanced team innings result: $e');
      return null;
    }
  }

  /// Get enhanced batting stats (all players who participated)
  Future<List<PlayerBattingResultModel>> getEnhancedBattingStats(
    int matchId,
    int inningNo,
    int teamId,
  ) async {
    try {
      Database db = await MyDatabase().database;

      List<Map<String, dynamic>> batsmenData = await db.rawQuery(
        '''
        SELECT DISTINCT 
          b.strikerBatsmanId as playerId,
          tp.playerName,
          SUM(b.runs) as totalRuns,
          COUNT(*) as balls,
          SUM(CASE WHEN b.runs = 4 THEN 1 ELSE 0 END) as fours,
          SUM(CASE WHEN b.runs = 6 THEN 1 ELSE 0 END) as sixes,
          MAX(CASE WHEN b.isWicket = 1 THEN 1 ELSE 0 END) as isOut
        FROM $TBL_BALL_BY_BALL b
        JOIN $TBL_TEAM_PLAYERS tp ON b.strikerBatsmanId = tp.teamPlayerId
        WHERE b.matchId = ? AND b.inningNo = ? AND tp.teamId = ?
        GROUP BY b.strikerBatsmanId, tp.playerName
        ORDER BY totalRuns DESC
        ''',
        [matchId, inningNo, teamId],
      );

      List<PlayerBattingResultModel> battingResults = [];

      for (var batsman in batsmenData) {
        int runs = (batsman['totalRuns'] as num?)?.toInt() ?? 0;
        int balls = (batsman['balls'] as num?)?.toInt() ?? 0;
        double strikeRate = balls > 0 ? (runs * 100.0 / balls) : 0.0;
        bool isOut = (batsman['isOut'] as num?)?.toInt() == 1;

        battingResults.add(
          PlayerBattingResultModel(
            playerId: batsman['playerId'],
            playerName: batsman['playerName'],
            runs: runs,
            balls: balls,
            fours: (batsman['fours'] as num?)?.toInt() ?? 0,
            sixes: (batsman['sixes'] as num?)?.toInt() ?? 0,
            strikeRate: strikeRate,
            isOut: isOut,
            isNotOut: !isOut,
          ),
        );
      }

      return battingResults;
    } catch (e) {
      log('Error getting enhanced batting stats: $e');
      return [];
    }
  }

  /// Calculate maiden overs for a bowler
  Future<int> _calculateMaidenOvers(int matchId, int inningNo, int bowlerId) async {
    try {
      Database db = await MyDatabase().database;
      
      // Use the same logic as in CALCULATE_MAIDEN query from scoreboard_queries.dart
      List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        WITH legal_balls AS (
          SELECT 
            id,
            ROW_NUMBER() OVER (ORDER BY id) as ball_seq,
            COALESCE(runs, 0) AS ball_runs
          FROM $TBL_BALL_BY_BALL
          WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
          AND (isWide = 0 OR isWide IS NULL) 
          AND (isNoBall = 0 OR isNoBall IS NULL)
        ),
        over_groups AS (
          SELECT 
            ((ball_seq - 1) / 6) AS over_no,
            SUM(ball_runs) AS over_runs,
            COUNT(*) as balls_in_over
          FROM legal_balls
          GROUP BY ((ball_seq - 1) / 6)
          HAVING balls_in_over = 6
        )
        SELECT COUNT(*) AS maidens
        FROM over_groups
        WHERE over_runs = 0
        ''',
        [matchId, inningNo, bowlerId],
      );
      
      return (result.first['maidens'] as num?)?.toInt() ?? 0;
    } catch (e) {
      log('Error calculating maiden overs: $e');
      return 0;
    }
  }

  /// Get enhanced bowling stats (opposition bowlers)
  Future<List<PlayerBowlingResultModel>> getEnhancedBowlingStats(
    int matchId,
    int inningNo,
    int teamId,
  ) async {
    try {
      Database db = await MyDatabase().database;
      
      // Get match configuration for wide and no-ball run values
      MatchModel match = await _findMatch(matchId);
      int wideRun = match.wideRun ?? 0;
      int noBallRun = match.noBallRun ?? 0;

      // Get bowlers from the opposite team
      List<Map<String, dynamic>> bowlersData = await db.rawQuery(
        '''
        SELECT DISTINCT 
          b.bowlerId as playerId,
          tp.playerName,
          COUNT(CASE WHEN (b.isWide = 0 OR b.isWide IS NULL) AND (b.isNoBall = 0 OR b.isNoBall IS NULL) THEN 1 END) as legalBalls,
          COALESCE(SUM(b.runs), 0) as baseRuns,
          SUM(CASE WHEN b.isWicket = 1 THEN 1 ELSE 0 END) as wickets,
          SUM(CASE WHEN b.isWide = 1 THEN 1 ELSE 0 END) as wides,
          SUM(CASE WHEN b.isNoBall = 1 THEN 1 ELSE 0 END) as noBalls
        FROM $TBL_BALL_BY_BALL b
        JOIN $TBL_TEAM_PLAYERS tp ON b.bowlerId = tp.teamPlayerId
        WHERE b.matchId = ? AND b.inningNo = ? AND tp.teamId != ?
        GROUP BY b.bowlerId, tp.playerName
        ORDER BY wickets DESC, baseRuns ASC
        ''',
        [matchId, inningNo, teamId],
      );

      List<PlayerBowlingResultModel> bowlingResults = [];

      for (var bowler in bowlersData) {
        int legalBalls = (bowler['legalBalls'] as num?)?.toInt() ?? 0;
        int baseRuns = (bowler['baseRuns'] as num?)?.toInt() ?? 0;
        int wickets = (bowler['wickets'] as num?)?.toInt() ?? 0;
        int wides = (bowler['wides'] as num?)?.toInt() ?? 0;
        int noBalls = (bowler['noBalls'] as num?)?.toInt() ?? 0;
        
        // Calculate total runs including extras (similar to scoreboard logic)
        // Use match-specific wide and no-ball run values
        int runs = baseRuns + (wides * wideRun) + (noBalls * noBallRun);
        
        log('🎯 RESULT BOWLING CALC: ${bowler['playerName']}');
        log('  Legal balls: $legalBalls, Base runs: $baseRuns, Wides: $wides (x$wideRun), No-balls: $noBalls (x$noBallRun)');
        log('  Total runs: $runs, Wickets: $wickets');

        // Calculate overs properly: X.Y format where X = completed overs, Y = remaining balls
        int completedOvers = legalBalls ~/ 6;
        int ballsInCurrentOver = legalBalls % 6;
        double overs = completedOvers + (ballsInCurrentOver / 10.0);
        
        log('  Overs calculation: $legalBalls balls = $completedOvers.$ballsInCurrentOver = $overs overs');

        // Calculate economy rate properly: runs per over
        double economyRate = overs > 0 ? (runs / overs) : 0.0;
        
        log('  Economy rate: ${economyRate.toStringAsFixed(2)}');

        // Calculate maiden overs
        int maidens = await _calculateMaidenOvers(
          matchId, 
          inningNo, 
          bowler['playerId'],
        );

        bowlingResults.add(
          PlayerBowlingResultModel(
            playerId: bowler['playerId'],
            playerName: bowler['playerName'],
            overs: overs,
            runs: runs,
            wickets: wickets,
            economyRate: economyRate,
            maidens: maidens,
            wides: (bowler['wides'] as num?)?.toInt() ?? 0,
            noBalls: (bowler['noBalls'] as num?)?.toInt() ?? 0,
          ),
        );
      }

      return bowlingResults;
    } catch (e) {
      log('Error getting enhanced bowling stats: $e');
      return [];
    }
  }

  /// Calculate overall match statistics
  Future<Map<String, int>> calculateMatchStatistics(int matchId) async {
    try {
      Database db = await MyDatabase().database;

      // Get total match stats
      List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT 
          SUM(runs) as totalRuns,
          SUM(CASE WHEN isWicket = 1 THEN 1 ELSE 0 END) as totalWickets,
          SUM(CASE WHEN runs = 4 THEN 1 ELSE 0 END) as totalBoundaries,
          SUM(CASE WHEN runs = 6 THEN 1 ELSE 0 END) as totalSixes
        FROM $TBL_BALL_BY_BALL
        WHERE matchId = ?
        ''',
        [matchId],
      );

      // Get highest individual score
      List<Map<String, dynamic>> topScorer = await db.rawQuery(
        '''
        SELECT MAX(totalRuns) as highestScore
        FROM (
          SELECT SUM(runs) as totalRuns
          FROM $TBL_BALL_BY_BALL
          WHERE matchId = ?
          GROUP BY strikerBatsmanId, inningNo
        )
        ''',
        [matchId],
      );

      // Get highest team score
      List<Map<String, dynamic>> topTeamScore = await db.rawQuery(
        '''
        SELECT MAX(teamRuns) as highestTeamScore
        FROM (
          SELECT SUM(runs) as teamRuns
          FROM $TBL_BALL_BY_BALL
          WHERE matchId = ?
          GROUP BY inningNo
        )
        ''',
        [matchId],
      );

      if (result.isNotEmpty) {
        return {
          'totalRuns': (result.first['totalRuns'] as num?)?.toInt() ?? 0,
          'totalWickets': (result.first['totalWickets'] as num?)?.toInt() ?? 0,
          'totalBoundaries':
              (result.first['totalBoundaries'] as num?)?.toInt() ?? 0,
          'totalSixes': (result.first['totalSixes'] as num?)?.toInt() ?? 0,
          'highestIndividualScore':
              (topScorer.isNotEmpty
                      ? topScorer.first['highestScore'] as num?
                      : 0)
                  ?.toInt() ??
              0,
          'highestTeamScore':
              (topTeamScore.isNotEmpty
                      ? topTeamScore.first['highestTeamScore'] as num?
                      : 0)
                  ?.toInt() ??
              0,
        };
      }

      return {
        'totalRuns': 0,
        'totalWickets': 0,
        'totalBoundaries': 0,
        'totalSixes': 0,
        'highestIndividualScore': 0,
        'highestTeamScore': 0,
      };
    } catch (e) {
      log('Error calculating match statistics: $e');
      return {
        'totalRuns': 0,
        'totalWickets': 0,
        'totalBoundaries': 0,
        'totalSixes': 0,
        'highestIndividualScore': 0,
        'highestTeamScore': 0,
      };
    }
  }

  /// Calculate live match data (run rates, balls remaining, etc.)
  Future<Map<String, dynamic>> calculateLiveMatchData(
    int matchId,
    TeamInningsResultModel? team1Innings,
    TeamInningsResultModel? team2Innings,
    int? currentInning,
  ) async {
    try {
      double? team1RunRate = team1Innings?.calculatedRunRate;
      double? team2RunRate = team2Innings?.calculatedRunRate;
      double? team2RequiredRunRate = team2Innings?.requiredRunRate;
      int? ballsRemaining = team2Innings?.ballsRemaining;
      int? runsToWin = team2Innings?.runsNeeded;

      return {
        'team1RunRate': team1RunRate,
        'team2RunRate': team2RunRate,
        'team2RequiredRunRate': team2RequiredRunRate,
        'ballsRemaining': ballsRemaining,
        'runsToWin': runsToWin,
      };
    } catch (e) {
      log('Error calculating live match data: $e');
      return {
        'team1RunRate': null,
        'team2RunRate': null,
        'team2RequiredRunRate': null,
        'ballsRemaining': null,
        'runsToWin': null,
      };
    }
  }

  /// Get current inning number
  Future<int?> _getCurrentInning(int matchId) async {
    try {
      Database db = await MyDatabase().database;

      List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT MAX(inningNo) as currentInning
        FROM $TBL_BALL_BY_BALL
        WHERE matchId = ?
        ''',
        [matchId],
      );

      if (result.isNotEmpty && result.first['currentInning'] != null) {
        return (result.first['currentInning'] as num).toInt();
      }

      return null;
    } catch (e) {
      log('Error getting current inning: $e');
      return null;
    }
  }

  //endregion

  //region Helper methods to avoid circular dependency
  //================================================================================

  /// Find a match by its ID.
  Future<MatchModel> _findMatch(int matchId) async {
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
  Future<String> _getTeamName(int teamId) async {
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
  Future<String> _getPlayerName(int playerId) async {
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

  /// Calculate total runs for a given inning.
  Future<int> _calculateRuns(int matchId, int inningNo) async {
    final db = await MyDatabase().database;
    final result = await db.rawQuery(
      'SELECT SUM(runs) as total FROM $TBL_BALL_BY_BALL WHERE matchId = ? AND inningNo = ?',
      [matchId, inningNo],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Calculate total wickets for a given inning.
  Future<int> _calculateWicket(int matchId, int inningNo) async {
    final db = await MyDatabase().database;
    final result = await db.rawQuery(
      'SELECT SUM(isWicket) as total FROM $TBL_BALL_BY_BALL WHERE matchId = ? AND inningNo = ? AND isWicket = 1',
      [matchId, inningNo],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Calculate the current overs in the X.Y format.
  Future<double> _calculateCurrentOvers(int matchId, int inningNo) async {
    final db = await MyDatabase().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $TBL_BALL_BY_BALL WHERE matchId = ? AND inningNo = ? AND (isWide = 0 OR isWide IS NULL) AND (isNoBall = 0 OR isNoBall IS NULL)',
      [matchId, inningNo],
    );
    final int legalBalls = Sqflite.firstIntValue(result) ?? 0;
    final int completedOvers = legalBalls ~/ 6;
    final int ballsInCurrentOver = legalBalls % 6;
    return completedOvers + (ballsInCurrentOver / 10.0);
  }



  //endregion
}
