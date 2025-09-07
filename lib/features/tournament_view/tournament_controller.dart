import 'package:cric_live/utils/import_exports.dart';

class TournamentController extends GetxController {
  // RxVariables
  RxList<CreateMatchModel> matches = <CreateMatchModel>[].obs;
  Rx<TournamentModel?> tournament = Rx<TournamentModel?>(null);
  RxBool isLoading = true.obs;
  RxBool isUserScorer = false.obs;

  // Local variables
  late int tournamentId;
  late int hostId;
  final TournamentRepo _repo = TournamentRepo();
  final CreateMatchRepo _createMatchRepo = CreateMatchRepo();
  final SelectTeamRepo _selectTeamRepo = SelectTeamRepo();
  final AuthService _authService = AuthService();

  // Get user role text
  String get userRoleText {
    if (!isUserScorer.value) return "View Only";

    TokenModel? userToken = _authService.fetchInfoFromToken();
    if (userToken != null && tournament.value != null) {
      if (userToken.uid == tournament.value!.hostId) {
        return "Tournament Admin";
      }
    }
    return "Scorer Access";
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
      log("Fetching tournament details for hostId: $hostId");
      tournament.value = await _repo.getTournamentById(hostId);

      if (tournament.value != null) {
        log("Tournament fetched successfully: ${tournament.value!.name}");
        log("Tournament data: ${tournament.value!.toMap()}");

        // Force UI update by triggering observable
        tournament.refresh();

        // Check if current user is a scorer
        TokenModel? userToken = _authService.fetchInfoFromToken();
        if (userToken != null) {
          // Check scorer status using both email and uid
          isUserScorer.value = tournament.value!.isUserScorer(
            userToken.email,
            uid: userToken.uid,
          );

          // Log additional details for debugging
          bool isHost = userToken.uid == tournament.value!.hostId;
          bool isInScorersList = tournament.value!.scorers.any(
            (s) => s.scorerId == userToken.uid,
          );

          log(
            "User ${userToken.email} (uid: ${userToken.uid}) - isHost: $isHost, isInScorersList: $isInScorersList, final isUserScorer: ${isUserScorer.value}",
          );
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

  startMatch(CreateMatchModel match) async {
    // Only allow starting match if user is a scorer or host
    if (!isUserScorer.value) {
      Get.snackbar(
        "Access Denied",
        "Only tournament admins and scorers can start matches",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      Get.toNamed(NAV_TOSS_DECISION, arguments: {"matchId": match.id});
    } catch (e) {
      log("Error starting match: $e");
      Get.snackbar(
        "Error",
        "Failed to start match",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  viewMatch(CreateMatchModel match) {
    // Navigate to match view for non-scorers or general viewing
    Get.toNamed(NAV_MATCH_VIEW, arguments: {"matchId": match.id});
  }

  refreshData() {
    _initializeData();
  }
}
