import 'package:cric_live/utils/import_exports.dart';

class ResultController extends GetxController {
  final ResultRepo _repo = ResultRepo();

  // Observables
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CompleteMatchResultModel?> matchResult =
      Rx<CompleteMatchResultModel?>(null);
  final RxInt currentMatchId = 0.obs;

  // Getters for easy access
  TeamInningsResultModel? get team1Innings => matchResult.value?.team1Innings;
  TeamInningsResultModel? get team2Innings => matchResult.value?.team2Innings;
  String get matchTitle => matchResult.value?.matchTitle ?? 'Match Result';
  String get resultSummary => matchResult.value?.matchSummary ?? '';

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  void _initializeData() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments.containsKey('matchId')) {
      currentMatchId.value = arguments['matchId'] as int;
      loadMatchResult(currentMatchId.value);
    } else {
      errorMessage.value = 'No match selected';
      isLoading.value = false;
    }
  }

  /// Load complete match result data
  Future<void> loadMatchResult(int matchId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      CompleteMatchResultModel? result = await _repo.getCompleteMatchResult(
        matchId,
      );

      if (result != null) {
        matchResult.value = result;
      } else {
        errorMessage.value = 'Failed to load match result';
      }
    } catch (e) {
      print('Error in loadMatchResult: $e');
      errorMessage.value = 'Error loading match result: ${e.toString()}';
      log('Error in loadMatchResult: $e');
    } finally {
      isLoading.value = false;
      print('=== Loading complete, isLoading: ${isLoading.value} ===');
    }
  }

  /// Refresh match data
  Future<void> refreshMatchData() async {
    if (currentMatchId.value > 0) {
      await loadMatchResult(currentMatchId.value);
    }
  }

  /// Get batting results for a specific team
  List<PlayerBattingResultModel> getBattingResults(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.battingResults ?? [];
    } else {
      return team2Innings?.battingResults ?? [];
    }
  }

  /// Get bowling results for a specific team
  List<PlayerBowlingResultModel> getBowlingResults(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.bowlingResults ?? [];
    } else {
      return team2Innings?.bowlingResults ?? [];
    }
  }


  /// Get team name by innings
  String getTeamName(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.teamName ?? 'Team 1';
    } else {
      return team2Innings?.teamName ?? 'Team 2';
    }
  }

  /// Get team score display
  String getTeamScore(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.scoreDisplay ?? '0/0';
    } else {
      return team2Innings?.scoreDisplay ?? '0/0';
    }
  }

  /// Get team overs display
  String getTeamOversDisplay(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.oversDisplay ?? '0.0';
    } else {
      return team2Innings?.oversDisplay ?? '0.0';
    }
  }

  /// Check if match has data
  bool get hasMatchData => matchResult.value != null;

  /// Check if team has data
  bool hasTeamData(int inningNo) {
    if (inningNo == 1) {
      return team1Innings != null;
    } else {
      return team2Innings != null;
    }
  }

  /// Get match status for display
  String get matchStatus {
    if (isLoading.value) return 'Loading...';
    if (errorMessage.value.isNotEmpty) return errorMessage.value;
    if (!hasMatchData) return 'No match data';
    return matchResult.value?.status ?? 'Unknown';
  }

  deleteTeamAndPlayers() async {
    final Database db = await MyDatabase().database;
    await db.rawQuery('''
      
      delete from $TBL_TEAM_PLAYERS
      
    
    ''');
    await db.rawQuery('''
      
      delete from $TBL_TEAMS
      
    
    ''');
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    deleteTeamAndPlayers();
  }
}
