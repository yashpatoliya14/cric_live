import 'package:cric_live/utils/import_exports.dart';

class SearchScreenController extends GetxController {
  final ISearchRepository _searchRepository;
  final MatchViewRepo _matchViewRepo = MatchViewRepo();

  final TextEditingController controllerSearch = TextEditingController();

  // Make search text reactive
  final RxString searchText = ''.obs;

  // Observable variables using new models
  final RxList<SearchItem> searchResults = <SearchItem>[].obs;
  final RxMap<String, CompleteMatchResultModel> matchStates =
      <String, CompleteMatchResultModel>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final Rx<SearchFilter> selectedFilter = SearchFilter.all.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalResultsCount = 0.obs;
  final RxList<String> recentSearchTerms = <String>[].obs;
  final RxList<String> trendingSearches = <String>[].obs;
  
  
  // Search cache for better performance
  final Map<String, SearchResponse> _searchCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration cacheExpiry = Duration(minutes: 5);

  // Constructor with dependency injection
  SearchScreenController({required ISearchRepository searchRepository})
    : _searchRepository = searchRepository;

  List<SearchFilter> get searchFilters => SearchFilter.values;

  @override
  void onInit() {
    super.onInit();

    // Add listener to sync text field with reactive variable
    controllerSearch.addListener(() {
      searchText.value = controllerSearch.text;
    });

    // Add debounced search
    debounce(
      searchText,
      _onSearchChanged,
      time: const Duration(milliseconds: 500),
    );
    

    // Load initial data
    _loadInitialData();
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && trimmed.length >= 2) {
      performSearch(trimmed);
    } else if (trimmed.isEmpty) {
      clearSearch();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load recent searches and trending searches
      final recentTerms = await _searchRepository.getRecentSearchTerms();
      final trending = await _searchRepository.getTrendingSearches();

      recentSearchTerms.value = recentTerms;
      trendingSearches.value = trending;
    } catch (e) {
      log('Error loading initial search data: $e');
    }
  }

  Future<void> performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    
    // Check cache first
    final cacheKey = '${q}_${selectedFilter.value.apiValue}';
    if (_searchCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      log('📋 Using cached results for: $q');
      final cachedResponse = _searchCache[cacheKey]!;
      searchResults.value = cachedResponse.results;
      totalResultsCount.value = cachedResponse.totalCount;
      hasSearched.value = true;
      await _fetchMatchStatesForSearchResults(cachedResponse.results);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      hasSearched.value = true;

      log(
        '🔍 Performing search for: $q with filter: ${selectedFilter.value.displayName}',
      );

      // Call the real API
      final response = await _searchRepository.searchContent(
        q,
        filter: selectedFilter.value,
      );

      // Cache the response
      _searchCache[cacheKey] = response;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      searchResults.value = response.results;
      totalResultsCount.value = response.totalCount;

      log('✅ Search completed: ${response.results.length} results found');

      // Fetch detailed match states for search results
      await _fetchMatchStatesForSearchResults(response.results);

      // Save to recent searches if we got results
      if (response.results.isNotEmpty) {
        await _saveSearchTerm(q);
        // Refresh recent search terms
        final updatedRecent = await _searchRepository.getRecentSearchTerms();
        recentSearchTerms.value = updatedRecent;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      log('❌ Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Check if cache is valid
  bool _isCacheValid(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < cacheExpiry;
  }
  
  /// Save search term to recent searches
  Future<void> _saveSearchTerm(String term) async {
    try {
      // Add to recent searches if not already there
      if (!recentSearchTerms.contains(term)) {
        recentSearchTerms.insert(0, term);
        // Keep only last 10 searches
        if (recentSearchTerms.length > 10) {
          recentSearchTerms.removeRange(10, recentSearchTerms.length);
        }
      } else {
        // Move to top if already exists
        recentSearchTerms.remove(term);
        recentSearchTerms.insert(0, term);
      }
    } catch (e) {
      log('Error saving search term: $e');
    }
  }
  
  
  /// Clear cache
  void clearSearchCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    log('Search cache cleared');
  }

  void onFilterChanged(SearchFilter filter) {
    log('🏷️ Filter changed to: ${filter.displayName} (${filter.apiValue})');
    selectedFilter.value = filter;
    log('✅ Selected filter updated: ${selectedFilter.value.displayName}');
    
    // Show user feedback that filter is applied
    Get.snackbar(
      'Filter Applied',
      'Showing ${filter.displayName.toLowerCase()} results',
      backgroundColor: Colors.deepOrange.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(
        Icons.filter_alt,
        color: Colors.white,
        size: 20,
      ),
    );
    
    if (hasSearched.value && controllerSearch.text.isNotEmpty) {
      log('🔄 Re-running search with new filter for: ${controllerSearch.text}');
      // Re-run search with new filter
      performSearch(controllerSearch.text);
    } else {
      log('🆕 Performing new search with filter: ${filter.displayName}');
      // If no previous search, perform a general search with the filter
      // Use a generic search term that should return results for the filter
      String defaultQuery = '';
      switch (filter) {
        case SearchFilter.tournaments:
          defaultQuery = 'tournament';
          break;
        case SearchFilter.matches:
          defaultQuery = 'match';
          break;
        case SearchFilter.live:
          defaultQuery = 'live';
          break;
        case SearchFilter.upcoming:
          defaultQuery = 'upcoming';
          break;
        case SearchFilter.completed:
          defaultQuery = 'completed';
          break;
        default:
          defaultQuery = 'cricket'; // Generic term for 'all'
      }
      performSearch(defaultQuery);
    }
  }

  // Handle search result tap
  void onSearchResultTap(SearchItem item) {
    try {
      if (item is SearchMatch) {
        // Parse matchId to int for navigation - handle string to int conversion
        log('🎯 Navigating to match view: matchId="${item.matchId}"');
        final matchIdInt = int.tryParse(item.matchId) ?? 0;
        log('🔢 Parsed matchId: $matchIdInt');
        if (matchIdInt > 0) {
          log('✅ Navigating to NAV_MATCH_VIEW with matchId: $matchIdInt');
          Get.toNamed(NAV_MATCH_VIEW, arguments: {'matchId': matchIdInt});
        } else {
          log('Invalid matchId: ${item.matchId}');
          Get.snackbar(
            'Navigation Error',
            'Invalid match ID. Cannot open match details.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (item is SearchTournament) {
        // Debug: Log tournament data before navigation
        log('🏆 Tournament Navigation Debug:');
        log('   - Tournament ID: "${item.tournamentId}"');
        log('   - Tournament Title: "${item.title}"');
        log('   - Host ID: ${item.hostId}');
        log('   - Full Tournament Data: ${item.toJson()}');
        
        // Parse tournamentId to int for navigation
        final tournamentIdInt = int.tryParse(item.tournamentId) ?? 0;
        log('   - Parsed Tournament ID as int: $tournamentIdInt');
        
        // Additional validation checks
        if (item.tournamentId.isEmpty) {
          log('❌ Tournament ID is empty!');
          Get.snackbar(
            'Navigation Error',
            'Tournament ID is missing. Cannot open tournament details.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
        if (tournamentIdInt > 0) {
          // Final validation before navigation
          final navigationArgs = {
            "tournamentId": tournamentIdInt,
            "hostId": item.hostId,
            "tournamentName": item.title, // Add tournament name for debugging
            "source": "search", // Add source tracking
          };
          
          log('✅ Navigating to NAV_TOURNAMENT_DISPLAY with:');
          log('   - tournamentId: $tournamentIdInt');
          log('   - hostId: ${item.hostId}');
          log('   - tournamentName: ${item.title}');
          log('   - Full arguments: $navigationArgs');
          
          Get.toNamed(
            NAV_TOURNAMENT_DISPLAY,
            arguments: navigationArgs,
          );
        } else {
          log('❌ Invalid tournamentId: "${item.tournamentId}" could not be parsed to integer');
          Get.snackbar(
            'Navigation Error',
            'Invalid tournament ID "${item.tournamentId}". Cannot open tournament details.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      log('Error navigating to search result: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to open details. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Handle history tap
  void onHistoryTap(SearchItem item) {
    try {
      if (item is SearchMatch) {
        // Parse matchId to int for navigation - handle string to int conversion
        final matchIdInt = int.tryParse(item.matchId) ?? 0;
        if (matchIdInt > 0) {
          Get.toNamed(NAV_RESULT, arguments: {'matchId': matchIdInt});
        } else {
          log('Invalid matchId for history: ${item.matchId}');
          Get.snackbar(
            'Navigation Error',
            'Invalid match ID. Cannot open match history.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (item is SearchTournament) {
        // Parse tournamentId to int for navigation
        final tournamentIdInt = int.tryParse(item.tournamentId) ?? 0;
        if (tournamentIdInt > 0) {
          log(
            '✅ Navigating to NAV_TOURNAMENT_DISPLAY with tournamentId: $tournamentIdInt (history)',
          );
          Get.toNamed(
            NAV_TOURNAMENT_DISPLAY,
            arguments: {'tournamentId': tournamentIdInt, 'showHistory': true},
          );
        } else {
          log('Invalid tournamentId for history: ${item.tournamentId}');
          Get.snackbar(
            'Navigation Error',
            'Invalid tournament ID. Cannot open tournament history.',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      log('Error navigating to history: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to open history. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get search suggestions
  Future<List<String>> getSearchSuggestions() async {
    try {
      return await _searchRepository.getSearchSuggestions();
    } catch (e) {
      log('Error getting search suggestions: $e');
      return [];
    }
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _searchRepository.clearRecentSearches();
      recentSearchTerms.clear();
    } catch (e) {
      log('Error clearing recent searches: $e');
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    if (hasSearched.value && controllerSearch.text.isNotEmpty) {
      await performSearch(controllerSearch.text);
    } else {
      await _loadInitialData();
    }
  }

  void clearSearch() {
    searchResults.clear();
    matchStates.clear();
    hasSearched.value = false;
    errorMessage.value = '';
    totalResultsCount.value = 0;
  }

  /// Fetch detailed match states for search results
  Future<void> _fetchMatchStatesForSearchResults(
    List<SearchItem> results,
  ) async {
    try {
      log(
        '🔍 Fetching detailed match states for ${results.length} search results',
      );

      // Clear existing match states
      matchStates.clear();

      // Fetch detailed state for each match in the search results
      for (var item in results) {
        if (item is SearchMatch) {
          try {
            final matchIdInt = int.tryParse(item.matchId) ?? 0;
            if (matchIdInt > 0) {
              log('📊 Fetching match state for match ID: $matchIdInt');

              // Use the existing MatchViewRepo to get detailed match state
              final matchState = await _matchViewRepo.getMatchState(matchIdInt);

              if (matchState != null) {
                matchStates[item.matchId] = matchState;
                log(
                  '✅ Got match state for match $matchIdInt: ${matchState.team1Name} vs ${matchState.team2Name}',
                );
              } else {
                log('⚠️ No match state found for match $matchIdInt');
              }
            }
          } catch (e) {
            log('❌ Error fetching match state for match ${item.matchId}: $e');
            // Continue with other matches even if one fails
          }
        }
      }

      log(
        '📈 Successfully fetched ${matchStates.length} match states out of ${results.where((r) => r is SearchMatch).length} matches',
      );
    } catch (e) {
      log('❌ Error fetching match states: $e');
      // Don't throw error - search results can still be shown without detailed states
    }
  }

  /// Get match state for a specific match ID
  CompleteMatchResultModel? getMatchState(String matchId) {
    return matchStates[matchId];
  }
  
  /// Test method to verify API connectivity and filter functionality
  Future<void> testFilterAPI(SearchFilter filter) async {
    try {
      log('🧪 Testing API with filter: ${filter.displayName}');
      
      final response = await _searchRepository.searchContent(
        'test',
        filter: filter,
      );
      
      log('✅ API test successful - got ${response.results.length} results');
      log('📊 Filter API response: ${response.message}');
      
    } catch (e) {
      log('❌ API test failed: $e');
      Get.snackbar(
        'API Test Failed',
        'Filter API error: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    controllerSearch.dispose();
    super.onClose();
  }
}
