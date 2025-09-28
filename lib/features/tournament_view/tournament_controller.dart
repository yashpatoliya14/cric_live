import 'package:cric_live/utils/import_exports.dart';
import 'user_role.dart';
import '../../utils/access_control_utils.dart';

class TournamentController extends GetxController {
  // RxVariables
  RxList<MatchModel> matches = <MatchModel>[].obs;
  Rx<TournamentModel?> tournament = Rx<TournamentModel?>(null);
  RxBool isLoading = true.obs;
  RxBool isUserScorer = false.obs;
  RxString error = "".obs;
  Rx<UserRole> userRole = UserRole.viewer.obs;

  // Local variables
  late int tournamentId;
  late int hostId;
  final TournamentRepo _repo = TournamentRepo();
  final CreateMatchRepo _createMatchRepo = CreateMatchRepo();
  final SelectTeamRepo _selectTeamRepo = SelectTeamRepo();
  final AuthService _authService = AuthService();

  // Get user role text
  String get userRoleText {
    return userRole.value.displayText;
  }

  // Check if user can create matches
  bool get canCreateMatches {
    return userRole.value.canCreateMatches;
  }

  // Check if user can edit matches
  bool get canEditMatches {
    return userRole.value.canEditMatches;
  }

  // Check if user can delete matches
  bool get canDeleteMatches {
    return userRole.value.canDeleteMatches;
  }

  // Check if user can control matches (start/stop/resume)
  bool get canControlMatches {
    return userRole.value.canControlMatches;
  }

  // Check if user has admin access
  bool get hasAdminAccess {
    return userRole.value.hasAdminAccess;
  }

  @override
  void onInit() {
    super.onInit();

    // Get arguments from route
    final arguments = Get.arguments;
    log("Tournament arguments received: $arguments");
    if (arguments != null) {
      tournamentId = arguments["tournamentId"] ?? 0;
      // If hostId is not provided, use tournamentId as hostId
      // This handles cases where we only have tournamentId
      hostId = arguments["hostId"] ?? arguments["tournamentId"] ?? 0;
      log("Tournament ID: $tournamentId, Host ID: $hostId");
    } else {
      log("ERROR: No arguments provided to tournament view!");
    }

    _initializeData();
  }

  _initializeData() async {
    try {
      isLoading.value = true;

      // Fetch tournament details and check scorer status
      await _fetchTournamentDetails();

      // Fetch tournament matches
      await _fetchTournamentMatches();
    } catch (e) {
      log("Error initializing tournament data: $e");
      Get.snackbar(
        "Error",
        "Failed to load tournament data",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  _fetchTournamentDetails() async {
    try {
      log("🏟️ Fetching tournament details for tournamentId: $tournamentId (not hostId: $hostId)");
      tournament.value = await _repo.getTournamentBySpecificId(tournamentId);

      if (tournament.value != null) {
        log("Tournament fetched successfully: ${tournament.value!.name}");
        log("Tournament data: ${tournament.value!.toMap()}");

        // Force UI update by triggering observable
        tournament.refresh();

        // Check user role and access
        log("🔍 Starting access control check...");
        
        TokenModel? userToken = _authService.fetchInfoFromToken();
        log("📋 User Token: $userToken");
        
        if (userToken != null) {
          log("✅ User token found");
          log("👤 Token UID: ${userToken.uid}");
          log("📧 Token Email: ${userToken.email}");
          log("🏷️ Token Username: ${userToken.username}");
          
          if (userToken.uid != null) {
            int userId = userToken.uid!;
            log("🆔 User ID extracted: $userId (type: ${userId.runtimeType})");
            
            // Log tournament details
            log("🏟️ Tournament Host ID: ${tournament.value!.hostId} (type: ${tournament.value!.hostId.runtimeType})");
            log("📊 Tournament Name: ${tournament.value!.name}");
            log("👥 Scorers Array Length: ${tournament.value!.scorers.length}");
            
            // Log each scorer in detail
            for (int i = 0; i < tournament.value!.scorers.length; i++) {
              var scorer = tournament.value!.scorers[i];
              log("👤 Scorer [$i]: ID=${scorer.scorerId} (type: ${scorer.scorerId.runtimeType}), Name=${scorer.username}");
            }
            
            // Check if user is host (tournament creator)
            bool isHost = userId == tournament.value!.hostId;
            log("🏠 Host Check: $userId == ${tournament.value!.hostId} = $isHost");
            
            // Check if user is in scorers list with detailed logging
            log("🔍 Checking scorers list...");
            bool isInScorersList = false;
            for (var scorer in tournament.value!.scorers) {
              bool match = scorer.scorerId == userId;
              log("   👤 Scorer ${scorer.scorerId} == User $userId = $match");
              if (match) {
                isInScorersList = true;
                log("   ✅ MATCH FOUND! User is a scorer");
                break;
              }
            }
            log("📋 Final Scorer Check Result: $isInScorersList");
            
            // Determine user role based on access
            if (isHost) {
              userRole.value = UserRole.host;
              isUserScorer.value = true;
              log("👑 Role Assigned: Tournament Admin (Host)");
            } else if (isInScorersList) {
              userRole.value = UserRole.scorer;
              isUserScorer.value = true;
              log("✏️ Role Assigned: Scorer Access");
            } else {
              userRole.value = UserRole.viewer;
              isUserScorer.value = false;
              log("👁️ Role Assigned: View Only");
            }

            // Enhanced logging for debugging
            log("=========== FINAL ACCESS CONTROL SUMMARY ===========");
            log("🆔 User ID: $userId");
            log("🏟️ Tournament Host ID: ${tournament.value!.hostId}");
            log("🏠 Is Host: $isHost");
            log("👥 Scorers List: ${tournament.value!.scorers.map((s) => '${s.scorerId}(${s.username})').toList()}");
            log("✏️ Is In Scorers List: $isInScorersList");
            log("🎭 Final Role: ${userRole.value.displayText}");
            log("🆔 Legacy isUserScorer: ${isUserScorer.value}");
            log("➕ Can Create Matches: $canCreateMatches");
            log("✏️ Can Edit Matches: $canEditMatches");
            log("🗑️ Can Delete Matches: $canDeleteMatches");
            log("🎮 Can Control Matches: $canControlMatches");
            log("👑 Has Admin Access: $hasAdminAccess");
            log("====================================================");
          } else {
            log("❌ User token UID is null!");
            userRole.value = UserRole.viewer;
            isUserScorer.value = false;
          }
        } else {
          log("❌ No user token found!");
          userRole.value = UserRole.viewer;
          isUserScorer.value = false;
        }
      } else {
        log("Tournament is null after fetch attempt");
      }
    } catch (e) {
      log("Error fetching tournament details: $e");
      rethrow;
    }
  }

  _fetchTournamentMatches() async {
    try {
      matches.value = await _repo.fetchTournamentMatches(tournamentId) ?? [];
      log("Fetched ${matches.length} matches for tournament $tournamentId");
    } catch (e) {
      log("Error fetching tournament matches: $e");
      rethrow;
    }
  }

  startMatch(MatchModel match) async {
    // Only allow starting match if user has control access
    if (!checkAccessWithMessage("Start Match", canControlMatches)) {
      return;
    }

    try {
      log('🎯 Starting match: matchId="${match.id}"');
      
      // Ensure matchId is properly converted to int
      int? matchIdInt;
      if (match.id is int) {
        matchIdInt = match.id;
      } else if (match.id is String) {
        matchIdInt = int.tryParse(match.id.toString());
      } else {
        matchIdInt = int.tryParse(match.id.toString());
      }
      
      if (matchIdInt != null && matchIdInt > 0) {
        log('✅ Starting match with matchId: $matchIdInt');
        Get.toNamed(NAV_TOSS_DECISION, arguments: {"matchId": matchIdInt});
      } else {
        log('❌ Invalid matchId for startMatch: ${match.id}');
        Get.snackbar(
          "Error",
          "Invalid match ID. Cannot start match.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      log("Error starting match: $e");
      Get.snackbar(
        "Error",
        "Failed to start match",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<MatchModel?> getMatch(int matchId) async {
    return await _createMatchRepo.getMatchById(matchId);
  }

  navScheduled(MatchModel model) async {
    try {
      log('🎯 Navigating to scheduled match: matchId="${model.id}", tournamentId="${model.tournamentId}"');
      
      // Ensure matchId is properly converted to int
      int? matchIdInt;
      if (model.id is int) {
        matchIdInt = model.id;
      } else if (model.id is String) {
        matchIdInt = int.tryParse(model.id.toString());
      } else {
        matchIdInt = int.tryParse(model.id.toString());
      }
      
      // Ensure tournamentId is properly converted to int
      int? tournamentIdInt;
      if (model.tournamentId is int) {
        tournamentIdInt = model.tournamentId;
      } else if (model.tournamentId is String) {
        tournamentIdInt = int.tryParse(model.tournamentId.toString());
      } else {
        tournamentIdInt = int.tryParse(model.tournamentId.toString());
      }
      
      if (matchIdInt != null && matchIdInt > 0 && tournamentIdInt != null && tournamentIdInt > 0) {
        log('✅ Navigating to create match with matchId: $matchIdInt, tournamentId: $tournamentIdInt');
        Get.toNamed(
          NAV_CREATE_MATCH,
          arguments: {'matchId': matchIdInt, 'tournamentId': tournamentIdInt},
        );
      } else {
        log('❌ Invalid IDs - matchId: ${model.id}, tournamentId: ${model.tournamentId}');
        Get.snackbar(
          'Navigation Error',
          'Invalid match or tournament ID. Cannot edit match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      log('❌ Error navigating to scheduled match: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to open match editor. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  navResume(MatchModel match) async {
    try {
      log('🎯 Resuming match: ${match.toMap()}');
      
      if (match.matchState == null) {
        log('❌ Match state is null for match: ${match.id}');
        getSnackBar(title: "Match not found", message: "Create a new match");
        return;
      }
      
      final rawMatchId = match.matchState?.matchId;
      log('🎯 Resuming match: matchId="$rawMatchId"');
      
      // Ensure matchId is properly converted to int
      int? matchIdInt;
      if (rawMatchId is int) {
        matchIdInt = rawMatchId;
      } else if (rawMatchId is String) {
        matchIdInt = int.tryParse(rawMatchId.toString());
      } else if (rawMatchId != null) {
        matchIdInt = int.tryParse(rawMatchId.toString());
      }
      
      if (matchIdInt != null && matchIdInt > 0) {
        log('✅ Resuming scoreboard with matchId: $matchIdInt');
        Get.toNamed(
          NAV_SCOREBOARD,
          arguments: {'matchId': matchIdInt},
        );
      } else {
        log('❌ Invalid matchId for resume: $rawMatchId');
        Get.snackbar(
          'Navigation Error',
          'Invalid match ID. Cannot resume match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      log('❌ Error resuming match: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to resume match. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  viewMatch(MatchModel match) {
    try {
      // Navigate to match view for non-scorers or general viewing
      log('🎯 Navigating to match view: matchId="${match.id}"');
      
      // Ensure matchId is properly converted to int
      int? matchIdInt;
      if (match.id is int) {
        matchIdInt = match.id;
      } else if (match.id is String) {
        matchIdInt = int.tryParse(match.id.toString());
      } else {
        matchIdInt = int.tryParse(match.id.toString());
      }
      
      if (matchIdInt != null && matchIdInt > 0) {
        log('✅ Navigating to NAV_MATCH_VIEW with matchId: $matchIdInt');
        Get.toNamed(NAV_MATCH_VIEW, arguments: {"matchId": matchIdInt});
      } else {
        log('❌ Invalid matchId: ${match.id}');
        Get.snackbar(
          'Navigation Error',
          'Invalid match ID. Cannot open match details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      log('❌ Error navigating to match view: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to open match details. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  refreshData() {
    _initializeData();
  }

  matchState(MatchModel match) {
    // Only allow match control if user has control access
    if (!checkAccessWithMessage("Control Match", canControlMatches)) {
      return;
    }
    
    if (match.status == "completed") {
      getSnackBar(
        title: "Match Completed",
        message: "Please Create A New Match",
      );
      return;
    } else if (match.status == "resume") {
      navResume(match);
    } else if (match.status == "scheduled") {
      navScheduled(match);
      log("Navigating to scheduled match for editing");
    }
  }

  /// Delete a match from tournament
  Future<void> deleteMatch(MatchModel match) async {
    // Only allow deletion if user can delete matches
    if (!checkAccessWithMessage("Delete Match", canDeleteMatches)) {
      return;
    }

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
        
        AccessControlUtils.showSuccessMessage(
          title: "Success",
          message: "Match deleted successfully",
        );
      } else {
        throw Exception("Failed to delete match");
      }
    } catch (e) {
      AccessControlUtils.showErrorMessage(
        title: "Error",
        message: "Failed to delete match: ${e.toString()}",
      );
    }
  }

  /// Check if user can perform a specific action and show message if not
  bool checkAccessWithMessage(String action, bool hasAccess) {
    return AccessControlUtils.checkAccessWithMessage(
      action: action,
      hasAccess: hasAccess,
      currentRole: userRole.value,
    );
  }

  /// Show role information dialog
  void showRoleInfoDialog() {
    AccessControlUtils.showRoleInfoDialog(
      currentRole: userRole.value,
      tournamentName: tournament.value?.name ?? 'Tournament',
    );
  }
}
