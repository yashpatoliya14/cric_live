import 'package:cric_live/utils/import_exports.dart';

class CreateMatchController extends GetxController {
  final CreateMatchRepo _repo = CreateMatchRepo();
  final SelectTeamRepo _selectTeamRepo = SelectTeamRepo();

  //variables
  int? tournamentId;
  int? matchIdOnline;

  //Rx variables
  RxBool isCreatingMatch = false.obs;
  RxBool isScheduledMatch = false.obs;
  var isReady = false.obs;
  var team1 = {}.obs;
  var team2 = {}.obs;
  RxList<PlayerModel> batsmanList = <PlayerModel>[].obs;
  RxList<PlayerModel> bowlerList = <PlayerModel>[].obs;

  RxString tossWinnerTeam = TEAM_A.obs;
  RxString batOrBowl = BAT.obs;
  RxInt overs = 0.obs;
  RxBool isNoBall = false.obs;
  RxBool isWide = false.obs;

  RxInt noBallRun = 1.obs;
  RxInt wideRun = 1.obs;

  // Date and Time selection for scheduled matches
  Rx<DateTime?> selectedMatchDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> selectedMatchTime = Rx<TimeOfDay?>(null);
  RxBool isDateTimeRequired = false.obs; // Set to true when scheduling a match
  RxBool showDateTimeSelection =
      false.obs; // Show date/time section even for immediate matches

  RxString bowler = "".obs;
  RxInt bowlerId = 012345.obs;

  RxString nonStrikerBatsman = "".obs;
  RxInt nonStrikerBatsmanId = 123456.obs;

  RxString strikerBatsman = "".obs;
  RxInt strikerBatsmanId = 123456.obs;

  TextEditingController controllerOvers = TextEditingController();
  TextEditingController controllerNoBallRun = TextEditingController();
  TextEditingController controllerWideRun = TextEditingController();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    everAll([batsmanList, bowlerList], (_) {
      isReady.value = batsmanList.length == 2 && bowlerList.isNotEmpty;
    });
    
    // Clear selected players when toss winner or bat/bowl decision changes
    // This prevents invalid player selections when team roles switch
    ever(tossWinnerTeam, (_) {
      if (team1.isNotEmpty && team2.isNotEmpty) {
        _clearSelectedPlayers();
        log('🔄 Cleared selected players due to toss winner change');
      }
    });
    
    ever(batOrBowl, (_) {
      if (team1.isNotEmpty && team2.isNotEmpty) {
        _clearSelectedPlayers();
        log('🔄 Cleared selected players due to bat/bowl decision change');
      }
    });

    // Check if we are starting a scheduled match
    if (Get.arguments != null && Get.arguments['matchId'] != null) {
      final int matchId = Get.arguments['matchId'];
      matchIdOnline = matchId;
      loadScheduledMatch(matchId);
    }
    tournamentId = (Get.arguments as Map?)?["tournamentId"];
    // Default extras to 1 (standard cricket rules)
    controllerWideRun.text = '1';
    controllerNoBallRun.text = '1';
    controllerOvers.text = '2';
  }

  Future<void> loadScheduledMatch(int matchId) async {
    MatchModel? match = await _repo.getMatchById(matchId);
    if (match != null) {
      log("match ::: ${match.toMap()}");

      // Safely load values with sensible defaults
      final oversVal = match.overs ?? int.tryParse(controllerOvers.text) ?? 2;

      // Heuristic: backend often returns 0 for scheduled matches' extras.
      // If status is scheduled and extras are 0 or null, fall back to 1 by default.
      int resolvedNoBall = match.noBallRun ?? 0;
      int resolvedWide = match.wideRun ?? 0;
      if ((match.status?.toLowerCase() == 'scheduled') &&
          (resolvedNoBall == 0 && resolvedWide == 0)) {
        resolvedNoBall = 1;
        resolvedWide = 1;
        log(
          '⚠️ Backend returned extras as 0 for scheduled match. Applying defaults: wideRun=1, noBallRun=1',
        );
      }

      controllerOvers.text = oversVal.toString();
      controllerNoBallRun.text = resolvedNoBall.toString();
      controllerWideRun.text = resolvedWide.toString();

      // Set toggles based on >0 extras
      isNoBall.value = (resolvedNoBall > 0);
      isWide.value = (resolvedWide > 0);

      //fetch values
      team1["teamId"] = match.team1?.toInt();
      team2["teamId"] = match.team2?.toInt();
      team1["teamName"] = match.team1Name?.toString();
      team2["teamName"] = match.team2Name?.toString();
      tournamentId = match.tournamentId;
      
      // Fix toss winner selection for scheduled matches
      // Update toss winner to use actual team name instead of TEAM_A
      if (tossWinnerTeam.value == TEAM_A && team1["teamName"] != null) {
        tossWinnerTeam.value = team1["teamName"].toString();
        log('✅ Updated toss winner to: ${tossWinnerTeam.value}');
      }
    }
  }

  /// Set team 1 and update toss winner to Team A by default
  void setTeam1(Map<String, dynamic> teamData) {
    team1.assignAll(teamData);
    // Set toss winner to Team A (team1) by default
    tossWinnerTeam.value = teamData['teamName'] ?? TEAM_A;

    // Clear selected players when team changes
    _clearSelectedPlayers();
  }

  /// Set team 2
  void setTeam2(Map<String, dynamic> teamData) {
    team2.assignAll(teamData);

    // If no toss winner set yet, default to Team A
    if (tossWinnerTeam.value == TEAM_A && team1.isNotEmpty) {
      tossWinnerTeam.value = team1['teamName'];
    }

    // Clear selected players when team changes
    _clearSelectedPlayers();
  }

  /// Clear selected players when teams change or roles switch
  void _clearSelectedPlayers() {
    final hadBatsmen = batsmanList.isNotEmpty;
    final hadBowler = bowlerList.isNotEmpty;
    
    // Clear player lists
    batsmanList.clear();
    bowlerList.clear();
    
    // Clear player names
    strikerBatsman.value = "";
    nonStrikerBatsman.value = "";
    bowler.value = "";
    
    // Reset player IDs to default values
    strikerBatsmanId.value = 123456;
    nonStrikerBatsmanId.value = 123456;
    bowlerId.value = 012345;
    
    // Log what was cleared for debugging
    if (hadBatsmen || hadBowler) {
      log('🗑️ Cleared selected players: Batsmen=${hadBatsmen ? 'Yes' : 'No'}, Bowler=${hadBowler ? 'Yes' : 'No'}');
    }
  }

  onTossWinnerTeamChanged(value) {
    if (value != null) {
      final previousWinner = tossWinnerTeam.value;
      tossWinnerTeam.value = value;
      
      // Show user feedback if players were cleared due to team role change
      if (previousWinner != value && (batsmanList.isNotEmpty || bowlerList.isNotEmpty)) {
        Get.snackbar(
          "Team Roles Changed",
          "Selected players cleared due to toss winner change",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(
            Icons.swap_horiz,
            color: Colors.blue,
          ),
        );
      }
    }
  }

  onbatOrBowlChanged(value) {
    if (value != null) {
      final previousDecision = batOrBowl.value;
      batOrBowl.value = value;
      
      // Show user feedback if players were cleared due to batting decision change
      if (previousDecision != value && (batsmanList.isNotEmpty || bowlerList.isNotEmpty)) {
        Get.snackbar(
          "Batting Decision Changed",
          "Selected players cleared due to bat/bowl decision change",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(
            Icons.sports_cricket,
            color: Colors.orange,
          ),
        );
      }
    }
  }

  onNoBallChanged(value) {
    if (value != null) {
      isNoBall.value = value;
    }
  }

  onWideChanged(value) {
    if (value != null) {
      isWide.value = value;
    }
  }

  /// Show date picker for match scheduling
  Future<void> selectMatchDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate:
          selectedMatchDate.value ?? DateTime.now().add(Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'SELECT MATCH DATE',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      fieldLabelText: 'Match Date',
      fieldHintText: 'mm/dd/yyyy',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedMatchDate.value = picked;
      log('📅 Selected match date: ${picked.toString()}');
    }
  }

  /// Show time picker for match scheduling
  Future<void> selectMatchTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedMatchTime.value ?? TimeOfDay.now(),
      helpText: 'SELECT MATCH TIME',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      hourLabelText: 'Hour',
      minuteLabelText: 'Minute',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedMatchTime.value = picked;
      log('🕐 Selected match time: ${picked.format(Get.context!)}');
    }
  }

  /// Get combined DateTime from selected date and time
  DateTime? get scheduledDateTime {
    if (selectedMatchDate.value == null || selectedMatchTime.value == null) {
      return null;
    }

    final date = selectedMatchDate.value!;
    final time = selectedMatchTime.value!;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Check if date/time is required and selected for scheduling
  bool get isSchedulingDateTimeValid {
    if (!isDateTimeRequired.value)
      return true; // Not required for immediate matches
    return selectedMatchDate.value != null && selectedMatchTime.value != null;
  }

  /// Toggle date/time selection visibility for better UX
  void toggleDateTimeSelection() {
    showDateTimeSelection.value = !showDateTimeSelection.value;
    if (!showDateTimeSelection.value) {
      // Clear selections when hiding
      selectedMatchDate.value = null;
      selectedMatchTime.value = null;
      isDateTimeRequired.value = false;
    }
  }

  /// Clear date and time selections
  void clearDateTimeSelection() {
    selectedMatchDate.value = null;
    selectedMatchTime.value = null;
    isDateTimeRequired.value = false;
    showDateTimeSelection.value = false;
  }

  bool isBatsmanTeam(team) {
    if (tossWinnerTeam.value == team['teamName'] && batOrBowl.value == BAT) {
      return true;
    } else if (tossWinnerTeam.value != team['teamName'] &&
        batOrBowl.value == BOWL) {
      return true;
    }
    return false;
  }

  /// Comprehensive validation for match creation (used by form)
  String? validateMatchCreation() {
    // Team validation
    if (team1.isEmpty || team1['teamId'] == null) {
      return "Please select Team 1 (Home Team)";
    }
    if (team2.isEmpty || team2['teamId'] == null) {
      return "Please select Team 2 (Away Team)";
    }
    if (team1['teamId'] == team2['teamId']) {
      return "Teams must be different. Please select different teams.";
    }

    // Overs validation (redundant check since form validator should catch this)
    if (controllerOvers.text.isEmpty) {
      return "Please enter number of overs";
    }
    int? overs = int.tryParse(controllerOvers.text);
    if (overs == null || overs <= 0 || overs > 50) {
      return "Please enter a valid number of overs (1-50)";
    }

    // Extra runs validation (when enabled)
    if (isNoBall.value) {
      int? noBallRuns = int.tryParse(controllerNoBallRun.text);
      if (noBallRuns == null || noBallRuns < 0 || noBallRuns > 6) {
        return "No-ball runs must be between 0-6";
      }
    }
    if (isWide.value) {
      int? wideRuns = int.tryParse(controllerWideRun.text);
      if (wideRuns == null || wideRuns < 0 || wideRuns > 6) {
        return "Wide runs must be between 0-6";
      }
    }

    // Date/Time validation for scheduled matches
    if (isDateTimeRequired.value) {
      if (selectedMatchDate.value == null) {
        return "Scheduled matches require a specific date. Please select a match date.";
      }
      if (selectedMatchTime.value == null) {
        return "Scheduled matches require a specific time. Please select a match time.";
      }

      // Validate that scheduled date/time is in the future
      final scheduledDateTime = this.scheduledDateTime;
      if (scheduledDateTime != null &&
          scheduledDateTime.isBefore(DateTime.now())) {
        return "Scheduled match date and time must be in the future";
      }
    }

    return null; // All validations passed
  }

  /// Legacy validation method (kept for backward compatibility)
  String? validatePreTossSettings() {
    return validateMatchCreation();
  }

  onCreateMatch({required bool isScheduled}) async {
    try {
      // Set datetime requirement flag for scheduled matches
      isDateTimeRequired.value = isScheduled;

      // For scheduled matches, date/time selection is MANDATORY
      if (isScheduled) {
        // Always show date/time section for scheduled matches
        showDateTimeSelection.value = true;

        // Ensure both date and time are selected for scheduled matches
        if (selectedMatchDate.value == null) {
          await selectMatchDate();
          if (selectedMatchDate.value == null) {
            Get.snackbar(
              "Date Required",
              "Please select a date for the scheduled match",
              backgroundColor: Colors.orange.shade100,
              colorText: Colors.orange.shade800,
              icon: Icon(Icons.calendar_today, color: Colors.orange.shade600),
            );
            return; // User cancelled or didn't select date
          }
        }

        if (selectedMatchTime.value == null) {
          await selectMatchTime();
          if (selectedMatchTime.value == null) {
            Get.snackbar(
              "Time Required",
              "Please select a time for the scheduled match",
              backgroundColor: Colors.orange.shade100,
              colorText: Colors.orange.shade800,
              icon: Icon(Icons.access_time, color: Colors.orange.shade600),
            );
            return; // User cancelled or didn't select time
          }
        }

        // Validate that the scheduled date/time is in the future
        final scheduledDateTime = this.scheduledDateTime;
        if (scheduledDateTime != null &&
            scheduledDateTime.isBefore(DateTime.now())) {
          Get.snackbar(
            "Invalid Date/Time",
            "Scheduled matches must be set for a future date and time",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            icon: Icon(Icons.error_outline, color: Colors.red.shade600),
          );
          return;
        }
      }

      // Clear any existing ScoreboardController instances to prevent conflicts
      try {
        Get.delete<ScoreboardController>();
      } catch (e) {
        log('No existing ScoreboardController instances to clear: $e');
      }

      // Set appropriate loading state
      if (isScheduled) {
        isScheduledMatch.value = true;
      } else {
        isCreatingMatch.value = true;
      }

      // Determine match date based on match type
      DateTime matchDateTime;
      if (isScheduled) {
        // For scheduled matches, MUST use the selected date/time (validated above)
        matchDateTime = scheduledDateTime!;
        log('📅 Using scheduled date/time: ${matchDateTime.toString()}');
      } else if (showDateTimeSelection.value && scheduledDateTime != null) {
        // For immediate matches with optional date/time selected
        matchDateTime = scheduledDateTime!;
        log(
          '📅 Using optional selected date/time: ${matchDateTime.toString()}',
        );
      } else {
        // For immediate matches without specific date/time - use current time
        matchDateTime = DateTime.now();
        log(
          '🕰️ Using current date/time for immediate match: ${matchDateTime.toString()}',
        );
      }

      // Safely parse fields
      final parsedOvers = int.tryParse(controllerOvers.text) ?? 2;
      final parsedNoBall = int.parse(controllerNoBallRun.text);
      final parsedWide = int.parse(controllerWideRun.text);

      log(
        '🗓️ Scheduling with extras: wideRun=$parsedWide, noBallRun=$parsedNoBall',
      );
      MatchModel data = MatchModel(
        matchIdOnline: matchIdOnline,
        matchDate: matchDateTime,
        inningNo: 1,
        overs: parsedOvers,
        noBallRun: parsedNoBall,
        wideRun: parsedWide,
        status: "scheduled",
        tossWon:
            tossWinnerTeam.value == team1['teamName']
                ? team1['teamId']
                : team2['teamId'],
        team1: team1['teamId'],
        team2: team2['teamId'],
        currentBattingTeamId:
            isBatsmanTeam(team1) ? team1['teamId'] : team2['teamId'],
        strikerBatsmanId: strikerBatsmanId.value,
        nonStrikerBatsmanId: nonStrikerBatsmanId.value,
        bowlerId: bowlerId.value,
        tournamentId: tournamentId,
      );

      // fetch uid
      AuthService service = AuthService();
      TokenModel? tokenModel = service.fetchInfoFromToken();
      if (tokenModel == null) {
        throw Exception("userid is not found");
      }
      data.uid = tokenModel.uid ?? -1;

      // first it create match in database
      if (isScheduled || matchIdOnline == null) {
        log(
          ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::${data.toMap()}",
        );
        matchIdOnline = await _repo.createMatchOnline(data);
      }

      if (matchIdOnline == null) {
        Get.snackbar("Match Is Not Created", "Please Try Again");
        return;
      } else {
        data.matchIdOnline = matchIdOnline;
      }

      if (isScheduled) {
        Get.back(
          result: {
            "success": true,
            "matchId": matchIdOnline,
            "status": isScheduled ? "scheduled" : "created",
          },
        );
      } else {
        // Ensure matchId is properly typed for navigation
        if (matchIdOnline != null) {
          log('🎯 Navigating to toss decision with matchId: $matchIdOnline');
          Get.toNamed(NAV_TOSS_DECISION, arguments: {"matchId": matchIdOnline});
        } else {
          log('❌ matchIdOnline is null, cannot navigate to toss decision');
          Get.snackbar(
            "Navigation Error",
            "Match ID is invalid. Cannot proceed.",
          );
        }
      }
    } catch (e) {
      // Handle any errors and show user-friendly message
      log('❌ Error in onCreateMatch: $e');
      Get.snackbar(
        "Error",
        "Failed to create match. Please try again.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      // Always reset loading states
      isScheduledMatch.value = false;
      isCreatingMatch.value = false;
    }
  }

  startMatch() async {
    try {
      isCreatingMatch.value = true;

      // Validate player selections before creating match
      if (batsmanList.length < 2) {
        Get.snackbar(
          "Missing Players",
          "Please select 2 batsmen before starting the match.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (bowlerList.isEmpty) {
        Get.snackbar(
          "Missing Player",
          "Please select a bowler before starting the match.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate that all player IDs are valid
      final strikerPlayerId = batsmanList[0].teamPlayerId;
      final nonStrikerPlayerId = batsmanList[1].teamPlayerId;
      final bowlerPlayerId = bowlerList[0].teamPlayerId;

      if (strikerPlayerId == null || strikerPlayerId <= 0) {
        Get.snackbar(
          "Invalid Player",
          "Striker batsman ID is invalid. Please reselect players.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (nonStrikerPlayerId == null || nonStrikerPlayerId <= 0) {
        Get.snackbar(
          "Invalid Player",
          "Non-striker batsman ID is invalid. Please reselect players.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (bowlerPlayerId == null || bowlerPlayerId <= 0) {
        Get.snackbar(
          "Invalid Player",
          "Bowler ID is invalid. Please reselect players.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Log player information for debugging
      log('🏏 Creating match with players:');
      log('  Striker: ${batsmanList[0].playerName} (ID: $strikerPlayerId)');
      log(
        '  Non-Striker: ${batsmanList[1].playerName} (ID: $nonStrikerPlayerId)',
      );
      log('  Bowler: ${bowlerList[0].playerName} (ID: $bowlerPlayerId)');

      // Safely parse fields
      final parsedOvers = int.tryParse(controllerOvers.text) ?? 2;
      final parsedNoBall = int.parse(controllerNoBallRun.text);
      final parsedWide = int.parse(controllerWideRun.text);

      log(
        '🎛️ Extras configured for start: wideRun=$parsedWide, noBallRun=$parsedNoBall',
      );
      MatchModel data = MatchModel(
        matchIdOnline: matchIdOnline,
        matchDate: DateTime.now(),
        inningNo: 1,
        overs: parsedOvers,
        noBallRun: parsedNoBall,
        wideRun: parsedWide,
        status: "live",
        tossWon:
            tossWinnerTeam.value == team1['teamName']
                ? team1['teamId']
                : team2['teamId'],
        team1: team1['teamId'],
        team2: team2['teamId'],
        currentBattingTeamId:
            isBatsmanTeam(team1) ? team1['teamId'] : team2['teamId'],
        strikerBatsmanId: strikerPlayerId,
        nonStrikerBatsmanId: nonStrikerPlayerId,
        bowlerId: bowlerPlayerId,
        tournamentId: tournamentId,
        uid: _repo.getUidOfUser(),
      );

      //update a match in online
      await _repo.updateMatchOnline(model: data);
      log(data.toString());

      // set up local database
      await _selectTeamRepo.getAllTeams(wantToStore: true);
      int localMatchId = await _repo.createMatch(data);

      // Ensure matchId is valid before navigation
      if (localMatchId > 0) {
        log('🎯 Navigating to scoreboard with localMatchId: $localMatchId');
        Get.toNamed(NAV_SCOREBOARD, arguments: {"matchId": localMatchId});
      } else {
        log(
          '❌ Invalid localMatchId: $localMatchId, cannot navigate to scoreboard',
        );
        Get.snackbar(
          "Navigation Error",
          "Failed to create local match. Cannot start scoring.",
        );
      }
    } catch (e) {
      log('❌ Error in startMatch: $e');
      Get.snackbar(
        "Error",
        "Failed to start match. Please try again.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isCreatingMatch.value = false;
    }
  }

  Future<void> selectBatsman() async {
    // Validate teams are selected first
    if (team1.isEmpty || team2.isEmpty) {
      Get.snackbar(
        "Teams Required",
        "Please select both teams before choosing players",

        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    int battingTeamId =
        isBatsmanTeam(team1) ? team1['teamId'] : team2['teamId'];

    // Get current selected player IDs if any
    List<int> currentSelectedIds = [];
    if (batsmanList.isNotEmpty) {
      currentSelectedIds =
          batsmanList
              .where((player) => player.teamPlayerId != null)
              .map((player) => player.teamPlayerId!)
              .toList();
      log('🔄 Passing currently selected batsman IDs: $currentSelectedIds');
    }

    List<PlayerModel> batters = await Get.toNamed(
      NAV_CHOOSE_PLAYER,
      arguments: {
        "teamId": battingTeamId,
        "limit": 2,
        "selectedPlayerIds": currentSelectedIds,
      },
    );

    if (batters.length < 2) {
      return;
    }

    // Update the batsman list
    batsmanList.value = batters;

    strikerBatsmanId.value = batters[0].teamPlayerId ?? 0;
    nonStrikerBatsmanId.value = batters[1].teamPlayerId ?? 0;
    strikerBatsman.value = batters[0].playerName ?? "";
    nonStrikerBatsman.value = batters[1].playerName ?? "";
  }

  Future<void> selectBowler() async {
    // Validate teams are selected first
    if (team1.isEmpty || team2.isEmpty) {
      Get.snackbar(
        "Teams Required",
        "Please select both teams before choosing players",

        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    int bowlingTeamId =
        isBatsmanTeam(team1) ? team2['teamId'] : team1['teamId'];
    String bowlingTeamName =
        isBatsmanTeam(team1) ? team2['teamName'] : team1['teamName'];

    // Get current selected bowler ID if any
    List<int> currentSelectedIds = [];
    if (bowlerList.isNotEmpty && bowlerList[0].teamPlayerId != null) {
      currentSelectedIds = [bowlerList[0].teamPlayerId!];
      log('🔄 Passing currently selected bowler ID: $currentSelectedIds');
    }

    List<PlayerModel> bowlers = await Get.toNamed(
      NAV_CHOOSE_PLAYER,
      arguments: {
        "teamId": bowlingTeamId,
        "limit": 1,
        "selectedPlayerIds": currentSelectedIds,
      },
    );

    if (bowlers.isEmpty) {
      Get.snackbar(
        "Selection Required",
        "Please select 1 bowler from $bowlingTeamName to continue.",

        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Update the bowler list
    bowlerList.value = bowlers;

    bowlerId.value = bowlers[0].teamPlayerId ?? 0;
    bowler.value = bowlers[0].playerName ?? "";
  }
}
