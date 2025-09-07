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

  Future<CreateMatchModel?> getMatch(int matchId) async {
    return await _createMatchRepo.getMatchById(matchId);
  }

  navScheduled(int matchId) async {
    CreateMatchModel? model = await getMatch(matchId);
    if (model == null) {
      error.value = "match not found please create new match";
    } else {
      Get.toNamed(NAV_CREATE_MATCH, arguments: {'matchId': model.id});
    }
  }

  navResume(MatchModel match) async {
    if (match.matchState == null) {
      getSnackBar(title: "match is not found", message: "create a new match");
    }
    Get.toNamed(
      NAV_SCOREBOARD,
      arguments: {'matchId': match.matchState!.matchId},
    );
  }

  Future<void> getMatches() async {
    try {
      final fetchedMatches = await _repo.getUsersMatches();
      matches.assignAll(
        (fetchedMatches ?? []).where((match) {
          // Only show completed matches in history
          bool isCompleted =
              match.status?.toLowerCase() == 'completed' ||
              match.status?.toLowerCase() == 'scheduled' ||
              match.status?.toLowerCase() == 'resume';
          // Ensure match has meaningful state data
          bool hasMatchState =
              match.matchState != null || match.status == "scheduled";

          return isCompleted && hasMatchState;
        }).toList(),
      );
      matches.refresh();
      log('Filtered matches for history: ${matches.length}');
    } catch (e) {
      error.value = e.toString();
      log('Error in getMatches: ${e.toString()}');
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

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
