// lib/features/scoreboard/controller/scoreboard_controller_optimized.dart

import 'package:cric_live/utils/import_exports.dart';

class ScoreboardController extends GetxController with DebouncingMixin {
  final int matchId;
  final ScoreboardRepository _repo;

  ScoreboardController({required this.matchId, ScoreboardRepository? repo})
    : _repo = repo ?? ScoreboardRepository();

  //==========================================================================
  //region State Variables
  //==========================================================================
  late MatchModel matchModel;
  int wideRun = 0;
  int noBallRun = 0;

  // Match-level state
  final RxInt totalOvers = 0.obs;
  final RxInt inningNo = 1.obs;
  final RxInt totalRuns = 0.obs;
  final RxInt wickets = 0.obs;
  final RxDouble currentOvers = 0.0.obs;
  final RxDouble crr = 0.0.obs;
  final RxInt firstInningScore = 0.obs;

  // Team state
  final RxString team1 = "Team A".obs;
  final RxString team2 = "Team B".obs;
  final RxInt team1Id = 0.obs;
  final RxInt team2Id = 0.obs;
  final RxInt currentBattingTeamId = 0.obs;

  // Player state
  final RxString bowler = "".obs;
  final RxInt bowlerId = 0.obs;
  final RxString nonStrikerBatsman = "".obs;
  final RxInt nonStrikerBatsmanId = 0.obs;
  final RxString strikerBatsman = "".obs;
  final RxInt strikerBatsmanId = 0.obs;

  // Player statistics
  final RxMap<String, double> nonStrikerBatsmanState = <String, double>{}.obs;
  final RxMap<String, double> strikerBatsmanState = <String, double>{}.obs;
  final RxMap<String, double> bowlerState = <String, double>{}.obs;
  final RxMap<String, dynamic> oversState = <String, dynamic>{}.obs;

  // UI state
  final RxBool isWideSelected = false.obs;
  final RxBool isByeSelected = false.obs;
  final RxBool isNoBallSelected = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isWicketLoading = false.obs;
  final RxBool isMainButtonLoading = false.obs;
  final RxString errorMessage = "".obs;

  // Internal state
  final RxBool _justSelectedNewBowler = false.obs;
  final RxInt _bowlerSelectionRetryCount = 0.obs;
  final RxBool _teamWinDialogShown = false.obs;

  // Performance cache
  int? _cachedTeamSize;
  DateTime? _lastTeamSizeCheck;

  // Getters for UI state
  bool get isOverCompleted => _overCompleted.value;
  bool get isMatchCompleted => _matchCompleted.value;
  bool get userChoseStayAfterMatchEnd => _userChoseStayAfterMatchEnd.value;


  // Match completion tracking
  final RxBool _matchCompleted = false.obs;
  final RxBool _matchEndDialogShown = false.obs;
  final RxBool _userChoseStayAfterMatchEnd = false.obs;

  // Over completion tracking - shows button when over is completed
  final RxBool _overCompleted = false.obs;
  //endregion

  @override
  void onInit() {
    super.onInit();
    initializeMatch();
  }

  //==========================================================================
  //region Initialization
  //==========================================================================

  Future<void> initializeMatch() async {
    try {
      isLoading.value = true;
      matchModel = await _repo.findMatch(matchId);

      // Set match config
      totalOvers.value = matchModel.overs ?? 0;
      inningNo.value = matchModel.inningNo ?? 1;
      wideRun = matchModel.wideRun ?? 0;
      noBallRun = matchModel.noBallRun ?? 0;

      // Set team IDs and names
      team1Id.value = matchModel.team1 ?? 0;
      team2Id.value = matchModel.team2 ?? 0;
      currentBattingTeamId.value = matchModel.currentBattingTeamId ?? 0;
      team1.value = await _repo.getTeamName(team1Id.value);
      team2.value = await _repo.getTeamName(team2Id.value);

      // If it's the 2nd inning, fetch the target score
      if (inningNo.value == 2) {
        firstInningScore.value = await _repo.getFirstInningScore(matchId);
      }

      // Set player info with enhanced error handling and retry logic

      // Initialize player info with retry mechanism
      await _initializePlayerInfoWithRetry();

      // Update match status to live
      matchModel.status = 'live';
      await _repo.updateMatch(matchModel);

      _teamWinDialogShown.value = false;
      _overCompleted.value = false; // Reset over completion state
      await _refreshAllCalculations();

      // Force UI refresh for player names with explicit updates
      _forcePlayerNameRefresh();
    } catch (e) {
      errorMessage.value = "Failed to initialize match: ${e.toString()}";
      log('Error initializing ScoreboardController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// New method to initialize player info with retry mechanism
  Future<void> _initializePlayerInfoWithRetry() async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {

        // Set player IDs first (they should be available from the match model)
        strikerBatsmanId.value = matchModel.strikerBatsmanId ?? 0;
        nonStrikerBatsmanId.value = matchModel.nonStrikerBatsmanId ?? 0;
        bowlerId.value = matchModel.bowlerId ?? 0;

        // Clear any existing "Unknown Player" values
        strikerBatsman.value = "";
        nonStrikerBatsman.value = "";
        bowler.value = "";

        // Attempt to fetch player names sequentially to avoid race conditions
        await _setPlayerInfo(
          matchModel.strikerBatsmanId,
          strikerBatsman,
          strikerBatsmanId,
        );

        await _setPlayerInfo(
          matchModel.nonStrikerBatsmanId,
          nonStrikerBatsman,
          nonStrikerBatsmanId,
        );

        await _setPlayerInfo(matchModel.bowlerId, bowler, bowlerId);

        // Check if all names were successfully loaded
        bool allPlayersLoaded =
            strikerBatsman.value.isNotEmpty &&
            strikerBatsman.value != "Unknown Player" &&
            nonStrikerBatsman.value.isNotEmpty &&
            nonStrikerBatsman.value != "Unknown Player" &&
            bowler.value.isNotEmpty &&
            bowler.value != "Unknown Player";

        if (allPlayersLoaded) {
          return; // Success, exit retry loop
        }
      } catch (e) {
        log('❌ Error in player initialization attempt $attempt: $e');
      }

      // Wait before retrying (except on last attempt)
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay);
      }
    }

    // If we reach here, all retries failed
    log('⚠️ Player initialization completed after $maxRetries attempts');
  }

  /// Force refresh of player name UI elements
  void _forcePlayerNameRefresh() {
    // Force immediate UI updates
    strikerBatsman.refresh();
    nonStrikerBatsman.refresh();
    bowler.refresh();

    // Also refresh the IDs to ensure consistency
    strikerBatsmanId.refresh();
    nonStrikerBatsmanId.refresh();
    bowlerId.refresh();
  }


  Future<void> _setPlayerInfo(
    int? playerId,
    RxString nameRx,
    RxInt idRx,
  ) async {
    try {
      final playerRole =
          nameRx == strikerBatsman
              ? 'Striker'
              : nameRx == nonStrikerBatsman
              ? 'Non-Striker'
              : 'Bowler';

      // Always set the ID first
      idRx.value = playerId ?? 0;

      if (idRx.value > 0) {
        final playerName = await _repo.getPlayerName(idRx.value);

        // Ensure we got a valid name
        if (playerName.isNotEmpty && playerName != "Unknown Player") {
          nameRx.value = playerName;
        } else {
          log(
            '⚠️ $playerRole name fetch returned invalid result: "$playerName"',
          );
          nameRx.value = "Unknown Player";
        }

        // Force immediate UI update
        nameRx.refresh();
      } else {
        nameRx.value = "Unknown Player";
        nameRx.refresh();
      }
    } catch (e) {
      final playerRole =
          nameRx == strikerBatsman
              ? 'Striker'
              : nameRx == nonStrikerBatsman
              ? 'Non-Striker'
              : 'Bowler';
      log('❌ Error setting $playerRole info: $e');
      nameRx.value = "Unknown Player";
      nameRx.refresh();
    }
  }
  //endregion

  //==========================================================================
  //region Ball & Score Actions
  //==========================================================================

  Future<void> onTapRun({required int runs}) async {
    if (isDebouncing('onTapRun')) return;

    debounceTap('onTapRun', () async {
      // Block actions if match is completed and user chose to stay
      if (_matchCompleted.value && _userChoseStayAfterMatchEnd.value) {
        _showMatchCompletedMessage();
        return;
      }

      // Block actions if match is already completed
      if (_matchCompleted.value) {
        log('Match already completed - blocking run action');
        return;
      }

      if (await _isMatchActionBlocked()) return;

      // Prepare ball data
      int totalRunsForBall = runs;
      int? isWideLocal, isNoBallLocal, isByeLocal;
      log(
        '🧮 Pre-run: baseRuns=$runs, wideSelected=${isWideSelected.value}, noBallSelected=${isNoBallSelected.value}, byeSelected=${isByeSelected.value}, config(wide=$wideRun, nb=$noBallRun)',
      );

      if (isNoBallSelected.value) {
        totalRunsForBall += noBallRun;
        isNoBallLocal = 1;
      }
      if (isWideSelected.value) {
        totalRunsForBall += wideRun;
        isWideLocal = 1;
      }
      if (isByeSelected.value) {
        isByeLocal = 1;
      }

      final ballData = ScoreboardModel(
        totalOvers: totalOvers.value,
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        runs: totalRunsForBall,
        isWide: isWideLocal,
        isNoBall: isNoBallLocal,
        isBye: isByeLocal,
        currentOvers: currentOvers.value,
      );

      // Add ball entry and immediately update UI state
      await _repo.addBallEntry(ballData);
      
      // Reset new bowler flag after a legal ball is delivered (not wide/no-ball)
      if (_justSelectedNewBowler.value && isWideLocal != 1 && isNoBallLocal != 1) {
        _justSelectedNewBowler.value = false;
      }
      
      _resetExtraSelections();

      // Update critical values immediately for fast UI response
      _updateCriticalStatsImmediately(
        totalRunsForBall,
        isWideLocal,
        isNoBallLocal,
      );

      // Update batsman stats immediately (only for clean deliveries)
      if (isWideLocal != 1 && isNoBallLocal != 1 && isByeLocal != 1) {
        _updateBatsmanStatsImmediately(runs);
      }

      // Run full calculations in background
      unawaited(_refreshAllCalculationsOptimized());

      // Swap strike if needed
      if ([1, 3, 5].contains(runs) && isByeSelected.value == false) {
        onTapSwap();
      }

      // ===== COMPREHENSIVE INNING COMPLETION CHECKS =====

      // First: Check for match end conditions (must be awaited to prevent concurrent dialogs)
      await _checkInningCompletionAfterBall();

      // Second: Check winner in 2nd inning (only if match hasn't ended and dialog not shown)
      if (inningNo.value == 2 &&
          !_teamWinDialogShown.value &&
          !_matchCompleted.value) {
        await _checkSecondInningResult();
      }
    }, delay: const Duration(milliseconds: 50));
  }

  /// IMPROVED WICKET FLOW:
  /// 1. Show confirmation dialog first
  /// 2. Check if this is the final wicket (total players - 2 === current wickets)
  /// 3a. If final wicket: Record wicket and show completion/shift inning dialog directly
  /// 3b. If not final wicket: Show player selection, then record wicket
  /// 4. Show appropriate dialog based on match state
  Future<void> onTapWicket({required String wicketType}) async {
    if (isDebouncing('onTapWicket')) return;

    debounceTap('onTapWicket', () async {
      try {
        isWicketLoading.value = true;
        
        // Block actions if match is completed and user chose to stay
        if (_matchCompleted.value && _userChoseStayAfterMatchEnd.value) {
          _showMatchCompletedMessage();
          return;
        }

        if (await _isMatchActionBlocked()) return;

      final outPlayerId = strikerBatsmanId.value;
      final outPlayerName = strikerBatsman.value;
      final battingTeamId = currentBattingTeamId.value;

      // STEP 1: Show confirmation dialog first
      if (!await _showSimpleDialog(
        title: "Confirm Wicket",
        content: "$outPlayerName is out ($wicketType). Continue?",
        confirmText: "Confirm",
      )) {
        return;
      }

      // STEP 2: Check if this is the final wicket that will end the inning
      final totalPlayers = await _getCachedTeamSize(battingTeamId);
      final currentWickets = wickets.value;
      final isFinalWicket = (totalPlayers - 2) == currentWickets;

      if (isFinalWicket) {
        // FINAL WICKET PATH: Skip player selection, record wicket and show completion dialog
        await _handleFinalWicket(outPlayerId, outPlayerName, wicketType);
      } else {
        // REGULAR WICKET PATH: Show player selection then record wicket
        await _handleRegularWicket(outPlayerId, outPlayerName, wicketType);
      }
      } catch (e) {
        log('❌ Error in onTapWicket: $e');
      } finally {
        isWicketLoading.value = false;
      }
    }, delay: const Duration(milliseconds: 600));
  }

  /// Handle final wicket that will end the inning (no player selection needed)
  Future<void> _handleFinalWicket(
    int outPlayerId,
    String outPlayerName,
    String wicketType,
  ) async {
    try {

      // Record the wicket directly (no new player needed since inning ends)
      final ballData = ScoreboardModel(
        strikerBatsmanId: outPlayerId,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        isWicket: 1,
        wicketType: wicketType,
        currentOvers: currentOvers.value,
        totalOvers: totalOvers.value,
        runs: 0,
      );

      await _repo.addBallEntry(ballData);
      await _refreshAllCalculations();

      // FINAL WICKET STEP 2: Show completion dialog immediately
      _matchCompleted.value = true;

      if (inningNo.value == 1) {
        await _showAllOutDialog();
      } else {
        await _handleSecondInningAllOut();
      }
    } catch (e) {
      log('❌ Error in _handleFinalWicket: $e');
    }
  }

  /// Handle regular wicket that requires player selection
  Future<void> _handleRegularWicket(
    int outPlayerId,
    String outPlayerName,
    String wicketType,
  ) async {
    try {
      // REGULAR WICKET STEP 1: Show player selection dialog
      log('👤 REGULAR WICKET STEP 1: Showing player selection dialog');
      final newPlayer = await _selectNewPlayer();
      if (newPlayer == null) {
        log('❌ REGULAR WICKET: Player selection was cancelled');
        return;
      }
      log('✅ REGULAR WICKET STEP 1: Player selected - ${newPlayer.playerName}');

      // REGULAR WICKET STEP 2: Record the wicket and update match state
      log(
        '💾 REGULAR WICKET STEP 2: Recording wicket and updating match state',
      );
      final ballData = ScoreboardModel(
        strikerBatsmanId: outPlayerId,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        isWicket: 1,
        wicketType: wicketType,
        currentOvers: currentOvers.value,
        totalOvers: totalOvers.value,
        runs: 0,
      );

      await _repo.addBallEntry(ballData);

      // Update striker to new player
      strikerBatsman.value = newPlayer.playerName ?? "Unknown";
      strikerBatsmanId.value = newPlayer.teamPlayerId ?? 0;

      // Update match state
      matchModel.strikerBatsmanId = strikerBatsmanId.value;
      await _repo.updateMatch(matchModel);

      await _refreshAllCalculations();

      log(
        '✅ REGULAR WICKET STEP 2: Wicket recorded - $outPlayerName is out, ${newPlayer.playerName} is now batting',
      );

      // REGULAR WICKET STEP 3: Check for any other match completion conditions
      log('🔍 REGULAR WICKET STEP 3: Checking for other completion conditions');
      await _checkWicketInningCompletionAndShowDialog();
    } catch (e) {
      log('❌ Error in _handleRegularWicket: $e');
    }
  }

  Future<void> undoBall() async {
    if (isDebouncing('undoBall')) return;

    debounceTap('undoBall', () async {
      try {
        final currentBowlerId = bowlerId.value;
        final currentBowlerName = bowler.value;
        final currentLegalBalls = await getCurrentOverBallCount();

        ScoreboardModel? lastEntry = await _repo.undoBall();

        // Reset win dialog flag, match completion, and over completion when undoing - allows dialog to show again if team wins
        _teamWinDialogShown.value = false;
        _matchCompleted.value = false;
        _matchEndDialogShown.value = false;
        _userChoseStayAfterMatchEnd.value = false;
        _overCompleted.value = false;

        await _refreshAllCalculations();

        log('🔄 After undo - checking if inning completion status changed');
        // Check if undo changed inning completion status
        await _checkInningCompletionAfterBall();

        if (lastEntry != null) {
          final restoredBowlerId = lastEntry.bowlerId ?? 0;
          final bowlerChanged = restoredBowlerId != currentBowlerId;

          if (bowlerChanged && currentLegalBalls <= 1) {
            final shouldRestore = await _showSimpleDialog(
              title: "Restore Previous Over?",
              content:
                  "Undo went back to previous over. Restore $currentBowlerName → ${await _repo.getPlayerName(restoredBowlerId)}?",
              confirmText: "Restore",
            );

            if (shouldRestore) {
              await _restorePreviousOverState(lastEntry);
            } else {
              await _setPlayerInfo(
                lastEntry.strikerBatsmanId,
                strikerBatsman,
                strikerBatsmanId,
              );
              await _setPlayerInfo(
                lastEntry.nonStrikerBatsmanId,
                nonStrikerBatsman,
                nonStrikerBatsmanId,
              );
              log(
                'Undo complete: Previous ball undone. Current bowler ($currentBowlerName) maintained.',
              );
            }
          } else {
            log('🔄 Restoring player info after undo (no over change)');
            await _setPlayerInfo(
              lastEntry.strikerBatsmanId,
              strikerBatsman,
              strikerBatsmanId,
            );
            await _setPlayerInfo(
              lastEntry.nonStrikerBatsmanId,
              nonStrikerBatsman,
              nonStrikerBatsmanId,
            );
            await _setPlayerInfo(lastEntry.bowlerId, bowler, bowlerId);
            log(
              '✅ Player info restored after undo - Striker: "${strikerBatsman.value}", Non-Striker: "${nonStrikerBatsman.value}", Bowler: "${bowler.value}"',
            );
          }
        }
      } catch (e) {
        log('Error in undoBall: $e');
      }
    }, delay: const Duration(milliseconds: 400));
  }

  void onTapSwap() {
    if (isDebouncing('onTapSwap')) return;

    // Block actions if match is completed and user chose to stay
    if (_matchCompleted.value && _userChoseStayAfterMatchEnd.value) {
      _showMatchCompletedMessage();
      return;
    }

    debounceTap('onTapSwap', () {
      final tempName = strikerBatsman.value;
      strikerBatsman.value = nonStrikerBatsman.value;
      nonStrikerBatsman.value = tempName;

      final tempId = strikerBatsmanId.value;
      strikerBatsmanId.value = nonStrikerBatsmanId.value;
      nonStrikerBatsmanId.value = tempId;

      // Swap batsman stats immediately
      final tempStats = Map<String, double>.from(strikerBatsmanState);
      strikerBatsmanState.value = Map<String, double>.from(
        nonStrikerBatsmanState,
      );
      nonStrikerBatsmanState.value = tempStats;

      // Update full stats in background
      unawaited(calculateBatsman());
    }, delay: const Duration(milliseconds: 100));
  }

  void _resetExtraSelections() {
    isWideSelected.value = false;
    isNoBallSelected.value = false;
    isByeSelected.value = false;
  }
  //endregion

  //==========================================================================
  //region Inning & Match Flow
  //==========================================================================

  Future<bool> _isCurrentInningFinished() async {
    bool oversFinished =
        (await _repo.calculateCurrentOvers(matchId, inningNo.value)) >=
        totalOvers.value;
    final battingTeamId = currentBattingTeamId.value;
    // Check if inning is finished: total number of players - 1 wickets have happened
    final requiredWickets = await _getRequiredWicketsForMatchEnd(battingTeamId);
    bool allOut = wickets.value >= requiredWickets;

    log(
      '🔍 _isCurrentInningFinished check: ${wickets.value} wickets >= $requiredWickets required = $allOut',
    );
    return oversFinished || allOut;
  }

  Future<void> onTapMainButton() async {
    // Delegate to the new onTapEndMatch method for consistent behavior
    await onTapEndMatch();
  }

  Future<void> _endMatchAndNavigate() async {
    try {
      await _repo.endMatch(matchId);
      Get.offNamed(NAV_RESULT, arguments: {'matchId': matchId});
    } catch (e) {
      log('Error in _endMatchAndNavigate: $e');
    }
  }

  Future<bool> _isMatchActionBlocked() async {
    log('🚫 MATCH ACTION BLOCKED CHECK: Current wickets = ${wickets.value}');

    // Quick check without expensive database calls
    if (_isInningFinishedQuickCheck()) {
      log('🚨 MATCH ACTION BLOCKED: Quick check triggered onTapMainButton()');
      onTapMainButton();
      return true;
    }

    if (await _isOverCompleted()) {
      _overCompleted.value = true;
      log('Over completed - showing new bowler button');
      _showOverCompletedMessage();
      return true;
    }

    return false;
  }

  /// Shows a brief message when user tries to act during over completion
  void _showOverCompletedMessage() {
    Get.snackbar(
      'Over Completed',
      'Please select a new bowler to continue',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.sports_cricket, color: Colors.orange),
    );
  }

  /// Shows a message when user tries to act after match completion
  void _showMatchCompletedMessage() {
    Get.snackbar(
      'Match Completed',
      'This match has ended. Only undo is allowed. Use undo to continue scoring if needed.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.block, color: Colors.red),
    );
  }

  // Quick check using cached values instead of database queries
  bool _isInningFinishedQuickCheck() {
    // Check if already marked as completed
    if (_matchCompleted.value) {
      log('✅ Quick check: Match already marked as completed');
      return true;
    }

    // Check if overs are completed using cached value (allow small tolerance for floating point)
    bool oversFinished = currentOvers.value >= (totalOvers.value - 0.05);

    // Disable wicket logic in quick check - let comprehensive check handle all wicket logic
    // This prevents premature triggering with incorrect player counts
    bool possibleAllOut =
        false; // Quick check disabled for wickets - comprehensive check will handle

    if (oversFinished) {
      log(
        '⚡ Quick check: Overs possibly finished - ${currentOvers.value}/${totalOvers.value}',
      );
    }
    if (possibleAllOut) {
      log('⚡ Quick check: Possibly all out - ${wickets.value} wickets');
    }

    bool finished = oversFinished || possibleAllOut;
    log(
      '🎯 Quick inning finish check: ${finished ? "FINISHED" : "CONTINUING"} (Overs: ${currentOvers.value}/${totalOvers.value}, Wickets: ${wickets.value})',
    );

    return finished;
  }

  Future<PlayerModel?> _selectNewPlayer() async {
    try {
      List<int> currentlyPlayingIds = [
        strikerBatsmanId.value,
        nonStrikerBatsmanId.value,
      ];
      final choosePlayerRepo = ChoosePlayerRepo();
      List<int> outPlayerIds = await choosePlayerRepo.getOutPlayerIds(
        matchId: matchId,
        inningNo: inningNo.value,
      );

      Set<int> allHiddenIds = {...currentlyPlayingIds, ...outPlayerIds};

      final result = await Get.toNamed(
        NAV_CHOOSE_PLAYER,
        arguments: {
          'teamId': currentBattingTeamId.value,
          'limit': 1,
          'hiddenPlayerIds': allHiddenIds.toList(),
        },
      );

      if (result != null && result is List && result.isNotEmpty) {
        return result.cast<PlayerModel>().first;
      }
      return null;
    } catch (e) {
      log('Error in _selectNewPlayer: $e');
      return null;
    }
  }

  Future<bool> _isOverCompleted() async {
    if (_justSelectedNewBowler.value) return false;

    final sessionComplete = await _repo.isCurrentSessionOverComplete(
      matchId: matchId,
      inningNo: inningNo.value,
      bowlerId: bowlerId.value,
    );

    return sessionComplete;
  }

  Future<int> getCurrentOverBallCount() async {
    return await _repo.getCurrentSessionBallCount(
      matchId: matchId,
      inningNo: inningNo.value,
      bowlerId: bowlerId.value,
    );
  }

  Future<void> _promptNewBowlerSelection() async {
    log('Over complete - showing new bowler selection UI');
    // This method is now mainly for legacy support
    // The main UI interaction is through onTapSelectNewBowler()
    _overCompleted.value = true;
  }

  /// Public method to be called from UI button
  Future<void> onTapSelectNewBowler() async {
    if (isDebouncing('selectNewBowler')) {
      log('Bowler selection already in progress - ignoring tap');
      return;
    }

    debounceTap('selectNewBowler', () async {
      log('User tapped select new bowler button');
      await _selectNewBowler();
    }, delay: const Duration(milliseconds: 300));
  }

  Future<void> _selectNewBowler() async {
    try {
      final bowlingTeamId =
          currentBattingTeamId.value == team1Id.value
              ? team2Id.value
              : team1Id.value;
      final hiddenPlayerIds = [bowlerId.value];

      final result = await Get.toNamed(
        NAV_CHOOSE_PLAYER,
        arguments: {
          'teamId': bowlingTeamId,
          'limit': 1,
          'hiddenPlayerIds': hiddenPlayerIds,
        },
      );

      if (result != null && result is List && result.isNotEmpty) {
        final newBowler = result.cast<PlayerModel>().first;

        bowler.value = newBowler.playerName ?? "Unknown";
        bowlerId.value = newBowler.teamPlayerId ?? 0;

        matchModel.bowlerId = bowlerId.value;
        await _repo.updateMatch(matchModel);

        await _resetBowlerStateForNewOver();
        _justSelectedNewBowler.value = true;
        _bowlerSelectionRetryCount.value = 0;
        _overCompleted.value = false; // Reset over completion state

        onTapSwap();

        await _refreshCalculationsExceptBowler();

        log('New bowler selected: ${newBowler.playerName} is now bowling.');
      } else {
        // User cancelled selection - don't retry automatically
        log('Bowler selection cancelled by user');
        _bowlerSelectionRetryCount.value = 0;

        // Show a message to the user
        Get.snackbar(
          'Selection Required',
          'Please select a new bowler to continue the match',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.sports_cricket, color: Colors.orange),
        );

        // Keep the over completion state so the button remains visible
        // User can tap again when ready
      }
    } catch (e) {
      log('Error selecting new bowler: $e');
    }
  }

  Future<void> _checkSecondInningResult() async {
    final currentScore = totalRuns.value;
    final targetScore = firstInningScore.value;

    log(
      '🎯 Checking 2nd inning result: currentScore=$currentScore, targetScore=$targetScore, teamWinDialogShown=${_teamWinDialogShown.value}',
    );

    // If score dropped below target (e.g., after undo), reset win dialog flag
    if (currentScore <= targetScore && _teamWinDialogShown.value) {
      _teamWinDialogShown.value = false;
      log(
        'Score dropped to $currentScore (target: $targetScore) - reset win dialog flag',
      );
    }

    // Only check if dialog hasn't been shown for current winning state
    if (currentScore > targetScore && !_teamWinDialogShown.value) {
      // Team beats the target score - they win!
      log('🏆 Team WIN detected: $currentScore > $targetScore');
      _teamWinDialogShown.value = true;
      await _handleTeamWinResult();
    }
    // NOTE: We DON'T check for ties here during regular play!
    // Ties are ONLY checked when match ends (all out or overs complete)
  }

  Future<void> _showTieDialog() async {
    // Automatically end match and set up tie result
    await _calculateAndSetMatchResult(); // This will set result as "Match tied"
    await _repo.endMatch(matchId);

    // Set match completed state
    _matchCompleted.value = true;

    // Show match end dialog if not already shown
    if (!_matchEndDialogShown.value) {
      _matchEndDialogShown.value = true;
      await _showMatchEndDialog();
    }

    log('Match ended - declared as a tie: ${matchModel.result}');
  }

  Future<void> _showAllOutDialog() async {
    final battingTeamName =
        currentBattingTeamId.value == team1Id.value ? team1.value : team2.value;
    final isFirstInning = inningNo.value == 1;

    // For 2nd inning, check for tie before showing dialog
    if (!isFirstInning) {
      final currentScore = totalRuns.value;
      final targetScore = firstInningScore.value;

      if (currentScore == targetScore && !_teamWinDialogShown.value) {
        // Tie scenario - team all out with same score
        log('🤝 Tie detected: Team all out with same score ($currentScore)');
        _teamWinDialogShown.value = true;
        _matchCompleted.value = true;
        await _showTieDialog();
        return;
      }
    }

    final actionText = isFirstInning ? "Start Second Inning" : "End Match";

    final result = await _showSimpleDialog(
      title: "All Out!",
      content:
          "$battingTeamName is all out with ${wickets.value} wickets down.\n\nTotal Runs: ${totalRuns.value}\nOvers: ${currentOvers.value.toStringAsFixed(1)}",
      confirmText: actionText,
    );

    if (result) {
      await _handleAllOutAction(isFirstInning);
    }
  }

  Future<void> _handleAllOutAction(bool isFirstInning) async {
    try {
      isLoading.value = true;
      if (isFirstInning) {
        await _handleFirstInningEnd();
      } else {
        await _handleMatchEnd();
      }
    } catch (e) {
      log('Error in _handleAllOutAction: $e');
    } finally {
      isLoading.value = false;
    }
  }


  /// Comprehensive inning completion check that runs after every ball/wicket
  Future<void> _checkInningCompletionAfterBall() async {
    try {
      // Prevent multiple simultaneous checks
      if (_matchCompleted.value) {
        log('⚠️ Match already completed - skipping inning completion check');
        return;
      }

      // Get accurate data from database to avoid cached inconsistencies
      final actualCurrentOvers = await _repo.calculateCurrentOvers(
        matchId,
        inningNo.value,
      );
      final actualWickets = await _repo.calculateWicket(
        matchId,
        inningNo.value,
      );
      final battingTeamId = currentBattingTeamId.value;
      log('🔍 COMPREHENSIVE CHECK: Starting for team $battingTeamId');

      final totalPlayers = await _getCachedTeamSize(battingTeamId);
      log('🔢 TEAM SIZE RESULT: Team $battingTeamId has $totalPlayers players');

      // Show tie and win dialog only when total number of players - 1 wickets have happened
      final requiredWickets = await _getRequiredWicketsForMatchEnd(
        battingTeamId,
      );
      log(
        '🎯 WICKET CALCULATION: Team $battingTeamId needs $requiredWickets wickets (${totalPlayers} players - 1)',
      );

      // Update UI with accurate values
      currentOvers.value = actualCurrentOvers;
      wickets.value = actualWickets;

      log('📊 Inning status check:');
      log('  - Overs: $actualCurrentOvers / ${totalOvers.value}');
      log(
        '  - Wickets: $actualWickets / $requiredWickets (total players: $totalPlayers, required = players - 1)',
      );
      log('  - Inning: ${inningNo.value}');
      log(
        '  - Match end condition: Wickets >= $requiredWickets OR Overs >= ${totalOvers.value}',
      );
      log(
        '  - Team $battingTeamId has exactly $totalPlayers players in database',
      );

      // Check completion conditions
      bool oversCompleted = actualCurrentOvers >= (totalOvers.value - 0.001);
      bool allOut = actualWickets >= requiredWickets;

      if (oversCompleted) {
        log('✅ Overs completed: $actualCurrentOvers >= ${totalOvers.value}');
        _matchCompleted.value = true;
        if (inningNo.value == 1) {
          await _showInningCompleteDialog();
        } else {
          // Check for tie when overs are completed in 2nd inning
          final currentScore = totalRuns.value;
          final targetScore = firstInningScore.value;

          log(
            '🎯 OVERS COMPLETED - Checking result: currentScore=$currentScore, targetScore=$targetScore, teamWinDialogShown=${_teamWinDialogShown.value}',
          );

          if (currentScore == targetScore && !_teamWinDialogShown.value) {
            // Tie scenario - overs completed with same score
            log(
              '🤝 TIE detected: Overs completed with same score ($currentScore)',
            );
            _teamWinDialogShown.value = true;
            await _showTieDialog();
          } else {
            // Regular win/loss scenario
            log(
              '🏅 WIN/LOSS scenario: currentScore=$currentScore, targetScore=$targetScore',
            );
            if (!_matchEndDialogShown.value) {
              _matchEndDialogShown.value = true;
              await _calculateAndSetMatchResult();
              await _repo.endMatch(matchId);
              await _showMatchEndDialog();
            }
          }
        }
        return;
      }

      if (allOut) {
        log('🚨 DIALOG TRIGGER - All out condition met!');
        log('✅ All out: $actualWickets >= $requiredWickets wickets');
        log(
          '📊 Debug: Team $battingTeamId - Players: $totalPlayers, Required: $requiredWickets, Actual: $actualWickets',
        );
        _matchCompleted.value = true;
        if (inningNo.value == 2) {
          // Check for tie when team is all out in 2nd inning
          final currentScore = totalRuns.value;
          final targetScore = firstInningScore.value;

          log(
            '🎯 ALL OUT - Checking result: currentScore=$currentScore, targetScore=$targetScore, teamWinDialogShown=${_teamWinDialogShown.value}',
          );

          if (currentScore == targetScore && !_teamWinDialogShown.value) {
            // Tie scenario - team all out with same score
            log(
              '🤝 TIE detected: Team all out with same score ($currentScore)',
            );
            _teamWinDialogShown.value = true;
            await _showTieDialog();
          } else {
            // Regular win/loss scenario
            log(
              '🏅 WIN/LOSS scenario: currentScore=$currentScore, targetScore=$targetScore',
            );
            if (!_matchEndDialogShown.value) {
              _matchEndDialogShown.value = true;
              await _calculateAndSetMatchResult();
              await _repo.endMatch(matchId);
              await _showMatchEndDialog();
            }
          }
        } else {
          await _showAllOutDialog();
        }
        return;
      }

      log('ℹ️ Inning continues - not completed yet');
    } catch (e) {
      log('❌ Error checking inning completion: $e');
    }
  }


  Future<void> _showInningCompleteDialog() async {
    final battingTeamName =
        currentBattingTeamId.value == team1Id.value ? team1.value : team2.value;

    final result = await _showSimpleDialog(
      title: "Inning Complete!",
      content:
          "$battingTeamName completed ${totalOvers.value} overs.\n\nTotal Runs: ${totalRuns.value}\nWickets: ${wickets.value}",
      confirmText: "Start Second Inning",
    );

    if (result) {
      await _handleFirstInningEnd();
    }
  }

  Future<void> _showMatchCompleteDialog() async {
    final battingTeamName =
        currentBattingTeamId.value == team1Id.value ? team1.value : team2.value;

    final result = await _showSimpleDialog(
      title: "Match Complete!",
      content:
          "$battingTeamName completed ${totalOvers.value} overs.\n\nFinal Score: ${totalRuns.value}/${wickets.value}",
      confirmText: "End Match",
    );

    if (result) {
      await _handleMatchEnd();
    }
  }

  // Cached team size to avoid repeated database calls
  // Uses precise database COUNT query to determine exact number of players
  Future<int> _getCachedTeamSize(int teamId) async {
    final now = DateTime.now();

    // Use cache if available and not expired (5 minutes)
    if (_cachedTeamSize != null &&
        _lastTeamSizeCheck != null &&
        now.difference(_lastTeamSizeCheck!).inMinutes < 5) {
      log(
        '📋 Using cached team size for team $teamId: $_cachedTeamSize players',
      );
      return _cachedTeamSize!;
    }

    // Fetch actual player count from database using COUNT query
    log('🔍 Querying database for actual player count of team $teamId');
    _cachedTeamSize = await _repo.getTeamSize(teamId);
    _lastTeamSizeCheck = now;

    log(
      '🎯 Team $teamId player count confirmed: $_cachedTeamSize (wickets needed for match end: ${_cachedTeamSize! - 1})',
    );
    return _cachedTeamSize!;
  }

  /// Get required wickets for match end condition: total team players - 1
  /// This is the core logic for showing tie and win dialogs
  Future<int> _getRequiredWicketsForMatchEnd(int teamId) async {
    final totalPlayers = await _getCachedTeamSize(teamId);
    final requiredWickets = (totalPlayers - 1).clamp(1, 10);

    log(
      '🎯 Match end condition for team $teamId: $requiredWickets wickets required (total players: $totalPlayers)',
    );

    return requiredWickets;
  }


  /// Specialized method to check inning completion after wicket and show appropriate dialogs
  /// This method is called after confirmation and player selection are complete
  Future<void> _checkWicketInningCompletionAndShowDialog() async {
    try {
      log(
        '🎯 WICKET COMPLETION CHECK: Starting after player selection complete',
      );

      // Get accurate data from database
      final actualCurrentOvers = await _repo.calculateCurrentOvers(
        matchId,
        inningNo.value,
      );
      final actualWickets = await _repo.calculateWicket(
        matchId,
        inningNo.value,
      );
      final battingTeamId = currentBattingTeamId.value;

      // Update UI with accurate values
      currentOvers.value = actualCurrentOvers;
      wickets.value = actualWickets;

      // Get team size and required wickets
      final totalPlayers = await _getCachedTeamSize(battingTeamId);
      final requiredWickets = await _getRequiredWicketsForMatchEnd(
        battingTeamId,
      );

      log(
        '📊 WICKET COMPLETION: Overs: $actualCurrentOvers/${totalOvers.value}, Wickets: $actualWickets/$requiredWickets',
      );
      log(
        '🎯 WICKET COMPLETION: Team $battingTeamId has $totalPlayers players, needs $requiredWickets wickets',
      );

      // Check completion conditions
      bool oversCompleted = actualCurrentOvers >= (totalOvers.value - 0.001);
      bool allOut = actualWickets >= requiredWickets;

      if (oversCompleted) {
        log('⏰ WICKET COMPLETION: Overs completed - handling inning end');
        _matchCompleted.value = true;
        if (inningNo.value == 1) {
          await _showInningCompleteDialog();
        } else {
          await _handleSecondInningOversComplete();
        }
        return;
      }

      if (allOut) {
        log('🏏 WICKET COMPLETION: All out condition met - handling all out');
        _matchCompleted.value = true;
        if (inningNo.value == 1) {
          log(
            '📋 WICKET COMPLETION: First inning all out - showing next inning dialog',
          );
          await _showAllOutDialog();
        } else {
          log(
            '🏆 WICKET COMPLETION: Second inning all out - showing match result',
          );
          await _handleSecondInningAllOut();
        }
        return;
      }

      // Check for win in 2nd inning (only if team surpassed target)
      if (inningNo.value == 2 && !_teamWinDialogShown.value) {
        final currentScore = totalRuns.value;
        final targetScore = firstInningScore.value;

        if (currentScore > targetScore) {
          log('🏆 WICKET COMPLETION: Team won by surpassing target');
          _teamWinDialogShown.value = true;
          await _handleTeamWinResult();
          return;
        }
      }

      log(
        '▶️ WICKET COMPLETION: Match continues - no inning end condition met',
      );
    } catch (e) {
      log('❌ Error in _checkWicketInningCompletionAndShowDialog: $e');
    }
  }

  /// Handle second inning when overs are completed
  Future<void> _handleSecondInningOversComplete() async {
    final currentScore = totalRuns.value;
    final targetScore = firstInningScore.value;

    log(
      '⏰ 2nd inning overs complete - currentScore: $currentScore, targetScore: $targetScore',
    );

    if (currentScore == targetScore && !_teamWinDialogShown.value) {
      // Tie scenario
      log('🤝 OVERS COMPLETE: Match tied ($currentScore each)');
      _teamWinDialogShown.value = true;
      await _showTieDialog();
    } else {
      // Win/loss scenario
      log('🏆 OVERS COMPLETE: Showing match end dialog');
      if (!_matchEndDialogShown.value) {
        _matchEndDialogShown.value = true;
        await _calculateAndSetMatchResult();
        await _repo.endMatch(matchId);
        await _showMatchEndDialog();
      }
    }
  }

  /// Handle second inning when team is all out
  Future<void> _handleSecondInningAllOut() async {
    final currentScore = totalRuns.value;
    final targetScore = firstInningScore.value;

    log(
      '🏏 2nd inning all out - currentScore: $currentScore, targetScore: $targetScore',
    );

    if (currentScore == targetScore && !_teamWinDialogShown.value) {
      // Tie scenario
      log('🤝 ALL OUT: Match tied ($currentScore each)');
      _teamWinDialogShown.value = true;
      await _showTieDialog();
    } else {
      // Win/loss scenario
      log('🏆 ALL OUT: Showing match end dialog');
      if (!_matchEndDialogShown.value) {
        _matchEndDialogShown.value = true;
        await _calculateAndSetMatchResult();
        await _repo.endMatch(matchId);
        await _showMatchEndDialog();
      }
    }
  }
  //endregion

  //==========================================================================
  //region Calculations & UI Refresh
  //==========================================================================

  Future<void> _refreshAllCalculations() async {
    await Future.wait([
      calculateRuns(),
      calculateWicket(),
      calculateCurrentOvers(),
      calculateCRR(),
      calculateBatsman(),
      calculateBowler(),
      calculateOversState(),
    ]);
  }

  // Optimized refresh for better performance
  Future<void> _refreshAllCalculationsOptimized() async {
    try {
      // Group calculations by priority
      await Future.wait([
        // High priority - visible stats
        calculateRuns(),
        calculateCurrentOvers(),
        calculateCRR(),
        calculateWicket(),
      ]);

      // Medium priority - player stats (can be slightly delayed)
      unawaited(calculateBatsman());
      unawaited(calculateBowler());
      unawaited(calculateOversState());
    } catch (e) {
      log('Error in optimized calculations: $e');
      // Fallback to full calculations if optimized fails
      await _refreshAllCalculations();
    }
  }

  // Immediately update critical stats without database queries
  void _updateCriticalStatsImmediately(int runs, int? isWide, int? isNoBall) {
    // Update total runs immediately
    totalRuns.value += runs;

    // Update overs count immediately (only for legal deliveries)
    if (isWide != 1 && isNoBall != 1) {
      double currentOversValue = currentOvers.value;
      double ballsInOver = (currentOversValue % 1) * 10;

      // Only increment if we haven't reached the total overs yet
      if (currentOversValue < totalOvers.value) {
        if (ballsInOver >= 5) {
          // Complete over - move to next over
          currentOvers.value = (currentOversValue.floor() + 1).toDouble();
        } else {
          // Add one more ball to current over
          currentOvers.value = currentOversValue + 0.1;
        }
      }
    }

    // Update CRR immediately (approximate)
    if (currentOvers.value > 0) {
      crr.value = totalRuns.value / currentOvers.value;
    }
  }

  Future<void> _refreshCalculationsExceptBowler() async {
    await Future.wait([
      calculateRuns(),
      calculateWicket(),
      calculateCurrentOvers(),
      calculateCRR(),
      calculateBatsman(),
    ]);
  }

  Future<void> calculateRuns() async {
    totalRuns.value = await _repo.calculateRuns(matchId, inningNo.value);
  }

  Future<void> calculateWicket() async {
    wickets.value = await _repo.calculateWicket(matchId, inningNo.value);
  }

  Future<void> calculateCurrentOvers() async {
    currentOvers.value = await _repo.calculateCurrentOvers(
      matchId,
      inningNo.value,
    );
  }

  Future<void> calculateCRR() async {
    crr.value = await _repo.calculateCRR(matchId, inningNo.value);
  }

  Future<void> calculateBatsman() async {
    final futures = [
      _repo.calculateBatsman(strikerBatsmanId.value, matchId),
      _repo.calculateBatsman(nonStrikerBatsmanId.value, matchId),
    ];

    final results = await Future.wait(futures);
    strikerBatsmanState.value = results[0];
    nonStrikerBatsmanState.value = results[1];
  }

  // Immediately update batsman stats without database query
  void _updateBatsmanStatsImmediately(int runs) {
    // Update striker batsman runs
    final currentStats = Map<String, double>.from(strikerBatsmanState);
    currentStats['runs'] = (currentStats['runs'] ?? 0) + runs;
    currentStats['balls'] = (currentStats['balls'] ?? 0) + 1;

    // Update boundaries
    if (runs == 4) {
      currentStats['fours'] = (currentStats['fours'] ?? 0) + 1;
    } else if (runs == 6) {
      currentStats['sixes'] = (currentStats['sixes'] ?? 0) + 1;
    }

    strikerBatsmanState.value = currentStats;
  }

  Future<void> calculateBowler() async {
    try {
      if (bowlerId.value == 0) {
        bowlerState.value = _getEmptyBowlerState();
        return;
      }

      final result = await _repo.calculateBowler(
        bowlerId: bowlerId.value,
        matchId: matchId,
        inningNo: inningNo.value,
        noBallRun: noBallRun,
        wideRun: wideRun,
      );

      bowlerState.value = result;
    } catch (e) {
      log('Error in calculateBowler: $e');
      bowlerState.value = _getEmptyBowlerState();
    }
  }

  Future<void> _resetBowlerStateForNewOver() async {
    bowlerState.value = _getEmptyBowlerState();
    oversState.value = {
      'ballSequence': [],
      'overDisplay': '',
      'legalBallsCount': 0,
      'isOverComplete': false,
      'runsInOver': 0,
      'wicketsInOver': 0,
      'remainingBalls': 6,
    };
  }

  Map<String, double> _getEmptyBowlerState() {
    return {
      'overs': 0.0,
      'maidens': 0.0,
      'runs': 0.0,
      'wickets': 0.0,
      'ER': 0.0,
    };
  }

  Future<void> calculateOversState() async {
    final sessionOverState = await _repo.getCurrentSessionOverState(
      matchId: matchId,
      inningNo: inningNo.value,
      bowlerId: bowlerId.value,
    );
    oversState.value = sessionOverState;
  }
  //endregion

  //==========================================================================
  //region Match Management
  //==========================================================================

  Future<void> resumeMatch() async {
    try {
      isLoading.value = true;
      matchModel.status = 'resume';
      await _repo.updateMatch(matchModel);
      await _refreshAllCalculations();
      Get.back();
    } catch (e) {
      errorMessage.value = "Failed to resume match: ${e.toString()}";
      _showSnackbar(
        "Error",
        "Failed to resume match. Please try again.",
        Colors.red,
      );
      log('Error in resumeMatch: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Main method to handle end match button click
  /// Shows result dialog if match is naturally completed,
  /// otherwise shows manual end match confirmation dialog
  Future<void> onTapEndMatch() async {
    log('🔘 onTapEndMatch called - starting end match process');
    try {
      isMainButtonLoading.value = true;
      log('⏳ Main button loading state set to true');

      // Reset the dialog flag to ensure dialog can be shown
      _matchEndDialogShown.value = false;
      log('🔄 Reset dialog flag to allow new dialog display');

      // Check if match is naturally completed
      log('🔍 Checking if match is naturally completed...');
      final isNaturallyCompleted = await _isMatchNaturallyCompleted();
      log('📊 Match naturally completed: $isNaturallyCompleted');

      if (isNaturallyCompleted) {
        // Match completed naturally - show result dialog
        log('✅ Match naturally completed - showing result dialog');
        await _handleNaturalMatchCompletion();
        log('✅ Natural match completion handled');
      } else {
        // Match being ended manually - show confirmation dialog
        log('⚠️ Match being ended manually - showing confirmation dialog');
        await _handleManualMatchEnd();
        log('✅ Manual match end handled');
      }
    } catch (e, stackTrace) {
      log('❌ Error in onTapEndMatch: $e');
      log('📍 Stack trace: $stackTrace');
      _showSnackbar(
        "Error",
        "Failed to process match end. Please try again.",
        Colors.red,
      );
    } finally {
      isMainButtonLoading.value = false;
      log('⏳ Main button loading state set to false');
      log('🔚 onTapEndMatch completed');
    }
  }

  Future<void> endMatchFromDialog() async {
    try {
      isLoading.value = true;
      final shouldEnd = await _showSimpleDialog(
        title: "End Match?",
        content:
            "Are you sure you want to end this match? This action cannot be undone.",
        confirmText: "End Match",
      );

      if (shouldEnd) {
        await _endMatchAndNavigate();
      }
    } catch (e) {
      errorMessage.value = "Failed to end match: ${e.toString()}";
      _showSnackbar(
        "Error",
        "Failed to end match. Please try again.",
        Colors.red,
      );
      log('Error in endMatchFromDialog: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _showEndMatchConfirmationDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "End Match?",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Are you sure you want to end this match without completing the 2nd inning?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This action cannot be undone. The match result will be calculated based on current scores.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Current Score: ${totalRuns.value}/${wickets.value} (${currentOvers.value}/${totalOvers.value} overs)",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stop_circle, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "End Match",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  /// Show network required dialog
  Future<bool> _showNetworkRequiredDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Network Required",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "An active internet connection is required to end the match without completing the 2nd inning.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Please check your Wi-Fi or mobile data connection and try again.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "Retry",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  /// Check if match is naturally completed
  /// Returns true if match should end naturally, false if being ended manually
  Future<bool> _isMatchNaturallyCompleted() async {
    // Check if we're in the first inning
    if (inningNo.value == 1) {
      // First inning can only be naturally completed if all overs done or all out
      return await _isCurrentInningFinished();
    }

    // We're in second inning - check various completion conditions
    final inningFinished = await _isCurrentInningFinished();

    // Check if target has been achieved
    final targetAchieved = totalRuns.value > firstInningScore.value;

    log(
      '🎯 Match completion check: Inning finished: $inningFinished, Target achieved: $targetAchieved',
    );

    // Match is naturally completed if:
    // 1. Second inning is finished (overs complete or all out), OR
    // 2. Target has been achieved
    return inningFinished || targetAchieved;
  }

  /// Handle natural match completion - calculate result and show result dialog
  Future<void> _handleNaturalMatchCompletion() async {
    try {
      // Complete the match naturally
      if (inningNo.value == 1) {
        await _handleFirstInningEnd();
      } else {
        await _handleMatchEnd();
      }
    } catch (e) {
      log('Error in _handleNaturalMatchCompletion: $e');
      rethrow;
    }
  }

  /// Handle manual match end - show confirmation dialog and end if confirmed
  Future<void> _handleManualMatchEnd() async {
    try {
      bool shouldEndMatch;

      if (inningNo.value == 2) {
        // Check network connectivity for 2nd inning manual end
        final connectivityService = ConnectivityService.instance;
        bool hasNetwork = await connectivityService.hasInternetConnection();

        if (!hasNetwork) {
          // Show network required dialog
          bool shouldRetry = await _showNetworkRequiredDialog();
          if (shouldRetry) {
            // Retry network check
            hasNetwork = await connectivityService.hasInternetConnection();
            if (!hasNetwork) {
              _showSnackbar(
                "No Network",
                "Please check your internet connection and try again.",
                Colors.red,
              );
              return;
            }
          } else {
            return; // User cancelled
          }
        }

        // Show 2nd inning manual end confirmation
        shouldEndMatch = await _showEndMatchConfirmationDialog();
      } else {
        // Show simple confirmation for 1st inning manual end
        shouldEndMatch = await _showSimpleDialog(
          title: "End Match?",
          content:
              "Are you sure you want to end this match without completing the first inning? This action cannot be undone.",
          confirmText: "End Match",
        );
      }

      if (shouldEndMatch) {
        log('User confirmed manual match end');
        if (inningNo.value == 1) {
          // For first inning, we still need to handle it as first inning end
          await _handleFirstInningEnd();
        } else {
          // For second inning, end the match
          await _handleMatchEnd();
        }
      }
    } catch (e) {
      log('Error in _handleManualMatchEnd: $e');
      _showSnackbar(
        "Error",
        "Failed to end match. Please try again.",
        Colors.red,
      );
    }
  }

  Future<void> _handleFirstInningEnd() async {
    firstInningScore.value = totalRuns.value;
    matchModel.firstInningScore = firstInningScore.value;
    matchModel.inningNo = 2;
    await _repo.updateMatch(matchModel);

    log(
      'First inning complete: ${currentBattingTeamId.value == team1Id.value ? team1.value : team2.value} scored ${firstInningScore.value} runs',
    );

    await Future.delayed(Duration(milliseconds: 500));
    Get.toNamed(NAV_SHIFT_INNING, arguments: {'matchId': matchId});
  }

  Future<void> _handleMatchEnd() async {
    try {
      log('🏆 _handleMatchEnd called - calculating match result');
      await _calculateAndSetMatchResult();

      log('💾 Ending match in database...');
      await _repo.endMatch(matchId);

      // Set match completed state
      _matchCompleted.value = true;
      log('✅ Match completed state set to true');

      // Show match end dialog if not already shown
      log(
        '🔍 Checking if dialog should be shown - _matchEndDialogShown: ${_matchEndDialogShown.value}',
      );
      if (!_matchEndDialogShown.value) {
        log('💬 Setting dialog shown flag and showing dialog...');
        _matchEndDialogShown.value = true;
        await _showMatchEndDialog();
        log('💬 Dialog showing completed');
      } else {
        log('⚠️ Match end dialog already shown, skipping');
      }

      log('Match completed: ${matchModel.result}');
    } catch (e) {
      log('Error handling match end: $e');
      rethrow;
    }
  }

  Future<void> _calculateAndSetMatchResult() async {
    final secondInningScore = totalRuns.value;
    final firstInningScore = this.firstInningScore.value;

    log(
      '🏆 Calculating match result: Team2Score=$secondInningScore, Team1Score=$firstInningScore',
    );

    String result;
    String winnerTeam;
    int winnerTeamId;

    if (secondInningScore > firstInningScore) {
      winnerTeamId = currentBattingTeamId.value;
      winnerTeam =
          currentBattingTeamId.value == team1Id.value
              ? team1.value
              : team2.value;
      final margin = secondInningScore - firstInningScore;
      result = "$winnerTeam won by $margin runs";
      log('🏅 TEAM 2 WINS: $result');
    } else if (firstInningScore > secondInningScore) {
      winnerTeamId =
          currentBattingTeamId.value == team1Id.value
              ? team2Id.value
              : team1Id.value;
      winnerTeam = winnerTeamId == team1Id.value ? team1.value : team2.value;
      final margin = 10 - wickets.value;
      result = "$winnerTeam won by $margin wickets";
      log('🏅 TEAM 1 WINS: $result');
    } else {
      winnerTeamId = 0;
      winnerTeam = "Tie";
      result = "Match tied";
      log('🤝 MATCH TIED: $result');
    }

    matchModel.status = 'completed';
    matchModel.result = result;
    matchModel.winnerTeamId = winnerTeamId;

    log('📝 Final match result set: ${matchModel.result}');
  }

  /// Show match end dialog with View Result and Stay Here buttons
  Future<void> _showMatchEndDialog() async {
    log(
      '🎭 _showMatchEndDialog called - preparing to show match result dialog',
    );

    // Determine if it's a tie or win scenario for appropriate styling
    final isTie = matchModel.result?.toLowerCase().contains('tied') ?? false;
    final dialogColor = isTie ? Colors.blue : Colors.green;
    final dialogIcon = isTie ? Icons.handshake : Icons.emoji_events;

    log('🎨 Dialog styling - isTie: $isTie, result: ${matchModel.result}');
    log('🎪 About to show Get.dialog...');

    final result = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dialogColor.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(dialogIcon, color: dialogColor.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Match Complete!",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dialogColor.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dialogColor.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    isTie ? Icons.balance : Icons.celebration,
                    color: dialogColor.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      matchModel.result ?? "The match has been completed!",
                      style: TextStyle(
                        fontSize: 14,
                        color: dialogColor.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What would you like to do?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "• View Result: See detailed match results",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Text(
              "• Stay Here: Continue on this screen",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _userChoseStayAfterMatchEnd.value = true;
              Navigator.of(Get.context!).pop('stay');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              "Stay Here",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop('result');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogColor.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assessment, size: 18),
                const SizedBox(width: 6),
                const Text(
                  "View Result",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      barrierDismissible: false, // Prevent dismissing without making a choice
    );

    log('📋 Dialog closed with result: $result');

    // Handle the user's choice
    if (result == 'result') {
      log('📋 User chose to view results - navigating to result page');
      Get.offNamed(NAV_RESULT, arguments: {'matchId': matchId});
    } else if (result == 'stay') {
      log('📋 User chose to stay on scoreboard after match completion');
      // User stays on the current screen, actions will be blocked
    } else {
      log('⚠️ Unexpected dialog result: $result');
    }

    log('🎭 _showMatchEndDialog completed');
  }

  /// Navigate to match results view
  void viewMatchResults() {
    if (isDebouncing('viewResults')) return;

    debounceTap('viewResults', () {
      log('Navigating to match results view');
      Get.toNamed(NAV_RESULT, arguments: {'matchId': matchId});
    }, delay: const Duration(milliseconds: 300));
  }

  Future<void> _handlePostMatchNavigation(String option) async {
    switch (option) {
      case 'result':
        Get.offNamed(NAV_RESULT, arguments: {'matchId': matchId});
        break;
      case 'history':
        log('Match completed and saved to history');
        Get.offAllNamed(NAV_DASHBOARD_PAGE, arguments: {'initialTab': 1});
        break;
      default:
        Get.offNamed(NAV_RESULT, arguments: {'matchId': matchId});
        break;
    }
  }

  Future<void> _handleTeamWinResult() async {
    try {
      // Prevent multiple simultaneous calls
      if (_matchCompleted.value) return;

      await _calculateAndSetMatchResult();
      await _repo.endMatch(matchId);

      // Set match completed state
      _matchCompleted.value = true;

      // Show match end dialog if not already shown
      if (!_matchEndDialogShown.value) {
        _matchEndDialogShown.value = true;
        await _showMatchEndDialog();
      }

      log('Team won: ${matchModel.result}');
    } catch (e) {
      log('Error handling team win result: $e');
      rethrow;
    }
  }

  Future<void> _restorePreviousOverState(ScoreboardModel lastEntry) async {
    try {
      await _setPlayerInfo(
        lastEntry.strikerBatsmanId,
        strikerBatsman,
        strikerBatsmanId,
      );
      await _setPlayerInfo(
        lastEntry.nonStrikerBatsmanId,
        nonStrikerBatsman,
        nonStrikerBatsmanId,
      );
      await _setPlayerInfo(lastEntry.bowlerId, bowler, bowlerId);

      matchModel.bowlerId = bowlerId.value;
      await _repo.updateMatch(matchModel);
      await _refreshAllCalculations();

      log(
        'Previous over restored - Bowler: ${bowler.value}, Striker: ${strikerBatsman.value}, Non-Striker: ${nonStrikerBatsman.value}',
      );
    } catch (e) {
      log('Error restoring previous over state: $e');
      _showSnackbar(
        "Error",
        "Failed to restore previous state: ${e.toString()}",
        Colors.red,
      );
    }
  }
  //endregion

  //==========================================================================
  //region Helper Methods
  //==========================================================================

  Future<bool> _showSimpleDialog({
    required String title,
    required String content,
    required String confirmText,
    String cancelText = "Cancel",
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Text(content, style: TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  cancelText,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ], 
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  void _showSnackbar(String title, String message, MaterialColor color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.shade100,
      colorText: color.shade800,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  //endregion

  updateStatus() async {
    final Database db = await MyDatabase().database;
    // Fallback: Just mark as completed without detailed result
    await db.update(
      TBL_MATCHES,
      {'status': 'completed', 'completedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  @override 
  void onClose() {
    updateStatus();
    // TODO: implement onClose
    super.onClose();
  }
}
