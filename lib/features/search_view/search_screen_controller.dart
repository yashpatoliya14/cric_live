import 'package:cric_live/utils/import_exports.dart';

class SearchScreenController extends GetxController {
  TextEditingController controllerSearch = TextEditingController();

  // Make search text reactive
  RxString searchText = ''.obs;

  // Observable variables
  RxList<SearchResult> searchResults = <SearchResult>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasSearched = false.obs;
  RxString selectedFilter = 'All'.obs;
  RxString errorMessage = ''.obs;

  List<String> searchFilters = [
    'All',
    'Tournaments',
    'Matches',
    'Teams',
    'Players',
  ];

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
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty && value.length >= 2) {
      performSearch(value);
    } else if (value.isEmpty) {
      clearSearch();
    }
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      hasSearched.value = true;

      // Simulate search results - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      List<SearchResult> results = _generateMockResults(query);
      searchResults.value = _filterResults(results);
    } catch (e) {
      errorMessage.value = 'Search failed: ${e.toString()}';
      log('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<SearchResult> _generateMockResults(String query) {
    // Mock search results - replace with actual data
    return [
      SearchResult(
        title: 'IPL 2024 Tournament',
        subtitle: 'Cricket Tournament • 8 Teams',
        type: 'Tournament',
        icon: Icons.emoji_events,
        onTap: () => log('Tournament tapped'),
      ),
      SearchResult(
        title: 'Mumbai vs Chennai',
        subtitle: 'Live Match • T20 Format',
        type: 'Match',
        icon: Icons.sports_cricket,
        onTap: () => log('Match tapped'),
      ),
      SearchResult(
        title: 'Mumbai Indians',
        subtitle: 'Cricket Team • 15 Players',
        type: 'Team',
        icon: Icons.group,
        onTap: () => log('Team tapped'),
      ),
      SearchResult(
        title: 'Virat Kohli',
        subtitle: 'Batsman • Right Handed',
        type: 'Player',
        icon: Icons.person,
        onTap: () => log('Player tapped'),
      ),
    ];
  }

  List<SearchResult> _filterResults(List<SearchResult> results) {
    if (selectedFilter.value == 'All') {
      return results;
    }
    return results
        .where(
          (result) =>
              result.type.toLowerCase() ==
              selectedFilter.value.toLowerCase().replaceAll('s', ''),
        )
        .toList();
  }

  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    if (hasSearched.value) {
      searchResults.value = _filterResults(
        _generateMockResults(controllerSearch.text),
      );
    }
  }

  void clearSearch() {
    searchResults.clear();
    hasSearched.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    controllerSearch.dispose();
    super.onClose();
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final VoidCallback onTap;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.onTap,
  });
}
