// features/scoreboard/repositories/match_stats_repo.dart

import 'package:cric_live/utils/import_exports.dart';

mixin MatchCalculationRepo {
  /// Calculate total runs for a given inning.
  Future<int> calculateRuns(int matchId, int inningNo) async {
    try {
      final Database db = await MyDatabase().database;
      final data = await db.rawQuery(
        '''
        SELECT SUM(runs) AS total_runs
        FROM $TBL_BALL_BY_BALL
        WHERE runs IS NOT NULL AND matchId = ? AND inningNo = ?
        ''',
        [matchId, inningNo],
      );
      return data.isNotEmpty && data.first['total_runs'] != null
          ? data.first['total_runs'] as int
          : 0;
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate total wickets for a given inning.
  Future<int> calculateWicket(int matchId, int inningNo) async {
    try {
      final Database db = await MyDatabase().database;
      final data = await db.rawQuery(
        '''
        SELECT SUM(isWicket) AS total_wickets
        FROM $TBL_BALL_BY_BALL
        WHERE isWicket IS NOT NULL AND matchId = ? AND inningNo = ?
        ''',
        [matchId, inningNo],
      );
      return data.isNotEmpty && data.first['total_wickets'] != null
          ? data.first['total_wickets'] as int
          : 0;
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate batsman stats (runs, balls, 4s, 6s, strike rate) by ID.
  Future<Map<String, double>> calculateBatsman(int batsmanId) async {
    final Database db = await MyDatabase().database;
    final result = await db.rawQuery(
      '''
        SELECT 
          SUM(runs) AS runs,
          SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END) AS balls,
          SUM(CASE WHEN runs = 4 THEN 1 ELSE 0 END) AS fours,
          SUM(CASE WHEN runs = 6 THEN 1 ELSE 0 END) AS sixes,
          CASE 
            WHEN SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END) > 0 
            THEN ROUND(SUM(runs) * 100.0 / SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END), 2)
            ELSE 0
          END AS strikeRate
        FROM $TBL_BALL_BY_BALL
        WHERE strikerBatsmanId = ?
      ''',
      [batsmanId],
    );
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
    final result = await db.rawQuery(
      '''
      SELECT 
          COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) as legal_balls,
          COALESCE(SUM(runs), 0) + 
          COALESCE(SUM(CASE WHEN isWide = 1 THEN ${wideRun.toString()} ELSE 0 END), 0) + 
          COALESCE(SUM(CASE WHEN isNoBall = 1 THEN ${noBallRun.toString()} ELSE 0 END), 0) as runs,
          COALESCE(COUNT(CASE WHEN isWicket = 1 THEN 1 END), 0) as wickets
      FROM $TBL_BALL_BY_BALL 
      WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
      GROUP BY bowlerId;
      ''',
      [matchId, inningNo, bowlerId],
    );

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

    // Calculate maidens
    final maidenQuery = await db.rawQuery(
      '''
       WITH ball_sequence AS (
           SELECT 
               id,
               ROW_NUMBER() OVER (ORDER BY id) as ball_seq,
               ((ROW_NUMBER() OVER (ORDER BY id) - 1) / 6) AS over_no,
               COALESCE(runs, 0) + 
               COALESCE(CASE WHEN isWide = 1 THEN ${wideRun} ELSE 0 END, 0) + 
               COALESCE(CASE WHEN isNoBall = 1 THEN ${noBallRun} ELSE 0 END, 0) AS ball_runs
           FROM $TBL_BALL_BY_BALL
           WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
       ),
       over_runs AS (
           SELECT 
               over_no,
               SUM(ball_runs) AS over_runs
           FROM ball_sequence
           GROUP BY over_no
       )
       SELECT COUNT(*) AS maidens
       FROM over_runs
       WHERE over_runs = 0;
      ''',
      [matchId, inningNo, bowlerId],
    );
    final maidens = (maidenQuery.first['maidens'] as num?)?.toDouble() ?? 0.0;

    return {
      'overs': completedOvers + (ballsInOver / 10.0),
      'maidens': maidens,
      'runs': totalRuns,
      'wickets': (row['wickets'] as num?)?.toDouble() ?? 0.0,
      'ER': legalBalls > 0 ? (totalRuns * 6.0) / legalBalls : 0.0,
    };
  }

  /// Calculate the current overs in the X.Y format.
  Future<double> calculateCurrentOvers(int matchId, int inningNo) async {
    Database db = await MyDatabase().database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as legal_balls
      FROM $TBL_BALL_BY_BALL
      WHERE matchId = ? AND inningNo = ?
        AND (isWide IS NULL OR isWide = 0)
        AND (isNoBall IS NULL OR isNoBall = 0)
      ''',
      [matchId, inningNo],
    );
    final int legalBalls = Sqflite.firstIntValue(result) ?? 0;
    final int completedOvers = legalBalls ~/ 6;
    final int ballsInCurrentOver = (legalBalls % 6);
    return completedOvers.toDouble() + (ballsInCurrentOver / 10.0);
  }

  /// Check if the inning is finished based on overs.
  Future<bool> isInningFinished(
    int matchId,
    int inningNo,
    int totalOvers,
  ) async {
    try {
      double completedOvers = (await calculateCurrentOvers(matchId, inningNo));
      return completedOvers >= totalOvers.toDouble();
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  /// Calculate the current run rate (CRR).
  Future<double> calculateCRR(int matchId, int inningNo) async {
    int totalRuns = await calculateRuns(matchId, inningNo);
    double overs = await calculateCurrentOvers(matchId, inningNo);
    int balls = (overs * 10).toInt() % 10;
    int completeOvers = overs.toInt();
    double totalOversDecimal = completeOvers + (balls / 6.0);
    return totalOversDecimal > 0 ? totalRuns / totalOversDecimal : 0.0;
  }
}
