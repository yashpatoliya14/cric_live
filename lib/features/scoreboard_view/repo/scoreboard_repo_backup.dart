// import 'package:cric_live/utils/import_exports.dart';

// class ScoreboardRepo {
//   /// find match
//   Future<CreateMatchModel> findMatch(int matchId) async {
//     Database db = await MyDatabase().database;

//     final matchResult = await db.rawQuery(
//       'SELECT * FROM $TBL_MATCHES WHERE id = ?',
//       [matchId],
//     );

//     if (matchResult.isEmpty) {
//       log("No match found with id: $matchId");
//       Get.snackbar("Match Not Found", "Try Again !");
//       return CreateMatchModel();
//     }

//     final matchData = matchResult.first;
//     return CreateMatchModel.fromMap(matchData);
//   }

//   /// find team name
//   Future<String> getTeamName(int teamId) async {
//     try {
//       Database db = await MyDatabase().database;
//       final result = await db.rawQuery(
//         'SELECT * FROM $TBL_TEAMS WHERE teamId = ?',
//         [teamId],
//       );

//       if (result.isNotEmpty) {
//         return result.first['teamName'].toString();
//       } else {
//         return "";
//       }
//     } catch (e) {
//       log(e.toString());
//       return "";
//     }
//   }

//   /// ------------------description : it takes teamPlayerId and gives a playerName------------------
//   Future<String> getPlayerName(int id) async {
//     try {
//       Database db = await MyDatabase().database;
//       List<Map<String, dynamic>> data = await db.rawQuery(
//         '''
//       SELECT * FROM ${TBL_TEAM_PLAYERS}
//       WHERE teamPlayerId = ?      
//       ''',
//         [id],
//       );

//       return data.first['playerName'];
//     } catch (e) {
//       log(e.toString());
//       return "";
//     }
//   }

//   ///-------------------description : add ball data entry from local database ------------------------
//   Future<int> addBallEntry(ScoreboardModel data) async {
//     try {
//       final Database db = await MyDatabase().database;

//       return await db.insert(TBL_BALL_BY_BALL, data.toMap());
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// is inning finished ???

//   Future<bool> isInningFinished(
//     int matchId,
//     int inningNo,
//     int totalOvers,
//   ) async {
//     try {
//       // Check if current overs completed equals total overs
//       double completedOvers = (await calculateCurrentOvers(matchId, inningNo));
//       return completedOvers >= (totalOvers.toDouble() - 0.1);
//     } catch (e) {
//       log(e.toString());
//       return false;
//     }
//   }

//   ///-------------------description : calculate runs ----------------------------------
//   Future<int> calculateRuns(int matchId, int inningNo) async {
//     try {
//       final Database db = await MyDatabase().database;
//       List<Map<String, dynamic>> data = await db.rawQuery(
//         '''
//         SELECT SUM(runs) AS total_runs
//         FROM $TBL_BALL_BY_BALL
//         WHERE runs IS NOT NULL 
//           AND matchId = ?
//           AND inningNo = ?
//       ''',
//         [matchId, inningNo],
//       );

//       if (data.isNotEmpty && data.first['total_runs'] != null) {
//         return data.first['total_runs'];
//       } else {
//         return 0;
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   ///-------------------description : calculate wicket-----------------------------------
//   Future<int> calculateWicket(int matchId, int inningNo) async {
//     try {
//       final Database db = await MyDatabase().database;
//       List<Map<String, dynamic>> data = await db.rawQuery(
//         '''
//         SELECT SUM(isWicket) AS total_wickets
//         FROM $TBL_BALL_BY_BALL
//         WHERE isWicket IS NOT NULL
//           AND matchId = ?
//           AND inningNo = ?
//       ''',
//         [matchId, inningNo],
//       );
//       if (data.isNotEmpty && data.first['total_wickets'] != null) {
//         return data.first['total_wickets'];
//       } else {
//         return 0;
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   ///-------------------description : undo ball entries-----------------------------------
//   Future<ScoreboardModel?> undoBall() async {
//     final Database db = await MyDatabase().database;
//     db.rawQuery(''' 
//     DELETE FROM ${TBL_BALL_BY_BALL}
//     WHERE id = (
//         SELECT id
//         FROM ${TBL_BALL_BY_BALL}
//         ORDER BY id DESC
//         LIMIT 1
//     );
//     ''');
//     return lastEntry();
//   }

//   ///-------------------description : it gives a last entry of ball --------------------------------
//   Future<ScoreboardModel?> lastEntry() async {
//     final Database db = await MyDatabase().database;

//     final data = await db.rawQuery(''' 
//         Select * FROM ${TBL_BALL_BY_BALL}
//           WHERE id = (
//               SELECT id
//               FROM ${TBL_BALL_BY_BALL}
//               ORDER BY id DESC
//               LIMIT 1
//         );
//     ''');
//     if (data.isEmpty) return null;
//     return ScoreboardModel().fromMap(data[0]);
//   }

//   ///-------------------description : calculate a batsman run and balls 4s and 6s by Id ----------------------
//   /// --------formula to calculate a strike rate : (total_runs * 100) / num_runs

//   Future<Map<String, double>> calculateBatsman(int batsmanId) async {
//     final Database db = await MyDatabase().database;

//     final result = await db.rawQuery(
//       '''
//         SELECT 
//           SUM(runs) AS runs,
//           SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END) AS balls,
//           SUM(CASE WHEN runs = 4 THEN 1 ELSE 0 END) AS fours,
//           SUM(CASE WHEN runs = 6 THEN 1 ELSE 0 END) AS sixes,
//           CASE 
//             WHEN SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END) > 0 
//             THEN ROUND(SUM(runs) * 100.0 / SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END), 2)
//             ELSE 0
//           END AS strikeRate
//         FROM $TBL_BALL_BY_BALL
//         WHERE strikerBatsmanId = ?
//       ''',
//       [batsmanId],
//     );
//     return {
//       'runs': (result[0]['runs'] as num?)?.toDouble() ?? 0.0,
//       'balls': (result[0]['balls'] as num?)?.toDouble() ?? 0.0,
//       'fours': (result[0]['fours'] as num?)?.toDouble() ?? 0.0,
//       'sixes': (result[0]['sixes'] as num?)?.toDouble() ?? 0.0,
//       'strikeRate': (result[0]['strikeRate'] as num?)?.toDouble() ?? 0.0,
//     };
//   }

//   ///-------------------description : calculate a bowler run and balls 4s and 6s by Id ----------------------
//   Future<Map<String, double>> calculateBowler({
//     required int bowlerId,
//     required int matchId,
//     required int inningNo,
//     required int noBallRun,
//     required int wideRun,
//   }) async {
//     final Database db = await MyDatabase().database;

//     /*
//     * calculate [CURRENT OVERS] e.g, total balls = 20
//     *
//     * 1. total balls = COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) = 0
//     * 2. complete overs =  total balls / 6 ( 20 / 6 == 3 as integer)
//     * 3. balls of current over  = total balls % 6 (20 % 6 == 2 as integer)
//     * 4. final over = complete overs + ( balls of current over  * 0.1) => 3.2 overs
//     */

//     /*
//     * calculate [ECONOMY RATE]
//     *
//     * ER = ((sum of all runs with wide and no-ball ) * 6) / total balls
//     *
//     */

//     final result = await db.rawQuery(
//       '''
//       SELECT 
//           CASE 
//               WHEN COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) = 0 
//               THEN 0.0
//               ELSE 
//                   (COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) / 6) + 
//                   (COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) % 6) * 0.1
//           END as overs,
          
//           COALESCE(SUM(runs), 0) + 
//           COALESCE(SUM(CASE WHEN isWide = 1 THEN ${wideRun.toString()} ELSE 0 END), 0) + 
//           COALESCE(SUM(CASE WHEN isNoBall = 1 THEN ${noBallRun.toString()} ELSE 0 END), 0) as runs,
          
//           COALESCE(COUNT(CASE WHEN isWicket = 1 THEN 1 END), 0) as wickets,
          
//           CASE 
//               WHEN COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) = 0 
//               THEN 0.0
//               ELSE 
//                   (COALESCE(SUM(runs), 0) + 
//                    COALESCE(SUM(CASE WHEN isWide = 1 THEN ${wideRun.toString()} ELSE 0 END), 0) + 
//                    COALESCE(SUM(CASE WHEN isNoBall = 1 THEN ${noBallRun.toString()} ELSE 0 END), 0)) * 6.0 / 
//                   COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END)
//           END as ER
          
       
//       FROM $TBL_BALL_BY_BALL 
//       WHERE matchId = ? 
//           AND inningNo = ? 
//           AND bowlerId = ?
//       GROUP BY bowlerId;
//         ''',
//       [matchId, inningNo, bowlerId],
//     );

//     final maidenQuery = await db.rawQuery(
//       '''
//        WITH numbered_balls AS (
//     SELECT 
//         id,
//         runs,
//         isWide,
//         isNoBall,
//         ((ROW_NUMBER() OVER (ORDER BY id) - 1) / 6) AS over_no
//     FROM $TBL_BALL_BY_BALL
//     WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
// ),
// over_runs AS (
//     SELECT 
//         over_no,
//         SUM(COALESCE(runs, 0) + 
//             COALESCE(CASE WHEN isWide = 1 THEN ${wideRun} ELSE 0 END, 0) + 
//             COALESCE(CASE WHEN isNoBall = 1 THEN ${noBallRun} ELSE 0 END, 0)
//         ) AS over_runs,
//         COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) 
//                       AND (isWide = 0 OR isWide IS NULL) 
//                    THEN 1 END) AS legal_balls_in_over
//     FROM numbered_balls
//     GROUP BY over_no
// )
// SELECT COUNT(*) AS maidens
// FROM over_runs
// WHERE over_runs = 0 AND legal_balls_in_over = 6;
 
//       ''',
//       [matchId, inningNo, bowlerId],
//     );

//     final maidens =
//         maidenQuery.isNotEmpty
//             ? (maidenQuery.first['maidens'] as num?)?.toDouble() ?? 0.0
//             : 0.0;

//     if (result.isEmpty) {
//       return {
//         'overs': 0.0,
//         'maidens': 0.0,
//         'runs': 0.0,
//         'wickets': 0.0,
//         'ER': 0.0,
//       };
//     }
//     log(result.toString());
//     final row = result.first;
//     return {
//       'overs': (row['overs'] as num?)?.toDouble() ?? 0.0,
//       'maidens': maidens,
//       'runs': (row['runs'] as num?)?.toDouble() ?? 0.0,
//       'wickets': (row['wickets'] as num?)?.toDouble() ?? 0.0,
//       'ER': (row['ER'] as num?)?.toDouble() ?? 0.0,
//     };
//   }

//   ///------------------description : calculate a current overs ---------------------------------
//   Future<double> calculateCurrentOvers(int matchId, int inningNo) async {
//     Database db = await MyDatabase().database;

//     // This query counts the total number of legal balls bowled.
//     // It excludes wides and no-balls from the count.
//     final List<Map<String, dynamic>> result = await db.rawQuery(
//       '''
//     SELECT COUNT(*) as legal_balls
//     FROM $TBL_BALL_BY_BALL
//     WHERE matchId = ?
//       AND inningNo = ?
//       AND (isWide IS NULL OR isWide = 0)
//       AND (isNoBall IS NULL OR isNoBall = 0)
//   ''',
//       [matchId, inningNo],
//     );

//     // Sqflite.firstIntValue is a helper to safely get the integer value from the result.
//     final int legalBalls = Sqflite.firstIntValue(result) ?? 0;

//     if (legalBalls == 0) {
//       return 0.0;
//     }

//     // Get the number of complete overs bowled (6 balls = 1 over)
//     final int completedOvers = legalBalls ~/ 6;

//     // Get the number of balls in the current incomplete over
//     final int ballsInCurrentOver = (legalBalls % 6);

//     // Cricket overs format: X.Y where X = complete overs, Y = balls in current over
//     // Examples: 0 balls = 0.0, 5 balls = 0.5, 6 balls = 1.0, 7 balls = 1.1
//     final oversResult = completedOvers.toDouble() + (ballsInCurrentOver / 10.0);

//     return oversResult;
//   }

//   ///------------------description : when inning no 1 and overs reach then change into match configuration
//   Future<void> shiftInning(
//     int matchId,
//     int currentBattingTeamId,
//     int strikerId,
//     int nonStrikerId,
//     int bowlerId,
//   ) async {
//     try {
//       Database db = await MyDatabase().database;
//       // Remove the redundant team swap - it's already done in the controller
//       await db.rawUpdate(
//         '''
//         UPDATE $TBL_MATCHES
//         SET inningNo = 2,
//             currentBattingTeamId = ?,
//             strikerBatsmanId = ?,
//             nonStrikerBatsmanId = ?,
//             bowlerId = ?
//         WHERE id = ?
//       ''',
//         [currentBattingTeamId, strikerId, nonStrikerId, bowlerId, matchId],
//       );
//     } catch (e) {
//       log(e.toString());
//     }
//   }

//   Future<void> getStateOfMatch(matchId) async {
//     final db = await MyDatabase().database;
//     CompleteMatchResultModel? matchState = await getCompleteMatchResult(
//       matchId,
//     );
//     await db.rawQuery(
//       '''
//         update $TBL_MATCHES
//         set matchState = ?
//         where id = ?
//       ''',
//       [jsonEncode(matchState?.toJson() ?? {}), matchId],
//     );
//     SyncFeature syncFeature = SyncFeature();

//     syncFeature.checkConnectivity(
//       () async => await syncFeature.syncMatchUpdate(matchId: matchId),
//     );
//   }

//   void _syncAllMatches() {
//     SyncFeature syncFeature = SyncFeature();
//     syncFeature.checkConnectivity(
//       () async => await syncFeature.syncAllMatches(),
//     );
//   }

//   ///------------------- Get Current Over State (e.g., "1 2 4 6 W WD NB") ----------------------
//   Future<Map<String, dynamic>> getCurrentOverState({
//     required int matchId,
//     required int inningNo,
//     required int bowlerId,
//     required int noBallRun,
//     required int wideRun,
//   }) async {
//     final db = await MyDatabase().database;

//     // Step 1: Count legal balls
//     final overInfo = await db.rawQuery(
//       '''
//     SELECT COUNT(CASE WHEN (isNoBall != 1) AND (isWide != 1) THEN 1 END) AS total_legal_balls
//     FROM $TBL_BALL_BY_BALL
//     WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
//   ''',
//       [matchId, inningNo, bowlerId],
//     );

//     if (overInfo.isEmpty) {
//       return _emptyOver();
//     }

//     final totalLegalBalls =
//         (overInfo.first['total_legal_balls'] as num?)?.toInt() ?? 0;
//     final completeOvers = totalLegalBalls ~/ 6;
//     int ballsInCompleteOvers = completeOvers * 6;

//     // Step 2: Get balls bowled and identify the current over
//     final ballData = await db.rawQuery(
//       '''
//     SELECT * FROM $TBL_BALL_BY_BALL
//     WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
//     ORDER BY id
//   ''',
//       [matchId, inningNo, bowlerId],
//     );

//     List<Map<String, dynamic>> currentOverBalls = [];
//     int legalBallsCounted = 0;

//     for (var ball in ballData) {
//       // Check if this ball is legally delivered
//       bool isLegal =
//           ((ball['isNoBall'] ?? 0) == 0) && ((ball['isWide'] ?? 0) == 0);

//       // Stop processing if we have already counted 6 legal balls for the current over.
//       // This prevents balls from the next over from being included.
//       if (legalBallsCounted >= ballsInCompleteOvers + 6) {
//         break;
//       }

//       // Start adding balls (legal or not) to our list once we have passed all the
//       // balls from previously completed overs.
//       if (legalBallsCounted >= ballsInCompleteOvers) {
//         currentOverBalls.add(ball);
//       }

//       // Increment the counter only if the ball was legal
//       if (isLegal) {
//         legalBallsCounted++;
//       }
//     }

//     // Step 3: Build display (This part remains unchanged and will now work correctly)
//     List<String> seq = [];
//     int legalCount = 0, runs = 0, wickets = 0;
//     for (var ball in currentOverBalls) {
//       bool wide = (ball['isWide'] ?? 0) == 1;
//       bool nb = (ball['isNoBall'] ?? 0) == 1;
//       bool wkt = (ball['isWicket'] ?? 0) == 1;
//       int r = (ball['runs'] ?? 0);
//       if (wkt) wickets++;
//       runs += r;

//       if (wide) {
//         seq.add(r > 1 ? "WD+${r - 1}" : "WD");
//       } else if (nb) {
//         seq.add(r > 1 ? "NB+${r - 1}" : "NB");
//       } else if (wkt) {
//         seq.add(r > 0 ? "${r}W" : "W");
//         legalCount++;
//       } else {
//         seq.add(r == 0 ? "•" : "$r");
//         legalCount++;
//       }
//     }

//     //call on every 5 balls
//     if (seq.length == 6) {
//       _syncAllMatches();
//     }
//     await getStateOfMatch(matchId);

//     return {
//       'currentOver': legalCount > 0 ? completeOvers + 1 : completeOvers,
//       'ballSequence': seq,
//       'overDisplay': seq.join(' '),
//       'ballCount': legalCount,
//       'totalDeliveries': seq.length,
//       'isOverComplete': legalCount >= 6,
//       'runsInOver': runs,
//       'wicketsInOver': wickets,
//     };
//   }

//   Map<String, dynamic> _emptyOver() => {
//     'currentOver': 1,
//     'ballSequence': [],
//     'overDisplay': '',
//     'ballCount': 0,
//     'isOverComplete': false,
//     'runsInOver': 0,
//     'wicketsInOver': 0,
//   };

//   ///update the match in online db
//   Future<void> updateMatch(CreateMatchModel match) async {
//     try {
//       ApiServices services = ApiServices();
//       Response res = await services.put(
//         "/CL_Matches/UpdateMatch?id=${match.matchIdOnline}",
//         match.toMap(),
//       );
//       log("::::::::::::::::::::::::::::");
//       log(match.toMap().toString());
//       if (res.statusCode == 200) {
//         log("Match updated in online db");
//       } else {
//         log("Match update failed in online db");
//       }
//     } catch (e) {
//       log("From updateMatch");
//       log(e.toString());
//     }
//   }

//   /// Delete all match-related data to ensure clean state for new matches
//   Future<void> deleteAllEntries() async {
//     Database db = await MyDatabase().database;

//     try {
//       // Clear all ball-by-ball data
//       await db.delete(TBL_BALL_BY_BALL);

//       // Clear all match data
//       await db.delete(TBL_MATCHES);

//       log('✅ All match data cleared successfully');
//     } catch (e) {
//       log('❌ Error clearing match data: $e');
//       throw e;
//     }
//   }

//   Future<double> calculateCRR(matchId, inningNo) async {
//     int totalRuns = await calculateRuns(matchId, inningNo);
//     double overs = await calculateCurrentOvers(matchId, inningNo);
//     int balls = (overs * 10).toInt() % 10;
//     int completeOvers = overs.toInt();
//     return totalRuns / (completeOvers + (balls / 6));
//   }

//   Future<void> endMatch(matchId) async {
//     // deleteAllEntries();
//     Database db = await MyDatabase().database;
//     await db.rawQuery(
//       '''
//     UPDATE $TBL_MATCHES
//     set status='completed' 
//     where id = ? 
//     ''',
//       [matchId],
//     );
//   }

//   // region Functions of getState
//   /// Get complete match result data
//   Future<CompleteMatchResultModel?> getCompleteMatchResult(int matchId) async {
//     try {
//       CreateMatchModel match = await findMatch(matchId);
//       if (match.id == null) {
//         throw Exception("Match not found");
//       }

//       // Team names
//       String team1Name = await getTeamName(match.team1 ?? 0);
//       String team2Name = await getTeamName(match.team2 ?? 0);

//       // Get innings results
//       TeamInningsResultModel? team1Innings = await getTeamInningsResult(
//         matchId,
//         1,
//         match.team1 ?? 0,
//       );
//       TeamInningsResultModel? team2Innings = await getTeamInningsResult(
//         matchId,
//         2,
//         match.team2 ?? 0,
//       );

//       // Get overs summary
//       List<OverSummaryModel> team1Overs = await getInningsOvers(matchId, 1);
//       List<OverSummaryModel> team2Overs = await getInningsOvers(matchId, 2);

//       // Variables for result
//       String? winnerTeamName;
//       String? resultDescription;
//       bool isCompleted = match.status?.toLowerCase() == "completed";

//       // If match completed, calculate winner
//       if (isCompleted && team1Innings != null && team2Innings != null) {
//         int team1Score = team1Innings.totalRuns ?? 0;
//         int team2Score = team2Innings.totalRuns ?? 0;

//         if (team2Score > team1Score) {
//           winnerTeamName = team2Name;
//           int wicketsRemaining = 10 - (team2Innings.wickets ?? 0);
//           resultDescription = "$team2Name won by $wicketsRemaining wickets";
//         } else if (team1Score > team2Score) {
//           winnerTeamName = team1Name;
//           int runsMargin = team1Score - team2Score;
//           resultDescription = "$team1Name won by $runsMargin runs";
//         } else {
//           resultDescription = "Match tied";
//         }
//       }

//       // If match is still live → get current batsmen & bowler
//       List<PlayerBattingResultModel>? currentBatsmen = [];
//       PlayerBowlingResultModel? currentBowler;

//       if (!isCompleted) {
//         Database db = await MyDatabase().database;

//         // Current inning = max inning in DB
//         List<Map<String, dynamic>> inningRes = await db.rawQuery(
//           '''SELECT MAX(inningNo) as currentInning FROM $TBL_BALL_BY_BALL WHERE matchId = ?''',
//           [matchId],
//         );

//         int currentInning = (inningRes.first['currentInning'] as int?) ?? 1;

//         // Current batsmen (last 2 not out players)
//         List<Map<String, dynamic>> batsmenData = await db.rawQuery(
//           '''SELECT tp.teamPlayerId as playerId, tp.playerName
//            FROM $TBL_TEAM_PLAYERS tp
//            WHERE tp.teamId = ?
//            AND tp.teamPlayerId NOT IN (
//              SELECT strikerBatsmanId FROM $TBL_BALL_BY_BALL 
//              WHERE matchId = ? AND inningNo = ? AND isWicket = 1
//            )
//            LIMIT 2''',
//           [
//             currentInning == 1 ? match.team1 : match.team2,
//             matchId,
//             currentInning,
//           ],
//         );

//         for (var b in batsmenData) {
//           Map<String, double> stats = await calculateBatsman(b['playerId']);
//           currentBatsmen.add(
//             PlayerBattingResultModel(
//               playerId: b['playerId'],
//               playerName: b['playerName'],
//               runs: stats['runs']?.toInt(),
//               balls: stats['balls']?.toInt(),
//               fours: stats['fours']?.toInt(),
//               sixes: stats['sixes']?.toInt(),
//               strikeRate: stats['strikeRate'],
//               isOut: false,
//               isNotOut: true,
//             ),
//           );
//         }

//         // Current bowler = bowler from last ball
//         List<Map<String, dynamic>> bowlerData = await db.rawQuery(
//           '''SELECT b.bowlerId, tp.playerName
//            FROM $TBL_BALL_BY_BALL b
//            JOIN $TBL_TEAM_PLAYERS tp ON b.bowlerId = tp.teamPlayerId
//            WHERE b.matchId = ? AND b.inningNo = ?
//            ORDER BY b.id DESC LIMIT 1''',
//           [matchId, currentInning],
//         );

//         if (bowlerData.isNotEmpty) {
//           int bowlerId = bowlerData.first['bowlerId'];
//           String bowlerName = bowlerData.first['playerName'];

//           Map<String, double> stats = await calculateBowler(
//             bowlerId: bowlerId,
//             matchId: matchId,
//             inningNo: currentInning,
//             noBallRun: match.noBallRun ?? 1,
//             wideRun: match.wideRun ?? 1,
//           );

//           currentBowler = PlayerBowlingResultModel(
//             playerId: bowlerId,
//             playerName: bowlerName,
//             overs: stats['overs'],
//             wickets: stats['wickets']?.toInt(),
//             runs: stats['runs']?.toInt(),
//             maidens: stats['maidens']?.toInt(),
//             economyRate: stats['ER'],
//           );
//         }
//       }

//       // Return final model
//       return CompleteMatchResultModel(
//         matchId: matchId,
//         matchTitle: "$team1Name vs $team2Name",
//         date: match.matchDate,
//         matchType: 'T20',
//         status: match.status,
//         winnerTeamName: winnerTeamName,
//         resultDescription: resultDescription,
//         team1Innings: team1Innings,
//         team2Innings: team2Innings,
//         team1Overs: team1Overs,
//         team2Overs: team2Overs,
//       );
//     } catch (e) {
//       log("Error getting hybrid match result: $e");
//       return null;
//     }
//   }

//   /// Get team innings result with player stats
//   Future<TeamInningsResultModel?> getTeamInningsResult(
//     int matchId,
//     int inningNo,
//     int teamId,
//   ) async {
//     try {
//       Database db = await MyDatabase().database;

//       // Get team total runs and wickets
//       int totalRuns = await calculateRuns(matchId, inningNo);
//       int wickets = await calculateWicket(matchId, inningNo);
//       double overs = await calculateCurrentOvers(matchId, inningNo);

//       if (totalRuns == 0 && wickets == 0 && overs == 0.0) {
//         return null; // No data for this innings
//       }

//       String teamName = await getTeamName(teamId);

//       // Get batting results
//       List<PlayerBattingResultModel> battingResults = await getBattingResults(
//         matchId,
//         inningNo,
//         teamId,
//       );

//       // Get bowling results (opposition bowlers)
//       List<PlayerBowlingResultModel> bowlingResults = await getBowlingResults(
//         matchId,
//         inningNo,
//       );

//       // Calculate extras
//       Map<String, int> extras = await calculateExtras(matchId, inningNo);

//       return TeamInningsResultModel(
//         teamId: teamId,
//         teamName: teamName,
//         inningNo: inningNo,
//         totalRuns: totalRuns,
//         wickets: wickets,
//         overs: overs,
//         battingResults: battingResults,
//         bowlingResults: bowlingResults,
//         wides: extras['wides'],
//         noBalls: extras['noBalls'],
//         byes: extras['byes'],
//         extras: extras['total'],
//       );
//     } catch (e) {
//       log('Error getting team innings result: $e');
//       return null;
//     }
//   }

//   /// Get batting results for a team in an innings
//   Future<List<PlayerBattingResultModel>> getBattingResults(
//     int matchId,
//     int inningNo,
//     int teamId,
//   ) async {
//     try {
//       Database db = await MyDatabase().database;

//       // Get all batsmen who batted in this innings
//       List<Map<String, dynamic>> batsmenData = await db.rawQuery(
//         '''
//         SELECT DISTINCT 
//           b.strikerBatsmanId as playerId,
//           tp.playerName
//         FROM $TBL_BALL_BY_BALL b
//         JOIN $TBL_TEAM_PLAYERS tp ON b.strikerBatsmanId = tp.teamPlayerId
//         WHERE b.matchId = ? AND b.inningNo = ? AND tp.teamId = ?
//         ORDER BY b.strikerBatsmanId
//         ''',
//         [matchId, inningNo, teamId],
//       );

//       List<PlayerBattingResultModel> battingResults = [];

//       for (var batsman in batsmenData) {
//         int playerId = batsman['playerId'];
//         String playerName = batsman['playerName'];

//         // Get detailed batting stats
//         Map<String, double> stats = await calculateBatsman(playerId);

//         // Check if player got out
//         List<Map<String, dynamic>> wicketData = await db.rawQuery(
//           '''
//           SELECT wicketType FROM $TBL_BALL_BY_BALL
//           WHERE matchId = ? AND inningNo = ? AND strikerBatsmanId = ? AND isWicket = 1
//           LIMIT 1
//           ''',
//           [matchId, inningNo, playerId],
//         );

//         bool isOut = wicketData.isNotEmpty;
//         String? dismissalType = isOut ? wicketData.first['wicketType'] : null;

//         battingResults.add(
//           PlayerBattingResultModel(
//             playerId: playerId,
//             playerName: playerName,
//             runs: stats['runs']?.toInt(),
//             balls: stats['balls']?.toInt(),
//             fours: stats['fours']?.toInt(),
//             sixes: stats['sixes']?.toInt(),
//             strikeRate: stats['strikeRate'],
//             isOut: isOut,
//             isNotOut: !isOut,
//             dismissalType: dismissalType,
//           ),
//         );
//       }

//       return battingResults;
//     } catch (e) {
//       log('Error getting batting results: $e');
//       return [];
//     }
//   }

//   /// Get bowling results for an innings
//   Future<List<PlayerBowlingResultModel>> getBowlingResults(
//     int matchId,
//     int inningNo,
//   ) async {
//     try {
//       Database db = await MyDatabase().database;

//       // Get all bowlers who bowled in this innings
//       List<Map<String, dynamic>> bowlersData = await db.rawQuery(
//         '''
//         SELECT DISTINCT 
//           b.bowlerId as playerId,
//           tp.playerName
//         FROM $TBL_BALL_BY_BALL b
//         JOIN $TBL_TEAM_PLAYERS tp ON b.bowlerId = tp.teamPlayerId
//         WHERE b.matchId = ? AND b.inningNo = ?
//         ORDER BY b.bowlerId
//         ''',
//         [matchId, inningNo],
//       );

//       List<PlayerBowlingResultModel> bowlingResults = [];

//       // Get match config for wide/no-ball runs
//       CreateMatchModel match = await findMatch(matchId);
//       int wideRun = match.wideRun ?? 1;
//       int noBallRun = match.noBallRun ?? 1;

//       for (var bowler in bowlersData) {
//         int playerId = bowler['playerId'];
//         String playerName = bowler['playerName'];

//         // Get detailed bowling stats
//         Map<String, double> stats = await calculateBowler(
//           bowlerId: playerId,
//           matchId: matchId,
//           inningNo: inningNo,
//           noBallRun: noBallRun,
//           wideRun: wideRun,
//         );

//         bowlingResults.add(
//           PlayerBowlingResultModel(
//             playerId: playerId,
//             playerName: playerName,
//             overs: stats['overs'],
//             wickets: stats['wickets']?.toInt(),
//             runs: stats['runs']?.toInt(),
//             maidens: stats['maidens']?.toInt(),
//             economyRate: stats['ER'],
//           ),
//         );
//       }

//       return bowlingResults;
//     } catch (e) {
//       log('Error getting bowling results: $e');
//       return [];
//     }
//   }

//   /// Get over-by-over data for an innings
//   Future<List<OverSummaryModel>> getInningsOvers(
//     int matchId,
//     int inningNo,
//   ) async {
//     try {
//       Database db = await MyDatabase().database;

//       // Get all balls grouped by over
//       List<Map<String, dynamic>> ballsData = await db.rawQuery(
//         '''
//         SELECT 
//           *,
//           ((ROW_NUMBER() OVER (PARTITION BY bowlerId ORDER BY id) - 1) 
//            / CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) 
//                   THEN 6 ELSE 1000 END) + 1 as over_number
//         FROM $TBL_BALL_BY_BALL
//         WHERE matchId = ? AND inningNo = ?
//         ORDER BY id
//         ''',
//         [matchId, inningNo],
//       );

//       Map<int, List<BallDetailModel>> overGroups = {};

//       int currentOverNumber = 1;
//       int legalBallsInCurrentOver = 0;

//       for (var ballData in ballsData) {
//         BallDetailModel ball = BallDetailModel.fromJson(ballData);

//         // Group balls by over (6 legal balls per over)
//         if (!overGroups.containsKey(currentOverNumber)) {
//           overGroups[currentOverNumber] = [];
//         }

//         overGroups[currentOverNumber]!.add(ball);

//         // Count legal balls to determine when over is complete
//         if (ball.countsTowardOver) {
//           legalBallsInCurrentOver++;
//           if (legalBallsInCurrentOver >= 6) {
//             currentOverNumber++;
//             legalBallsInCurrentOver = 0;
//           }
//         }
//       }

//       List<OverSummaryModel> overs = [];

//       overGroups.forEach((overNumber, balls) async {
//         // Get bowler info from first ball
//         String bowlerName = "";
//         if (balls.isNotEmpty) {
//           bowlerName = await getPlayerName(balls.first.bowlerId ?? 0);
//         }

//         overs.add(
//           OverSummaryModel(
//             matchId: matchId,
//             inningNo: inningNo,
//             overNumber: overNumber,
//             bowlerName: bowlerName,
//             balls: balls,
//           ),
//         );
//       });

//       return overs;
//     } catch (e) {
//       log('Error getting innings overs: $e');
//       return [];
//     }
//   }

//   /// Calculate extras for an innings
//   Future<Map<String, int>> calculateExtras(int matchId, int inningNo) async {
//     try {
//       Database db = await MyDatabase().database;

//       List<Map<String, dynamic>> result = await db.rawQuery(
//         '''
//         SELECT 
//           SUM(CASE WHEN isWide = 1 THEN 1 ELSE 0 END) as wides,
//           SUM(CASE WHEN isNoBall = 1 THEN 1 ELSE 0 END) as noBalls,
//           SUM(CASE WHEN isBye = 1 THEN runs ELSE 0 END) as byes
//         FROM $TBL_BALL_BY_BALL
//         WHERE matchId = ? AND inningNo = ?
//         ''',
//         [matchId, inningNo],
//       );

//       if (result.isNotEmpty) {
//         int wides = (result.first['wides'] as num?)?.toInt() ?? 0;
//         int noBalls = (result.first['noBalls'] as num?)?.toInt() ?? 0;
//         int byes = (result.first['byes'] as num?)?.toInt() ?? 0;

//         return {
//           'wides': wides,
//           'noBalls': noBalls,
//           'byes': byes,
//           'total': wides + noBalls + byes,
//         };
//       }

//       return {'wides': 0, 'noBalls': 0, 'byes': 0, 'total': 0};
//     } catch (e) {
//       log('Error calculating extras: $e');
//       return {'wides': 0, 'noBalls': 0, 'byes': 0, 'total': 0};
//     }
//   }

//   Future<List<PlayersModel>> getAllPlayersByTeam(int teamId) async {
//     try {
//       Database db = await MyDatabase().database;
//       List<Map<String, dynamic>> data = await db.rawQuery(
//         '''
//       SELECT * FROM $TBL_TEAM_PLAYERS
//       WHERE teamId = ?
//       ''',
//         [teamId],
//       );

//       List<PlayersModel> players = [];
//       data.forEach((element) {
//         players.add(PlayersModel().fromMap(element));
//       });
//       return players;
//     } catch (e) {
//       log(e.toString());
//       return [];
//     }
//   }

//   //endregion
// }
