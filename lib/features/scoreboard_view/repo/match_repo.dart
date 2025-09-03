import 'package:cric_live/utils/import_exports.dart';

mixin MatchRepo {
  /// find match
  Future<CreateMatchModel> findMatch(int matchId) async {
    Database db = await MyDatabase().database;
    final matchResult = await db.rawQuery(
      'SELECT * FROM $TBL_MATCHES WHERE id = ?',
      [matchId],
    );

    if (matchResult.isEmpty) {
      log("No match found with id: $matchId");
      Get.snackbar("Match Not Found", "Try Again !");
      return CreateMatchModel();
    }

    return CreateMatchModel().fromMap(matchResult.first);
  }

  /// find team name
  Future<String> getTeamName(int teamId) async {
    try {
      Database db = await MyDatabase().database;
      final result = await db.rawQuery(
        'SELECT * FROM $TBL_TEAMS WHERE teamId = ?',
        [teamId],
      );

      return result.isNotEmpty ? result.first['teamName'].toString() : "";
    } catch (e) {
      log(e.toString());
      return "";
    }
  }

  /// It takes teamPlayerId and gives a playerName.
  Future<String> getPlayerName(int id) async {
    try {
      Database db = await MyDatabase().database;
      List<Map<String, dynamic>> data = await db.rawQuery(
        'SELECT * FROM ${TBL_TEAM_PLAYERS} WHERE teamPlayerId = ?',
        [id],
      );

      return data.isNotEmpty ? data.first['playerName'] : "";
    } catch (e) {
      log(e.toString());
      return "";
    }
  }

  /// when inning no 1 and overs reach then change into match configuration
  Future<void> shiftInning({
    required int matchId,
    required int currentBattingTeamId,
    required int strikerId,
    required int nonStrikerId,
    required int bowlerId,
  }) async {
    try {
      Database db = await MyDatabase().database;
      await db.rawUpdate(
        '''
        UPDATE $TBL_MATCHES
        SET inningNo = 2,
            currentBattingTeamId = ?,
            strikerBatsmanId = ?,
            nonStrikerBatsmanId = ?,
            bowlerId = ?
        WHERE id = ?
      ''',
        [currentBattingTeamId, strikerId, nonStrikerId, bowlerId, matchId],
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> endMatch(matchId) async {
    CreateMatchModel model = CreateMatchModel(status: 'completed');
    updateMatch(model);
    log("$matchId");
    SyncFeature syncFeature = SyncFeature();
    syncFeature.checkConnectivity(
      () async => await syncFeature.syncMatchUpdate(matchId: matchId),
    );
  }

  Future<void> deleteAllEntries() async {
    Database db = await MyDatabase().database;
    try {
      await db.delete(TBL_BALL_BY_BALL);
      await db.delete(TBL_MATCHES);
      log('All match data cleared successfully');
    } catch (e) {
      log('Error clearing match data from deleteAllEntries in match_repo: $e');
    }
  }

  Future<List<PlayersModel>> getAllPlayersByTeam(int teamId) async {
    try {
      Database db = await MyDatabase().database;
      List<Map<String, dynamic>> data = await db.rawQuery(
        'SELECT * FROM $TBL_TEAM_PLAYERS WHERE teamId = ?',
        [teamId],
      );
      return data.map((e) => PlayersModel().fromMap(e)).toList();
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<void> updateMatch(CreateMatchModel model) async {
    try {
      log("match update status ::$model");
      Database db = await MyDatabase().database;
      await db.update(
        TBL_MATCHES,
        model.toMap(),
        where: "id = ?",
        whereArgs: [model.id],
      );
    } catch (e) {
      log("Error in update match locally");
      log(e.toString());
    }
  }
}
