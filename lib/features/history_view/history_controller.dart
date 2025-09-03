import 'package:cric_live/features/dashboard_view/dashboard_repo.dart';
import 'package:cric_live/utils/import_exports.dart';

class HistoryController extends GetxController {
  late DashboardRepo _repo;
  RxList<CreateMatchModel> matches = <CreateMatchModel>[].obs;

  //rx variable
  RxList<CompleteMatchResultModel> matchesState =
      <CompleteMatchResultModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMatches = false.obs;
  RxString error = "".obs;
  @override
  void onInit() {
    super.onInit();
    _repo = DashboardRepo();

    //load users matches initially
    getMatches();
    getMatchesState();
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
              match.status?.toLowerCase() == 'live';
          // Ensure match has meaningful state data
          bool hasMatchState =
              match.matchState != null &&
              match.matchState!.trim().isNotEmpty &&
              match.matchState != '{}';

          log(
            'Match ${match.id}: status=${match.status}, hasMatchState=$hasMatchState, matchState=${match.matchState}',
          );

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

  Future<void> getMatchesState() async {
    try {
      isLoading.value = true;
      error.value = "";
      matchesState.clear();

      await getMatches(); // loads and filters

      log('Processing ${matches.length} matches for history display');

      for (CreateMatchModel match in matches) {
        log('Processing match ${match.id} with status: ${match.status}');
        final data = await _repo.getLiveMatchesState(match);
        if (data != null) {
          log('Successfully processed match ${match.id}: ${data.matchSummary}');
          matchesState.add(data);
        } else {
          log('Failed to get match state for match ${match.id}');
        }
      }

      hasMatches.value = matchesState.isNotEmpty;
      log('Final history matches count: ${matchesState.length}');
      matchesState.refresh();
    } catch (e) {
      error.value = e.toString();
      log('Error in getMatchesState: ${e.toString()}');
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
