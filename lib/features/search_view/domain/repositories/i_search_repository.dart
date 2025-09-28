import 'package:cric_live/features/search_view/data/models/search_models.dart';

/// Domain layer interface for search repository
/// This defines the contract that the data layer must implement
abstract class ISearchRepository {
  /// Search for content with optional filters
  Future<SearchResponse> searchContent(String query, {SearchFilter? filter});
  
  /// Get search suggestions based on popular/trending searches
  Future<List<String>> getSearchSuggestions();
  
  /// Get recent searches from local storage
  Future<List<SearchItem>> getRecentSearches();
  
  /// Save a search term to recent searches
  Future<void> saveRecentSearch(SearchItem item);
  
  /// Clear all recent searches
  Future<void> clearRecentSearches();
  
  /// Get recent search terms (just strings)
  Future<List<String>> getRecentSearchTerms();
  
  /// Get popular/trending searches
  Future<List<String>> getTrendingSearches();
  
  /// Advanced search with multiple parameters
  Future<SearchResponse> advancedSearch({
    required String query,
    SearchFilter? type,
    String? dateFrom,
    String? dateTo,
    String? venue,
    String? format,
    int? limit,
    int? offset,
  });
}