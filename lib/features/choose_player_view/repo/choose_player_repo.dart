import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerRepo implements IChoosePlayer {
  final MyDatabase _database = MyDatabase();
  
  @override
  Future<List<PlayerModel>?> getPlayersByTeamId(int teamId) async {
    try {
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_TeamPlayers/GetTeamPlayersById/$teamId",
      );

      // Handle different response structures
      List<dynamic> playersData;
      if (data.containsKey("data") && data["data"] is List) {
        playersData = data["data"] as List<dynamic>;
      } else if (data is List) {
        playersData = data as List<dynamic>;
      } else {
        playersData = [data];
      }

      return List.generate(playersData.length, (i) {
        return PlayerModel.fromMap(playersData[i]);
      });
    } catch (e, stackTrace) {
      log("Error from Choose player repo $e  ::::::::: $stackTrace");
      return null;
    }
  }

  /// Mark a player as out - This method is now deprecated
  /// Use ScoreboardController.onTapWicket instead for proper wicket handling
  @deprecated
  Future<void> markPlayerOut({
    required int matchId,
    required int inningNo,
    required int playerId,
    required double currentOvers,
    required String wicketType,
    int? bowlerId,
    int? nonStrikerBatsmanId,
  }) async {
    // This method is deprecated to avoid duplicate ball entries
    // The ball entry is now created directly in ScoreboardController.onTapWicket
    log('WARNING: markPlayerOut is deprecated. Ball entry should be created in ScoreboardController.');
    log('Player $playerId would be marked as out with wicket type: $wicketType');
  }

  /// Get list of out player IDs for a specific match and inning
  Future<List<int>> getOutPlayerIds({
    required int matchId,
    required int inningNo,
  }) async {
    final Database db = await _database.database;

    try {
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT DISTINCT strikerBatsmanId 
        FROM $TBL_BALL_BY_BALL 
        WHERE matchId = ? 
        AND inningNo = ? 
        AND isWicket = 1
        AND strikerBatsmanId IS NOT NULL
        AND strikerBatsmanId > 0
      ''', [matchId, inningNo]);

      List<int> outPlayerIds = results
          .map<int>((row) => row['strikerBatsmanId'] as int)
          .where((id) => id > 0)
          .toList();
          
      log('📊 Found ${outPlayerIds.length} out players for match $matchId, inning $inningNo: $outPlayerIds');
      return outPlayerIds;
    } catch (e) {
      log('❌ Error getting out players: $e');
      return [];
    }
  }

  /// Get currently playing batsmen (striker and non-striker) for a match
  Future<List<int>> getCurrentlyPlayingPlayerIds({
    required int matchId,
  }) async {
    final Database db = await _database.database;

    try {
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT strikerBatsmanId, nonStrikerBatsmanId 
        FROM $TBL_MATCHES 
        WHERE id = ?
      ''', [matchId]);

      if (results.isNotEmpty) {
        List<int> currentPlayers = [];
        final row = results.first;
        
        final strikerId = row['strikerBatsmanId'] as int?;
        final nonStrikerId = row['nonStrikerBatsmanId'] as int?;
        
        if (strikerId != null && strikerId > 0) {
          currentPlayers.add(strikerId);
        }
        
        if (nonStrikerId != null && nonStrikerId > 0) {
          currentPlayers.add(nonStrikerId);
        }
        
        log('🏑 Currently playing in match $matchId: $currentPlayers (Striker: $strikerId, Non-Striker: $nonStrikerId)');
        return currentPlayers;
      }
      
      log('⚠️ No match found for ID: $matchId');
      return [];
    } catch (e) {
      log('❌ Error getting currently playing players: $e');
      return [];
    }
  }

  /// Get all player IDs that should be hidden (out players + currently playing)
  Future<List<int>> getHiddenPlayerIds({
    required int matchId,
    required int inningNo,
  }) async {
    try {
      final outPlayers = await getOutPlayerIds(
        matchId: matchId,
        inningNo: inningNo,
      );
      
      final currentPlayers = await getCurrentlyPlayingPlayerIds(
        matchId: matchId,
      );

      // Combine both lists and remove duplicates
      final Set<int> hiddenPlayerIds = {...outPlayers, ...currentPlayers};
      
      log('Hidden players for match $matchId, inning $inningNo: $hiddenPlayerIds');
      return hiddenPlayerIds.toList();
    } catch (e) {
      log('Error getting hidden players: $e');
      return [];
    }
  }

  /// Check if a specific player is out in a match/inning
  Future<bool> isPlayerOut({
    required int matchId,
    required int inningNo,
    required int playerId,
  }) async {
    final Database db = await _database.database;

    try {
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $TBL_BALL_BY_BALL 
        WHERE matchId = ? 
        AND inningNo = ? 
        AND strikerBatsmanId = ? 
        AND isWicket = 1
      ''', [matchId, inningNo, playerId]);

      return results.isNotEmpty && (results.first['count'] as int) > 0;
    } catch (e) {
      log('Error checking if player is out: $e');
      return false;
    }
  }
}
