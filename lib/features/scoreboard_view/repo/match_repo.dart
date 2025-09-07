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

    return CreateMatchModel.fromMap(matchResult.first);
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

  /// find team name online
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

  /// It takes teamPlayerId and gives a playerName.
  Future<String> getPlayerName(int id) async {
    try {
      Database db = await MyDatabase().database;
      List<Map<String, dynamic>> data = await db.rawQuery(
        'SELECT * FROM $TBL_TEAM_PLAYERS WHERE teamPlayerId = ?',
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
    log(
      "Icalled and my match id is $matchId :::::::::::::::::::::::::::::::::::::::::::hello here",
    );
    CreateMatchModel model = CreateMatchModel(status: 'completed');
    updateMatch(model);
    log("$matchId");
    SyncFeature syncFeature = SyncFeature();
    syncFeature.checkConnectivity(
      () async => await syncFeature.syncMatchUpdate(matchId: matchId),
    );
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
      log("match update status ::${model.toMap()}");
      Database db = await MyDatabase().database;
      await db.rawQuery(
        '''
        update $TBL_MATCHES
        set status='completed'
        where id = ?
      ''',
        [model.id],
      );
    } catch (e) {
      log("Error in update match locally");
      log(e.toString());
    }
  }
}
