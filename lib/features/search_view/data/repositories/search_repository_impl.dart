import 'package:cric_live/utils/import_exports.dart';

class SearchRepositoryImpl implements ISearchRepository {
  final ApiServices _apiServices;
  
  SearchRepositoryImpl({required ApiServices apiServices}) 
      : _apiServices = apiServices;

  @override
  Future<SearchResponse> searchContent(
    String query, {
    SearchFilter? filter,
  }) async {
    try {
      // Build the endpoint URL
      String endpoint = '/CL_Matches/Search/${Uri.encodeComponent(query)}';

      // Add filter as query parameter if specified
      if (filter != null && filter != SearchFilter.all) {
        endpoint += '?filter=${filter.apiValue}';
      }

      log(
        '🔍 Searching for: $query with filter: ${filter?.displayName ?? 'All'}',
      );
      log('📡 API Endpoint: $endpoint');

      // Make the API call
      final response = await _apiServices.get(endpoint);

      log('✅ Search API Response received');
      log('📄 Response data: ${response.toString()}');
      
      // Debug: Log raw API response structure
      if (response is Map<String, dynamic>) {
        log('🔍 API Response Structure:');
        response.forEach((key, value) {
          if (value is List && key == 'result') {
            log('   - $key: List with ${value.length} items');
            for (int i = 0; i < value.length && i < 3; i++) {
              log('     Item $i: ${value[i]}');
            }
          } else {
            log('   - $key: $value');
          }
        });
      }

      // Parse the response using SearchResponse model
      // The API returns {message: "Success to fetch", result: [array]}
      final searchResponse = SearchResponse.fromJson(response);

      log('🎯 Parsed ${searchResponse.results.length} search results');

      return searchResponse;
    } catch (e) {
      log('❌ Search API Error: $e');

      // Handle different types of errors
      if (e.toString().contains('No Internet connection')) {
        throw Exception(
          'No internet connection. Please check your network and try again.',
        );
      } else if (e.toString().contains('404')) {
        throw Exception(
          'Search service is currently unavailable. Please try again later.',
        );
      } else if (e.toString().contains('500')) {
        throw Exception('Server error occurred. Please try again later.');
      } else {
        throw Exception('Search failed: ${e.toString()}');
      }
    }
  }

  @override
  Future<List<String>> getSearchSuggestions() async {
    try {
      // You can implement this to get search suggestions from API
      // For now, return default suggestions
      return [
        'IPL 2024',
        'T20 World Cup',
        'Mumbai Indians',
        'Chennai Super Kings',
        'Royal Challengers',
        'Kolkata Knight Riders',
        'Live Matches',
        'Upcoming Tournaments',
        'ODI Matches',
        'Test Matches',
      ];
    } catch (e) {
      log('Error getting search suggestions: $e');
      return [];
    }
  }

  @override
  Future<List<SearchItem>> getRecentSearches() async {
    try {
      // Implement recent searches from local storage
      // For now, return empty list
      // You could use SharedPreferences or local database to store recent searches
      return [];
    } catch (e) {
      log('Error getting recent searches: $e');
      return [];
    }
  }

  // Method to save recent search
  @override
  Future<void> saveRecentSearch(SearchItem item) async {
    try {
      // Implement saving to local storage
      // This could store the search term and result in SharedPreferences or local database
      final prefs = await SharedPreferences.getInstance();

      // Get existing recent searches
      List<String>? recentSearches =
          prefs.getStringList('recent_searches') ?? [];

      // Add new search to the beginning and limit to 10 items
      recentSearches.insert(0, item.title);
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.take(10).toList();
      }

      // Save updated list
      await prefs.setStringList('recent_searches', recentSearches);

      log('💾 Saved recent search: ${item.title}');
    } catch (e) {
      log('Error saving recent search: $e');
    }
  }

  // Method to clear recent searches
  @override
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      log('🗑️ Cleared recent searches');
    } catch (e) {
      log('Error clearing recent searches: $e');
    }
  }

  // Method to get recent search terms (just strings)
  @override
  Future<List<String>> getRecentSearchTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('recent_searches') ?? [];
    } catch (e) {
      log('Error getting recent search terms: $e');
      return [];
    }
  }

  // Method to get popular/trending searches (could be from API)
  @override
  Future<List<String>> getTrendingSearches() async {
    try {
      // This could be fetched from an API endpoint
      // For now, return static trending searches
      return [
        'Live Cricket',
        'Today\'s Matches',
        'IPL 2024',
        'World Cup',
        'India vs Australia',
        'Mumbai Indians',
        'Chennai Super Kings',
      ];
    } catch (e) {
      log('Error getting trending searches: $e');
      return [];
    }
  }

  // Method for advanced search with multiple parameters
  @override
  Future<SearchResponse> advancedSearch({
    required String query,
    SearchFilter? type,
    String? dateFrom,
    String? dateTo,
    String? venue,
    String? format,
    int? limit,
    int? offset,
  }) async {
    try {
      String endpoint = '/CL_Matches/Search/${Uri.encodeComponent(query)}';

      // Build query parameters
      Map<String, String> queryParams = {};

      if (type != null && type != SearchFilter.all) {
        queryParams['filter'] = type.apiValue;
      }
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;
      if (venue != null) queryParams['venue'] = venue;
      if (format != null) queryParams['format'] = format;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      // Add query parameters to endpoint
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      log('🔍 Advanced search endpoint: $endpoint');

      final response = await _apiServices.get(endpoint);
      return SearchResponse.fromJson(response);
    } catch (e) {
      log('❌ Advanced Search API Error: $e');
      throw Exception('Advanced search failed: ${e.toString()}');
    }
  }
}
