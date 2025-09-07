import 'package:cric_live/utils/import_exports.dart';

class ScoreboardRepo with MatchRepo, MatchCalculationRepo, BallByBallRepo {
  ScoreboardRepo();

  /// Description:==========================================================================
  /// functions are used to calculate a complete match state
  /// Get complete match result data
  /// ======================================================================================

  /// this function is main to get match state and result
  Future<CompleteMatchResultModel?> getCompleteMatchResult(int matchId) async {
    try {
      CreateMatchModel match = await findMatch(matchId);
      if (match.id == null) {
        throw Exception("Match not found");
      }

      // Team names
      String team1Name = await getTeamName(match.team1 ?? 0);
      String team2Name = await getTeamName(match.team2 ?? 0);

      // Get innings results
      TeamInningsResultModel? team1Innings = await getTeamInningsResult(
        matchId,
        1,
        match.team1 ?? 0,
      );
      TeamInningsResultModel? team2Innings = await getTeamInningsResult(
        matchId,
        2,
        match.team2 ?? 0,
      );

      // Get overs summary
      List<OverSummaryModel> team1Overs = await getInningsOvers(matchId, 1);
      List<OverSummaryModel> team2Overs = await getInningsOvers(matchId, 2);

      // Variables for result
      String? winnerTeamName;
      String? resultDescription;
      bool isCompleted = match.status?.toLowerCase() == "completed";

      // If match completed, calculate winner
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

      // If match is still live → get current batsmen & bowler
      List<PlayerBattingResultModel>? currentBatsmen = [];
      PlayerBowlingResultModel? currentBowler;

      if (!isCompleted) {
        Database db = await MyDatabase().database;

        // Current inning = max inning in DB
        List<Map<String, dynamic>> inningRes = await db.rawQuery(
          '''SELECT MAX(inningNo) as currentInning FROM $TBL_BALL_BY_BALL WHERE matchId = ?''',
          [matchId],
        );

        int currentInning = (inningRes.first['currentInning'] as int?) ?? 1;

        // Current batsmen (last 2 not out players)
        List<Map<String, dynamic>> batsmenData = await db.rawQuery(
          '''SELECT tp.teamPlayerId as playerId, tp.playerName
           FROM $TBL_TEAM_PLAYERS tp
           WHERE tp.teamId = ?
           AND tp.teamPlayerId NOT IN (
             SELECT strikerBatsmanId FROM $TBL_BALL_BY_BALL 
             WHERE matchId = ? AND inningNo = ? AND isWicket = 1
           )
           LIMIT 2''',
          [
            currentInning == 1 ? match.team1 : match.team2,
            matchId,
            currentInning,
          ],
        );

        for (var b in batsmenData) {
          Map<String, double> stats = await calculateBatsman(
            b['playerId'],
            matchId,
          );
          currentBatsmen.add(
            PlayerBattingResultModel(
              playerId: b['playerId'],
              playerName: b['playerName'],
              runs: stats['runs']?.toInt(),
              balls: stats['balls']?.toInt(),
              fours: stats['fours']?.toInt(),
              sixes: stats['sixes']?.toInt(),
              strikeRate: stats['strikeRate'],
              isOut: false,
              isNotOut: true,
            ),
          );
        }

        // Current bowler = bowler from last ball
        List<Map<String, dynamic>> bowlerData = await db.rawQuery(
          '''SELECT b.bowlerId, tp.playerName
           FROM $TBL_BALL_BY_BALL b
           JOIN $TBL_TEAM_PLAYERS tp ON b.bowlerId = tp.teamPlayerId
           WHERE b.matchId = ? AND b.inningNo = ?
           ORDER BY b.id DESC LIMIT 1''',
          [matchId, currentInning],
        );

        if (bowlerData.isNotEmpty) {
          int bowlerId = bowlerData.first['bowlerId'];
          String bowlerName = bowlerData.first['playerName'];

          Map<String, double> stats = await calculateBowler(
            bowlerId: bowlerId,
            matchId: matchId,
            inningNo: currentInning,
            noBallRun: match.noBallRun ?? 1,
            wideRun: match.wideRun ?? 1,
          );

          currentBowler = PlayerBowlingResultModel(
            playerId: bowlerId,
            playerName: bowlerName,
            overs: stats['overs'],
            wickets: stats['wickets']?.toInt(),
            runs: stats['runs']?.toInt(),
            maidens: stats['maidens']?.toInt(),
            economyRate: stats['ER'],
          );
        }
      }

      // Return final model
      return CompleteMatchResultModel(
        matchId: matchId,
        matchTitle: "$team1Name vs $team2Name",
        date: match.matchDate,
        matchType: 'T20',
        status: match.status,
        winnerTeamName: winnerTeamName,
        resultDescription: resultDescription,
        team1Innings: team1Innings,
        team2Innings: team2Innings,
        team1Overs: team1Overs,
        team2Overs: team2Overs,
      );
    } catch (e) {
      log("Error getting hybrid match result: $e");
      return null;
    }
  }

  /// Get team innings result with player stats
  Future<TeamInningsResultModel?> getTeamInningsResult(
    int matchId,
    int inningNo,
    int teamId,
  ) async {
    try {
      Database db = await MyDatabase().database;

      /// first we calculate ::
      /// total-runs / total-wickets ( currentOvers )
      int totalRuns = await calculateRuns(matchId, inningNo);
      int wickets = await calculateWicket(matchId, inningNo);
      double overs = await calculateCurrentOvers(matchId, inningNo);

      /// if result is getting null then may be match is not started yet
      if (totalRuns == 0 && wickets == 0 && overs == 0.0) {
        return null;
      }

      String teamName = await getTeamName(teamId);

      /// Get batting results
      List<PlayerBattingResultModel> battingResults = await getBattingResults(
        matchId,
        inningNo,
        teamId,
      );

      // Get bowling results (opposition bowlers)
      List<PlayerBowlingResultModel> bowlingResults = await getBowlingResults(
        matchId,
        inningNo,
      );

      // Calculate extras
      Map<String, int> extras = await calculateExtras(matchId, inningNo);

      return TeamInningsResultModel(
        teamId: teamId,
        teamName: teamName,
        inningNo: inningNo,
        totalRuns: totalRuns,
        wickets: wickets,
        overs: overs,
        battingResults: battingResults,
        bowlingResults: bowlingResults,
        wides: extras['wides'],
        noBalls: extras['noBalls'],
        byes: extras['byes'],
        extras: extras['total'],
      );
    } catch (e) {
      log('Error getting team innings result: $e');
      return null;
    }
  }

  /// todo: real need a teamId check this
  /// Get batting results for a team in an innings
  Future<List<PlayerBattingResultModel>> getBattingResults(
    int matchId,
    int inningNo,
    int teamId,
  ) async {
    try {
      Database db = await MyDatabase().database;

      /// ----------------------------------------------------------------------Get all batsmen who batted in this innings
      List<Map<String, dynamic>> batsmenData = await db.rawQuery(
        '''
        SELECT DISTINCT 
          b.strikerBatsmanId as playerId,
          tp.playerName
        FROM $TBL_BALL_BY_BALL b
        JOIN $TBL_TEAM_PLAYERS tp ON b.strikerBatsmanId = tp.teamPlayerId
        WHERE b.matchId = ? AND b.inningNo = ? AND tp.teamId = ?
        ORDER BY b.strikerBatsmanId
        ''',
        [matchId, inningNo, teamId],
      );

      List<PlayerBattingResultModel> battingResults = [];

      ///-----------------------------------------------------------------------calculate each batsman state
      for (var batsman in batsmenData) {
        int playerId = batsman['playerId'];
        String playerName = batsman['playerName'];

        /// Get detailed batting stats of the player
        Map<String, double> stats = await calculateBatsman(playerId, matchId);

        /// Check if player got out
        List<Map<String, dynamic>> wicketData = await db.rawQuery(
          '''
          SELECT * FROM $TBL_BALL_BY_BALL
          WHERE matchId = ? AND inningNo = ? AND strikerBatsmanId = ? AND isWicket = 1
          LIMIT 1
          ''',
          [matchId, inningNo, playerId],
        );

        bool isOut = wicketData.isNotEmpty;

        battingResults.add(
          PlayerBattingResultModel(
            playerId: playerId,
            playerName: playerName,
            runs: stats['runs']?.toInt(),
            balls: stats['balls']?.toInt(),
            fours: stats['fours']?.toInt(),
            sixes: stats['sixes']?.toInt(),
            strikeRate: stats['strikeRate'],
            isOut: isOut,
            isNotOut: !isOut,
          ),
        );
      }

      return battingResults;
    } catch (e) {
      log('Error getting batting results: $e');
      return [];
    }
  }

  /// Get bowling results for an innings
  Future<List<PlayerBowlingResultModel>> getBowlingResults(
    int matchId,
    int inningNo,
  ) async {
    try {
      Database db = await MyDatabase().database;

      /// ------------------------------------------------------------------------------Get all bowlers who bowled in this innings
      List<Map<String, dynamic>> bowlersData = await db.rawQuery(
        '''
        SELECT DISTINCT 
          b.bowlerId as playerId,
          tp.playerName
        FROM $TBL_BALL_BY_BALL b
        JOIN $TBL_TEAM_PLAYERS tp ON b.bowlerId = tp.teamPlayerId
        WHERE b.matchId = ? AND b.inningNo = ?
        ORDER BY b.bowlerId
        ''',
        [matchId, inningNo],
      );

      List<PlayerBowlingResultModel> bowlingResults = [];

      /// Get match config for wide/no-ball runs
      CreateMatchModel match = await findMatch(matchId);
      int wideRun = match.wideRun ?? 1;
      int noBallRun = match.noBallRun ?? 1;

      /// -------------------------------------------------------------------------------calculate each bowler state
      for (var bowler in bowlersData) {
        int playerId = bowler['playerId'];
        String playerName = bowler['playerName'];

        /// Get detailed bowling stats
        Map<String, double> stats = await calculateBowler(
          bowlerId: playerId,
          matchId: matchId,
          inningNo: inningNo,
          noBallRun: noBallRun,
          wideRun: wideRun,
        );

        bowlingResults.add(
          PlayerBowlingResultModel(
            playerId: playerId,
            playerName: playerName,
            overs: stats['overs'],
            wickets: stats['wickets']?.toInt(),
            runs: stats['runs']?.toInt(),
            maidens: stats['maidens']?.toInt(),
            economyRate: stats['ER'],
          ),
        );
      }

      return bowlingResults;
    } catch (e) {
      log('Error getting bowling results: $e');
      return [];
    }
  }

  /// Get over-by-over data for an innings
  Future<List<OverSummaryModel>> getInningsOvers(
    int matchId,
    int inningNo,
  ) async {
    try {
      Database db = await MyDatabase().database;

      // Get all balls grouped by over
      List<Map<String, dynamic>> ballsData = await db.rawQuery(
        '''
        SELECT 
          *,
          ((ROW_NUMBER() OVER (PARTITION BY bowlerId ORDER BY id) - 1) 
           / CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) 
                  THEN 6 ELSE 1000 END) + 1 as over_number
        FROM $TBL_BALL_BY_BALL
        WHERE matchId = ? AND inningNo = ?
        ORDER BY id
        ''',
        [matchId, inningNo],
      );

      Map<int, List<BallDetailModel>> overGroups = {};

      int currentOverNumber = 1;
      int legalBallsInCurrentOver = 0;

      for (var ballData in ballsData) {
        BallDetailModel ball = BallDetailModel.fromJson(ballData);

        // Group balls by over (6 legal balls per over)
        if (!overGroups.containsKey(currentOverNumber)) {
          overGroups[currentOverNumber] = [];
        }

        overGroups[currentOverNumber]!.add(ball);

        // Count legal balls to determine when over is complete
        if (ball.countsTowardOver) {
          legalBallsInCurrentOver++;
          if (legalBallsInCurrentOver >= 6) {
            currentOverNumber++;
            legalBallsInCurrentOver = 0;
          }
        }
      }

      List<OverSummaryModel> overs = [];

      overGroups.forEach((overNumber, balls) async {
        // Get bowler info from first ball
        String bowlerName = "";
        if (balls.isNotEmpty) {
          bowlerName = await getPlayerName(balls.first.bowlerId ?? 0);
        }

        overs.add(
          OverSummaryModel(
            matchId: matchId,
            inningNo: inningNo,
            overNumber: overNumber,
            bowlerName: bowlerName,
            balls: balls,
          ),
        );
      });

      return overs;
    } catch (e) {
      log('Error getting innings overs: $e');
      return [];
    }
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

  /// Get a summary of the current over's state.
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
      await updateMatchState(matchId);

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

  Future<void> updateMatchState(matchId) async {
    final db = await MyDatabase().database;
    CompleteMatchResultModel? matchState = await getCompleteMatchResult(
      matchId,
    );
    await db.rawQuery(
      '''
        update $TBL_MATCHES
        set matchState = ?
        where id = ?
      ''',
      [jsonEncode(matchState?.toJson() ?? {}), matchId],
    );
    SyncFeature syncFeature = SyncFeature();

    syncFeature.checkConnectivity(
      () async => await syncFeature.syncMatchUpdate(matchId: matchId),
    );
  }
}
