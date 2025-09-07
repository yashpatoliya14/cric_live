import 'package:cric_live/utils/import_exports.dart';

class SearchScreenView extends StatelessWidget {
  const SearchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchScreenController());

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.bottomSheet(
            _buildQuickActionSheet(controller),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          );
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: 20),
        label: Text(
          "Create",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                expandedHeight: 140,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: _buildEnhancedTitle(),
                  titlePadding: const EdgeInsets.only(
                    left: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  centerTitle: false,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepOrange.shade400,
                          Colors.deepOrange.shade600,
                          Colors.deepOrange.shade800,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background search elements
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Icon(
                            Icons.search,
                            size: 120,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.filter_list,
                            size: 80,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        body: Column(
          children: [
            _buildSearchSection(controller),
            _buildFilterSection(controller),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: () async {
                    if (controller.hasSearched.value &&
                        controller.controllerSearch.text.isNotEmpty) {
                      await controller.performSearch(
                        controller.controllerSearch.text,
                      );
                    }
                  },
                  color: Colors.deepOrange,
                  backgroundColor: Colors.white,
                  child: _buildSearchResults(controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTitle() {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                APPBAR_SEARCH,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Find tournaments, matches, teams",
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(SearchScreenController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.deepOrange.withOpacity(0.7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller.controllerSearch,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "Search tournaments, matches, teams, players...",
                      hintStyle: GoogleFonts.nunito(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        controller.performSearch(value);
                      }
                    },
                  ),
                ),
                Obx(
                  () =>
                      controller.searchText.value.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              controller.controllerSearch.clear();
                              controller.clearSearch();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // Search suggestions
          Obx(
            () =>
                controller.searchText.value.isNotEmpty &&
                        !controller.hasSearched.value
                    ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Suggestions",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children:
                                _getSearchSuggestions()
                                    .map(
                                      (suggestion) => InkWell(
                                        onTap: () {
                                          controller.controllerSearch.text =
                                              suggestion;
                                          controller.performSearch(suggestion);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            suggestion,
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  List<String> _getSearchSuggestions() {
    return [
      'IPL 2024',
      'T20 World Cup',
      'Mumbai Indians',
      'Chennai Super Kings',
      'Virat Kohli',
      'MS Dhoni',
    ];
  }

  Widget _buildFilterSection(SearchScreenController controller) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.searchFilters.length,
          itemBuilder: (context, index) {
            String filter = controller.searchFilters[index];
            bool isSelected = controller.selectedFilter.value == filter;

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(
                  filter,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.deepOrange,
                    height: 1.0,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => controller.onFilterChanged(filter),
                backgroundColor: Colors.white,
                selectedColor: Colors.deepOrange,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color:
                      isSelected
                          ? Colors.deepOrange
                          : Colors.deepOrange.withOpacity(0.3),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchScreenController controller) {
    try {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState(controller);
      }

      if (!controller.hasSearched.value) {
        return _buildInitialState();
      }

      if (controller.searchResults.isEmpty) {
        return _buildEmptyState(controller);
      }

      return _buildResultsList(controller);
    } catch (e) {
      return _buildErrorStateWithMessage('An unexpected search error occurred');
    }
  }

  Widget _buildLoadingState() {
    return const FullScreenLoader(
      message: 'Searching...',
      loaderColor: Colors.deepOrange,
    );
  }

  Widget _buildErrorState(SearchScreenController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              "Search Failed",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  () => controller.performSearch(
                    controller.controllerSearch.text,
                  ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                "Try Again",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 48,
                color: Colors.deepOrange.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Start Your Search",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter at least 2 characters to search for\ntournaments, matches, teams, or players",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(SearchScreenController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Results Found",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find anything matching\n'${controller.searchText.value}'",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Try different keywords or check filters",
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchScreenController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        SearchResult result = controller.searchResults[index];
        return _buildResultCard(result, index);
      },
    );
  }

  Widget _buildResultCard(SearchResult result, int index) {
    Color iconColor = _getIconColor(result.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            result.onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(result.icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.type,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return Colors.purple;
      case 'match':
        return Colors.green;
      case 'team':
        return Colors.blue;
      case 'player':
        return Colors.orange;
      default:
        return Colors.deepOrange;
    }
  }

  Widget _buildQuickActionSheet(SearchScreenController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Quick Actions",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              height: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildActionTile(
            icon: Icons.emoji_events,
            title: "Create Tournament",
            subtitle: "Organize a new cricket tournament",
            color: Colors.purple,
            onTap: () {
              Get.back();
              Get.toNamed(NAV_CREATE_TOURNAMENT);
            },
          ),
          _buildActionTile(
            icon: Icons.sports_cricket,
            title: "Create Match",
            subtitle: "Start a new cricket match",
            color: Colors.green,
            onTap: () {
              Get.back();
              Get.toNamed(NAV_CREATE_MATCH);
            },
          ),
          _buildActionTile(
            icon: Icons.group,
            title: "Create Team",
            subtitle: "Build your cricket team",
            color: Colors.blue,
            onTap: () {
              Get.back();
              Get.toNamed(NAV_CREATE_TEAM);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorStateWithMessage(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              "Search Error",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
