import 'package:cric_live/utils/import_exports.dart';

class HistoryController extends GetxController {
  late MatchesDisplay _repo;
  final CreateMatchRepo _createMatchRepo = CreateMatchRepo();

  RxList<MatchModel> matches = <MatchModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMatches = false.obs;
  RxString error = "".obs;

  // New section toggle variables
  RxString selectedSection = "matches".obs; // "matches" or "tournaments"
  RxList tournaments = [].obs;
  @override
  void onInit() {
    super.onInit();
    _repo = MatchesDisplay();

    //load users matches initially
    getMatches();
  }

  navigateToTournamentView(CreateTournamentModel tournament) {
    Get.toNamed(
      NAV_TOURNAMENT_DISPLAY,
      arguments: {
        "tournamentId": tournament.tournamentId,
        "hostId": tournament.hostId, // Pass the hostId from tournament data
      },
    );
  }

  Future<MatchModel?> getMatch(int matchId) async {
    return await _createMatchRepo.getMatchById(matchId);
  }

  navScheduled(int matchId) async {
    MatchModel? model = await getMatch(matchId);
    if (model == null) {
      error.value = "match not found please create new match";
    } else {
      try {
        log('🎯 Navigating to scheduled match: modelId="${model.id}"');
        
        // Ensure matchId is properly converted to int
        int? matchIdInt;
        if (model.id is int) {
          matchIdInt = model.id;
        } else if (model.id is String) {
          matchIdInt = int.tryParse(model.id.toString());
        } else {
          matchIdInt = int.tryParse(model.id.toString());
        }
        
        if (matchIdInt != null && matchIdInt > 0) {
          log('✅ Navigating to NAV_CREATE_MATCH with matchId: $matchIdInt');
          Get.toNamed(NAV_CREATE_MATCH, arguments: {'matchId': matchIdInt});
        } else {
          log('❌ Invalid matchId for scheduled match: ${model.id}');
          error.value = "Invalid match ID. Cannot open match editor.";
          Get.snackbar(
            'Navigation Error',
            'Invalid match ID. Cannot edit match.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } catch (e) {
        log('❌ Error navigating to scheduled match: $e');
        error.value = "Failed to navigate to match editor.";
        Get.snackbar(
          'Navigation Error',
          'Failed to open match editor. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    }
  }

  navResume(MatchModel match) async {
    try {
      if (match.matchState == null) {
        getSnackBar(title: "match is not found", message: "create a new match");
        return;
      }
      
      final rawMatchId = match.matchState!.matchId;
      log('🎯 Resuming match from history: matchId="$rawMatchId"');
      
      // Ensure matchId is properly converted to int
      int? matchIdInt;
      if (rawMatchId is int) {
        matchIdInt = rawMatchId;
      } else if (rawMatchId is String) {
        matchIdInt = int.tryParse(rawMatchId.toString());
      } else {
        matchIdInt = int.tryParse(rawMatchId.toString());
      }
      
      if (matchIdInt != null && matchIdInt > 0) {
        log('✅ Resuming scoreboard from history with matchId: $matchIdInt');
        Get.toNamed(
          NAV_SCOREBOARD,
          arguments: {'matchId': matchIdInt},
        );
      } else {
        log('❌ Invalid matchId for resume from history: $rawMatchId');
        Get.snackbar(
          'Navigation Error',
          'Invalid match ID. Cannot resume match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      log('❌ Error resuming match from history: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to resume match. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> getMatches() async {
    try {
      isLoading.value = true;
      error.value = "";
      
      log('🔄 Refreshing user matches...');
      final fetchedMatches = await _repo.getUsersMatches();
      
      if (fetchedMatches != null) {
        matches.assignAll(
          fetchedMatches.where((match) {
            // Only show completed matches in history
            bool isCompleted =
                match.status?.toLowerCase() == 'completed' ||
                match.status?.toLowerCase() == 'scheduled' ||
                match.status?.toLowerCase() == 'resume';
            
            // For completed matches, we don't need matchState
            // For scheduled/resume matches, we need matchState or it should be scheduled
            bool hasValidState = match.status?.toLowerCase() == 'completed' ||
                match.matchState != null || 
                match.status?.toLowerCase() == "scheduled";

            log('🔍 Match ${match.id}: status=${match.status}, hasMatchState=${match.matchState != null}, isCompleted=$isCompleted, hasValidState=$hasValidState');
            return isCompleted && hasValidState;
          }).toList(),
        );
        matches.refresh();
        hasMatches.value = matches.isNotEmpty;
        log('✅ Filtered matches for history: ${matches.length}');
      } else {
        matches.clear();
        hasMatches.value = false;
        log('⚠️ No matches returned from API');
      }
    } catch (e) {
      error.value = e.toString();
      log('❌ Error in getMatches: ${e.toString()}');
      // Show user-friendly error message
      Get.snackbar(
        "Refresh Failed",
        "Unable to refresh matches. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Manual refresh method for pull-to-refresh
  Future<void> refreshMatches() async {
    log('🔄 Manual refresh triggered by user');
    await getMatches();
  }
  
  /// Debug method to test API connectivity
  Future<void> testApiConnectivity() async {
    try {
      log('🔍 Testing API connectivity...');
      final authService = AuthService();
      final tokenModel = authService.fetchInfoFromToken();
      
      if (tokenModel?.uid == null) {
        log('❌ User not authenticated - cannot test API');
        return;
      }
      
      final apiService = ApiServices();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testUrl = "/CL_Matches/GetMatchesByUser/${tokenModel!.uid}?t=$timestamp";
      
      log('📡 Testing endpoint: $testUrl');
      
      final response = await apiService.get(testUrl);
      log('✅ API test successful: ${response.keys.toList()}');
      
      if (response.containsKey('matches')) {
        final matchCount = (response['matches'] as List?)?.length ?? 0;
        log('📊 API returned $matchCount matches');
      }
    } catch (e) {
      log('❌ API test failed: $e');
    }
  }
  
  /// Switch between matches and tournaments section
  void switchSection(String section) {
    selectedSection.value = section;
    if (section == "tournaments") {
      fetchTournaments();
    } else {
      getMatches();
    }
  }

  /// Fetch tournaments - API call placeholder
  Future<void> fetchTournaments() async {
    try {
      isLoading.value = true;
      error.value = "";

      // TODO: Implement API call to fetch tournaments
      // For now, using placeholder data
      tournaments.value = await _repo.getUsersTournaments() ?? [];
      tournaments.refresh();
    } catch (e) {
      error.value = e.toString();
      log('Error fetching tournaments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a match
  Future<void> deleteMatch(MatchModel match) async {
    if (match.id == null) {
      Get.snackbar(
        "Error",
        "Cannot delete match: Invalid match ID",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Call API to delete match
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> response = await apiServices.delete(
        "/CL_Matches/DeleteMatch/${match.id}",
      );

      // Check if deletion was successful
      if (response.containsKey('message') || response['success'] == true) {
        // Remove match from local list
        matches.removeWhere((m) => m.id == match.id);
        matches.refresh();

        Get.snackbar(
          "Success",
          "Match deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        throw Exception("Failed to delete match");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete match: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  /// Delete a tournament
  Future<void> deleteTournament(CreateTournamentModel tournament) async {
    if (tournament.tournamentId == null) {
      Get.snackbar(
        "Error",
        "Cannot delete tournament: Invalid tournament ID",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Call API to delete tournament
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> response = await apiServices.delete(
        "/CL_Tournaments/DeleteTournament/${tournament.tournamentId}",
      );

      // Check if deletion was successful
      if (response.containsKey('message') || response['success'] == true) {
        // Remove tournament from local list
        tournaments.removeWhere(
          (t) => t.tournamentId == tournament.tournamentId,
        );
        tournaments.refresh();

        Get.snackbar(
          "Success",
          "Tournament deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        throw Exception("Failed to delete tournament");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete tournament: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
