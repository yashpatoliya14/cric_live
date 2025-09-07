import 'dart:developer' as developer;

import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchController extends GetxController {
  late MatchesDisplay _repo;
  late PollingService _pollingService;

  //rx variable
  RxList<MatchModel> matches = <MatchModel>[].obs;
  RxList<CompleteMatchResultModel> matchesState =
      <CompleteMatchResultModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMatches = false.obs;
  RxString error = "".obs;
  RxBool isPollingActive = false.obs;

  // New section toggle variables
  RxString selectedSection = "matches".obs; // "matches" or "tournaments"
  RxList tournaments = [].obs; // For tournaments data

  ///on init function
  @override
  void onInit() {
    super.onInit();
    _repo = MatchesDisplay();
    //Todo: might error occur
    _loadInitialMatches();
    _pollingService = PollingService();
    _pollingService.startPolling(fn: () => getMatchesState(), seconds: 60);
    _pollingService.startPolling(fn: () => getMatches(), seconds: 60);
  }

  Future<void> getMatches() async {
    try {
      final data = await _repo.getLiveMatches();
      if (data != null) {
        matches.assignAll(data);
        matches.refresh();

        // Extract match state data for display
        await _processMatchStates();
      }
    } catch (e) {
      error.value = e.toString();
      developer.log('Error in getMatches: $e');
    }
  }

  /// Process matches to extract their state data
  Future<void> _processMatchStates() async {
    try {
      List<CompleteMatchResultModel> states = [];

      for (MatchModel match in matches) {
        if (match.matchState != null) {
          try {
            // The matchState should already be parsed as Map in MatchesDisplay.getLiveMatches()
            CompleteMatchResultModel? state = match.matchState;
            if (state != null) {
              states.add(state);
            }
          } catch (e) {
            developer.log(
              'Error processing match state for match ${match.id}: $e',
            );
            // Create a basic state for matches without proper state data
            states.add(CompleteMatchResultModel());
          }
        } else {
          developer.log('No match state data for match ${match.id}');
          states.add(CompleteMatchResultModel());
        }
      }

      matchesState.assignAll(states);
      matchesState.refresh();
      developer.log('Processed ${states.length} match states');
    } catch (e) {
      developer.log('Error in _processMatchStates: $e');
    }
  }

  /// Load initial matches using simple approach
  Future<void> _loadInitialMatches() async {
    try {
      isLoading.value = true;
      error.value = "";
      matches.clear();
      matchesState.clear();

      await getMatches();

      hasMatches.value = matchesState.isNotEmpty;
    } catch (e) {
      error.value = e.toString();
      developer.log('Error loading initial matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMatchesState() async {
    try {
      isLoading.value = true;
      error.value = "";

      await _loadInitialMatches();
      return;
    } catch (e) {
      error.value = e.toString();
      developer.log('Error in manual refresh: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch between matches and tournaments section
  void switchSection(String section) {
    selectedSection.value = section;
    if (section == "tournaments") {
      fetchTournaments();
    } else {
      getMatchesState();
    }
  }

  /// Fetch tournaments - API call placeholder
  Future<void> fetchTournaments() async {
    try {
      isLoading.value = true;
      error.value = "";

      // TODO: Implement API call to fetch tournaments
      // For now, using placeholder data
      await Future.delayed(const Duration(seconds: 1));

      // Placeholder tournament data
      tournaments.assignAll([
        {
          'id': 1,
          'name': 'Summer Cricket League 2024',
          'status': 'ongoing',
          'teams': 8,
          'matches': 15,
          'startDate': '2024-01-15',
          'venue': 'National Stadium',
        },
        {
          'id': 2,
          'name': 'Champions Trophy',
          'status': 'upcoming',
          'teams': 4,
          'matches': 6,
          'startDate': '2024-02-01',
          'venue': 'Central Ground',
        },
        {
          'id': 3,
          'name': 'Local Club Championship',
          'status': 'completed',
          'teams': 6,
          'matches': 10,
          'startDate': '2023-12-01',
          'venue': 'City Sports Complex',
        },
      ]);
    } catch (e) {
      error.value = e.toString();
      developer.log('Error fetching tournaments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _pollingService.stopPolling();
    super.onClose();
  }
}
