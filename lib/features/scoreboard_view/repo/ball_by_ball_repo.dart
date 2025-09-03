// features/scoreboard/repositories/ball_by_ball_repo.dart

import 'package:cric_live/utils/import_exports.dart';

mixin BallByBallRepo {
  /// Add ball data entry to the local database.
  Future<int> addBallEntry(ScoreboardModel data) async {
    try {
      final Database db = await MyDatabase().database;
      return await db.insert(TBL_BALL_BY_BALL, data.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Undo the last ball entry from the database.
  Future<ScoreboardModel?> undoBall() async {
    final Database db = await MyDatabase().database;
    await db.rawQuery(''' 
      DELETE FROM ${TBL_BALL_BY_BALL}
      WHERE id = (
          SELECT id
          FROM ${TBL_BALL_BY_BALL}
          ORDER BY id DESC
          LIMIT 1
      );
      ''');
    return lastEntry();
  }

  /// Get the most recent ball entry.
  Future<ScoreboardModel?> lastEntry() async {
    final Database db = await MyDatabase().database;
    final data = await db.rawQuery(''' 
      SELECT * FROM ${TBL_BALL_BY_BALL}
      WHERE id = (
          SELECT id
          FROM ${TBL_BALL_BY_BALL}
          ORDER BY id DESC
          LIMIT 1
      );
      ''');
    return data.isNotEmpty ? ScoreboardModel().fromMap(data[0]) : null;
  }
}
