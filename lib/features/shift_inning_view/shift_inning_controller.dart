import 'package:cric_live/utils/import_exports.dart';

class ShiftInningController extends GetxController {
  final int matchId;
  ShiftInningController({required this.matchId});
  final ShiftInningRepo _repo = ShiftInningRepo();

  // Local variables
  int _team1Id = 0;
  int _team2Id = 0;
  int _battingTeamId = 0;
  int _bowlingTeamId = 0;

  // Getters for private variables
  int get team1Id => _team1Id;
  int get team2Id => _team2Id;
  int get battingTeamId => _battingTeamId;
  int get bowlingTeamId => _bowlingTeamId;

  MatchModel? _matchModel;
  MatchModel? get matchModel => _matchModel;

  // Rx variables
  final RxString team1 = "".obs;
  final RxString team2 = "".obs;
  final RxString bowler = "".obs;
  final RxInt bowlerId = 0.obs;
  final RxString nonStrikerBatsman = "".obs;
  final RxInt nonStrikerBatsmanId = 0.obs;
  final RxString strikerBatsman = "".obs;
  final RxInt strikerBatsmanId = 0.obs;

  // UI state variables
  final RxBool isLoading = true.obs;
  final RxBool isSelectingBatsmen = false.obs;
  final RxBool isSelectingBowler = false.obs;
  final RxString errorMessage = "".obs;

  /// Check if all required players are selected
  bool get isReadyToStart {
    return strikerBatsmanId.value > 0 &&
        nonStrikerBatsmanId.value > 0 &&
        bowlerId.value > 0 &&
        strikerBatsman.value.isNotEmpty &&
        nonStrikerBatsman.value.isNotEmpty &&
        bowler.value.isNotEmpty;
  }

  /// Get batting team name
  String get battingTeamName {
    return _battingTeamId == _team1Id ? team1.value : team2.value;
  }

  /// Get bowling team name
  String get bowlingTeamName {
    return _bowlingTeamId == _team1Id ? team1.value : team2.value;
  }

  @override
  void onInit() {
    super.onInit();
    initializeMatch();
  }

  /// Initialize match data with error handling
  Future<void> initializeMatch() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      await findMatch();
    } catch (e) {
      errorMessage.value = "Failed to load match data: ${e.toString()}";
      log('Error initializing match: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Find and initialize match data
  Future<void> findMatch() async {
    _matchModel = await _repo.findMatch(matchId);
    if (_matchModel == null) {
      throw Exception('Match not found');
    }

    _team1Id = _matchModel!.team1 ?? 0;
    _team2Id = _matchModel!.team2 ?? 0;

    if (_team1Id == 0 || _team2Id == 0) {
      throw Exception('Invalid team data');
    }

    // Fetch team names concurrently
    final teamNames = await Future.wait([
      _repo.getTeamName(_team1Id),
      _repo.getTeamName(_team2Id),
    ]);

    team1.value = teamNames[0];
    team2.value = teamNames[1];

    // Determine batting and bowling teams for second inning
    _bowlingTeamId = _matchModel!.currentBattingTeamId ?? 0;
    _battingTeamId = (_bowlingTeamId == _team1Id) ? _team2Id : _team1Id;

    log('Match initialized: ${team1.value} vs ${team2.value}');
    log('Batting team: $battingTeamName, Bowling team: $bowlingTeamName');
  }

  /// Select opening batsmen with proper validation
  Future<void> selectBatsman() async {
    try {
      isSelectingBatsmen.value = true;

      // Get current selected player IDs if any
      List<int> currentSelectedIds = [];
      if (strikerBatsmanId.value > 0) currentSelectedIds.add(strikerBatsmanId.value);
      if (nonStrikerBatsmanId.value > 0) currentSelectedIds.add(nonStrikerBatsmanId.value);
      if (currentSelectedIds.isNotEmpty) {
        log('🔄 Passing currently selected batsman IDs: $currentSelectedIds');
      }

      final dynamic result = await Get.toNamed(
        NAV_CHOOSE_PLAYER,
        arguments: {
          "teamId": _battingTeamId,
          "limit": 2,
          "title": "Select Opening Batsmen for $battingTeamName",
          "selectedPlayerIds": currentSelectedIds,
        },
      );

      if (result == null) {
        // User cancelled selection
        return;
      }

      // Safely cast the result to List<PlayerModel>
      List<PlayerModel> batters;
      if (result is List<PlayerModel>) {
        batters = result;
      } else if (result is List) {
        // Try to cast each item
        try {
          batters = result.cast<PlayerModel>();
        } catch (e) {
          _showError("Invalid player data received. Please try again.");
          return;
        }
      } else {
        _showError("Unexpected data format received. Please try again.");
        return;
      }

      if (batters.length < 2) {
        _showError("Please select exactly 2 batsmen to continue.");
        return;
      }

      // Validate player data
      final striker = batters[0];
      final nonStriker = batters[1];

      if (striker.teamPlayerId == null ||
          striker.teamPlayerId! <= 0 ||
          nonStriker.teamPlayerId == null ||
          nonStriker.teamPlayerId! <= 0) {
        _showError("Invalid player selection. Please try again.");
        return;
      }

      if (striker.teamPlayerId == nonStriker.teamPlayerId) {
        _showError("Please select two different players.");
        return;
      }

      // Update player data
      strikerBatsmanId.value = striker.teamPlayerId!;
      nonStrikerBatsmanId.value = nonStriker.teamPlayerId!;
      strikerBatsman.value = striker.playerName ?? "Unknown Player";
      nonStrikerBatsman.value = nonStriker.playerName ?? "Unknown Player";

      log('Opening batsmen selected successfully');
    } catch (e) {
      _showError("Failed to select batsmen: ${e.toString()}");
      log('Error selecting batsmen: $e');
    } finally {
      isSelectingBatsmen.value = false;
    }
  }

  /// Select opening bowler with proper validation
  Future<void> selectBowler() async {
    try {
      isSelectingBowler.value = true;

      // Get current selected bowler ID if any
      List<int> currentSelectedIds = [];
      if (bowlerId.value > 0) {
        currentSelectedIds.add(bowlerId.value);
        log('🔄 Passing currently selected bowler ID: $currentSelectedIds');
      }

      final dynamic result = await Get.toNamed(
        NAV_CHOOSE_PLAYER,
        arguments: {
          "teamId": _bowlingTeamId,
          "limit": 1,
          "title": "Select Opening Bowler for $bowlingTeamName",
          "selectedPlayerIds": currentSelectedIds,
        },
      );

      if (result == null) {
        // User cancelled selection
        return;
      }

      // Safely cast the result to List<PlayerModel>
      List<PlayerModel> bowlers;
      if (result is List<PlayerModel>) {
        bowlers = result;
      } else if (result is List) {
        // Try to cast each item
        try {
          bowlers = result.cast<PlayerModel>();
        } catch (e) {
          _showError("Invalid player data received. Please try again.");
          return;
        }
      } else {
        _showError("Unexpected data format received. Please try again.");
        return;
      }

      if (bowlers.isEmpty) {
        _showError("Please select a bowler to continue.");
        return;
      }

      final selectedBowler = bowlers[0];

      if (selectedBowler.teamPlayerId == null ||
          selectedBowler.teamPlayerId! <= 0) {
        _showError("Invalid bowler selection. Please try again.");
        return;
      }

      bowlerId.value = selectedBowler.teamPlayerId!;
      bowler.value = selectedBowler.playerName ?? "Unknown Player";

      log('Opening bowler selected successfully');
    } catch (e) {
      _showError("Failed to select bowler: ${e.toString()}");
      log('Error selecting bowler: $e');
    } finally {
      isSelectingBowler.value = false;
    }
  }

  /// Start the second inning - force start without requiring all players
  Future<void> shiftInning() async {
    // Force start the inning - no validation required
    log('Force starting second inning - players can be selected later');
    
    showAppDialog(
      onConfirm: () async {
        try {
          isLoading.value = true;

          // Get default players if not selected
          int actualStrikerId = strikerBatsmanId.value;
          int actualNonStrikerId = nonStrikerBatsmanId.value;
          int actualBowlerId = bowlerId.value;
          
          // If players are not selected, get any available players from teams
          if (actualStrikerId <= 0 || actualNonStrikerId <= 0) {
            try {
              // Get first two players from batting team as defaults
              final choosePlayerRepo = ChoosePlayerRepo();
              final battingPlayers = await choosePlayerRepo.getPlayersByTeamId(_battingTeamId);
              if (battingPlayers != null && battingPlayers.isNotEmpty) {
                if (actualStrikerId <= 0) {
                  actualStrikerId = battingPlayers[0].teamPlayerId ?? 0;
                  strikerBatsmanId.value = actualStrikerId;
                  strikerBatsman.value = battingPlayers[0].playerName ?? "Player 1";
                  log('Auto-selected striker: ${strikerBatsman.value} (ID: $actualStrikerId)');
                }
                if (actualNonStrikerId <= 0 && battingPlayers.length > 1) {
                  actualNonStrikerId = battingPlayers[1].teamPlayerId ?? 0;
                  nonStrikerBatsmanId.value = actualNonStrikerId;
                  nonStrikerBatsman.value = battingPlayers[1].playerName ?? "Player 2";
                  log('Auto-selected non-striker: ${nonStrikerBatsman.value} (ID: $actualNonStrikerId)');
                }
              }
            } catch (e) {
              log('Warning: Could not get default batting players: $e');
            }
          }
          
          if (actualBowlerId <= 0) {
            try {
              // Get first player from bowling team as default
              final choosePlayerRepo = ChoosePlayerRepo();
              final bowlingPlayers = await choosePlayerRepo.getPlayersByTeamId(_bowlingTeamId);
              if (bowlingPlayers != null && bowlingPlayers.isNotEmpty) {
                actualBowlerId = bowlingPlayers[0].teamPlayerId ?? 0;
                bowlerId.value = actualBowlerId;
                bowler.value = bowlingPlayers[0].playerName ?? "Bowler 1";
                log('Auto-selected bowler: ${bowler.value} (ID: $actualBowlerId)');
              }
            } catch (e) {
              log('Warning: Could not get default bowling player: $e');
            }
          }

          await _repo.shiftInning(
            matchId: matchId,
            nextBattingTeamId: _battingTeamId,
            strikerId: actualStrikerId,
            nonStrikerId: actualNonStrikerId,
            bowlerId: actualBowlerId,
          );

          log('Second inning started successfully');

          // Navigate to scoreboard
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offNamedUntil(
            NAV_SCOREBOARD,
            (route) => route.settings.name == NAV_DASHBOARD_PAGE,
            arguments: {'matchId': matchId},
          );
        } catch (e) {
          _showError("Failed to start inning: ${e.toString()}");
          log('Error starting inning: $e');
        } finally {
          isLoading.value = false;
        }
      },
      title: "Start Second Inning?",

      cancelText: "Cancel",
      confirmText: "Start",
    );
  }

  /// Reset all player selections
  void resetSelections() {
    strikerBatsmanId.value = 0;
    nonStrikerBatsmanId.value = 0;
    bowlerId.value = 0;
    strikerBatsman.value = "";
    nonStrikerBatsman.value = "";
    bowler.value = "";
  }

  /// Show error message to user
  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
