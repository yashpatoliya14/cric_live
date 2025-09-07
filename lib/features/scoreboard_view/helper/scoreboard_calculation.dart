import 'package:cric_live/utils/import_exports.dart';

class ScoreboardCalculation extends ScoreboardMatchManager {
  final ScoreboardRepo _repo;

  ScoreboardCalculation(this._repo, matchId) : super(_repo, matchId);

  /// calculate CRR
  Future<void> calculateCRR() async {
    CRR.value = await _repo.calculateCRR(matchId, inningNo.value);
  }

  /// get current overs
  Future<void> calculateCurrentOvers() async {
    currentOvers.value = await _repo.calculateCurrentOvers(
      matchId,
      inningNo.value,
    );
  }

  /// get current overs state
  Future<void> calculateOversState() async {
    try {
      final overStateData = await _repo.getCurrentOverState(
        matchId: matchId,
        inningNo: inningNo.value,
        bowlerId: bowlerId.value,
      );

      if (overStateData.isNotEmpty) {
        oversState.value = overStateData;
        oversState.refresh();
      } else {
        log('⚠️ calculateOversState returned empty data');
        // Set default values
        oversState.value = {
          'ballSequence': [],
          'overDisplay': '',
          'ballCount': 0,
          'isOverComplete': false,
          'runsInOver': 0,
          'wicketsInOver': 0,
        };
        oversState.refresh();
      }
    } catch (e) {
      log('❌ Error in calculateOversState: $e');
      log('   StackTrace: ${StackTrace.current}');
      // Set error state or default values
      oversState.value = {
        'ballSequence': [],
        'overDisplay': 'Error loading over data',
        'ballCount': 0,
        'isOverComplete': false,
        'runsInOver': 0,
        'wicketsInOver': 0,
        'error': e.toString(),
      };
      oversState.refresh();
    }
  }

  /// calculate inning total runs
  Future<void> calculateRuns() async {
    totalRuns.value = await _repo.calculateRuns(matchId, inningNo.value);
    totalRuns.refresh();
    calculateCurrentOvers();
    calculateCRR();
    // Check for over completion after updating scores
    // await endOver();
  }

  /// calculate inning total wickets
  Future<void> calculateWicket() async {
    wickets.value = await _repo.calculateWicket(matchId, inningNo.value);
    wickets.refresh();
  }

  /// calculate batsman run states
  Future<void> calculateBatsman() async {
    strikerBatsmanState.value = await _repo.calculateBatsman(
      strikerBatsmanId.toInt(),
      matchId,
    );
    nonStrikerBatsmanState.value = await _repo.calculateBatsman(
      nonStrikerBatsmanId.toInt(),
      matchId,
    );
  }

  /// calculate bowler run states
  Future<void> calculateBowler() async {
    bowlerState.value = await _repo.calculateBowler(
      bowlerId: bowlerId.toInt(),
      matchId: matchId,
      inningNo: inningNo.value,
      noBallRun: noBallRun,
      wideRun: wideRun,
    );
  }
}
