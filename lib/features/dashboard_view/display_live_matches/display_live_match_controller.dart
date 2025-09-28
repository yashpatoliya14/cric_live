import 'dart:developer' as developer;

import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchController extends GetxController {
  late MatchesDisplay _repo;
  late PollingService _pollingService;
  late PreloadService _preloadService;

  //rx variable
  RxList<MatchModel> matches = <MatchModel>[].obs;
  RxList<CompleteMatchResultModel> matchesState =
      <CompleteMatchResultModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isInitialLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxBool hasMatches = false.obs;
  RxString error = "".obs;
  RxBool isPollingActive = false.obs;
  
  // Pagination variables
  RxInt currentMatchOffset = 0.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreMatches = true.obs;
  final int matchesPerPage = 5;

  // New section toggle variables
  RxString selectedSection = "matches".obs; // "matches" or "tournaments"
  RxList tournaments = [].obs; // For tournaments data

  ///on init function
  @override
  void onInit() {
    super.onInit();
    _repo = MatchesDisplay();
    _preloadService = Get.find<PreloadService>();
    
    // Check if we have preloaded data first
    _checkPreloadedData();
    
    _pollingService = PollingService();
    _pollingService.startPolling(fn: () => getMatchesState(), seconds: 60);
    _pollingService.startPolling(fn: () => getMatches(), seconds: 60);
  }

  Future<void> getMatches() async {
    try {
      // Reset pagination state for fresh load
      currentMatchOffset.value = 0;
      hasMoreMatches.value = true;
      
      final data = await _repo.getLiveMatchPaginated(
        from: currentMatchOffset.value,
        limit: matchesPerPage,
      );
      
      if (data != null) {
        matches.assignAll(data);
        matches.refresh();
        
        // Update pagination state
        currentMatchOffset.value = data.length;
        hasMoreMatches.value = data.length >= matchesPerPage;
        
        developer.log('Loaded ${data.length} matches, hasMore: ${hasMoreMatches.value}');

        // Extract match state data for display
        await _processMatchStates();
      } else {
        matches.clear();
        hasMoreMatches.value = false;
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

  /// Check and use preloaded data if available
  Future<void> _checkPreloadedData() async {
    try {
      if (_preloadService.hasPreloadedMatches) {
        developer.log('Using preloaded match data');
        
        // Use preloaded data
        final preloadedMatches = _preloadService.preloadedMatches;
        if (preloadedMatches != null && preloadedMatches.isNotEmpty) {
          matches.assignAll(preloadedMatches);
          matches.refresh();
          
          // Process match states from preloaded data
          await _processMatchStates();
          hasMatches.value = matchesState.isNotEmpty;
          
          developer.log('Loaded ${preloadedMatches.length} preloaded matches');
          return; // Exit early if we have preloaded data
        }
      }
      
      // Fall back to loading fresh data if no preloaded data available
      developer.log('No preloaded data available, loading fresh matches');
      await _loadInitialMatches();
    } catch (e) {
      error.value = e.toString();
      developer.log('Error checking preloaded data: $e');
      // Fall back to loading fresh data
      await _loadInitialMatches();
    }
  }

  /// Load initial matches using simple approach
  Future<void> _loadInitialMatches() async {
    try {
      isInitialLoading.value = true;
      error.value = "";
      matches.clear();
      matchesState.clear();

      await getMatches();

      hasMatches.value = matchesState.isNotEmpty;
    } catch (e) {
      error.value = e.toString();
      developer.log('Error loading initial matches: $e');
    } finally {
      isInitialLoading.value = false;
    }
  }

  /// Force refresh all data
  Future<void> forceRefresh() async {
    try {
      isRefreshing.value = true;
      error.value = "";
      matches.clear();
      matchesState.clear();

      await getMatches();

      hasMatches.value = matchesState.isNotEmpty;
    } catch (e) {
      error.value = e.toString();
      developer.log('Error in force refresh: $e');
    } finally {
      isRefreshing.value = false;
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

  /// Load more matches for pagination
  Future<void> loadMoreMatches() async {
    // Prevent multiple simultaneous requests and check if more matches are available
    if (isLoadingMore.value || !hasMoreMatches.value) {
      developer.log('LoadMore skipped: isLoadingMore=${isLoadingMore.value}, hasMore=${hasMoreMatches.value}');
      return;
    }

    try {
      isLoadingMore.value = true;
      error.value = "";
      
      developer.log('Loading more matches from offset: ${currentMatchOffset.value}');

      final data = await _repo.getLiveMatchPaginated(
        from: currentMatchOffset.value,
        limit: matchesPerPage,
      );

      if (data != null && data.isNotEmpty) {
        // Append new matches to existing list
        final existingMatches = List<MatchModel>.from(matches);
        existingMatches.addAll(data);
        matches.assignAll(existingMatches);
        matches.refresh();

        // Update pagination state
        currentMatchOffset.value += data.length;
        hasMoreMatches.value = data.length >= matchesPerPage;
        
        developer.log('Loaded ${data.length} more matches, total: ${matches.length}, hasMore: ${hasMoreMatches.value}');

        // Process match states for new matches
        await _processMatchStates();
        hasMatches.value = matchesState.isNotEmpty;
      } else {
        // No more matches available
        hasMoreMatches.value = false;
        developer.log('No more matches available');
      }
    } catch (e) {
      error.value = e.toString();
      developer.log('Error in loadMoreMatches: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    _pollingService.stopPolling();
    super.onClose();
  }
}
