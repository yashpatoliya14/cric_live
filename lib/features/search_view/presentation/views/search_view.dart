import 'package:cric_live/utils/import_exports.dart';

class SearchScreenView extends GetView<SearchScreenController> {
  const SearchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.find() since controller is registered in binding
    // GetView automatically provides the controller via the 'controller' getter

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
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBar: const CommonAppHeader(
        title: 'Search',
        subtitle: 'Find tournaments, matches & teams',
        leadingIcon: Icons.search,
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _buildSearchSection(controller),
              _buildFilterSection(controller),
              Expanded(
                child: Obx(
                  () => RefreshIndicator(
                    onRefresh: () => controller.refreshData(),
                    color: Colors.deepOrange,
                    backgroundColor: Colors.white,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _buildSearchResults(controller),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSearchSection(SearchScreenController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          // Enhanced search bar with modern design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.deepOrange.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Animated search icon
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: controller.searchText.value.isNotEmpty
                        ? Colors.deepOrange.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    controller.isLoading.value ? Icons.hourglass_empty : Icons.search,
                    color: controller.searchText.value.isNotEmpty
                        ? Colors.deepOrange
                        : Colors.grey[500],
                    size: 22,
                  ),
                )),
                const SizedBox(width: 16),
                // Enhanced text field
                Expanded(
                  child: TextField(
                    controller: controller.controllerSearch,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search tournaments, matches, teams...",
                      hintStyle: GoogleFonts.nunito(
                        color: Colors.grey[400],
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      controller.searchText.value = value;
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.performSearch(value.trim());
                      }
                    },
                  ),
                ),
                // Enhanced action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clear/Search button
                    Obx(() {
                      if (controller.searchText.value.isNotEmpty) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            onPressed: () {
                              controller.controllerSearch.clear();
                              controller.clearSearch();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            tooltip: 'Clear',
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterSection(SearchScreenController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header with result count
          Obx(() => controller.hasSearched.value ? 
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  if (controller.totalResultsCount.value > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.totalResultsCount.value} results',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange[700],
                        ),
                      ),
                    ),
                ],
              ),
            ) : const SizedBox.shrink(),
          ),
          
          // Enhanced filter chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.searchFilters.length,
              itemBuilder: (context, index) {
                SearchFilter filter = controller.searchFilters[index];
                
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Obx(
                    () {
                      bool isSelected = controller.selectedFilter.value == filter;
                      
                      return GestureDetector(
                        onTap: () {
                          print('🖱️ Filter chip tapped: ${filter.displayName}');
                          controller.onFilterChanged(filter);
                        },
                        onLongPress: () {
                          print('🧪 Long press detected - testing API for: ${filter.displayName}');
                          controller.testFilterAPI(filter);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? LinearGradient(
                              colors: [Colors.deepOrange, Colors.orange[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ) : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.deepOrange.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFilterIcon(filter),
                                size: 16,
                                color: isSelected ? Colors.white : Colors.deepOrange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                filter.displayName,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.deepOrange,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getFilterIcon(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return Icons.apps;
      case SearchFilter.tournaments:
        return Icons.emoji_events;
      case SearchFilter.matches:
        return Icons.sports_cricket;
      case SearchFilter.live:
        return Icons.radio_button_checked;
      case SearchFilter.upcoming:
        return Icons.schedule;
      case SearchFilter.completed:
        return Icons.check_circle;
    }
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
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced loading animation
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  strokeWidth: 3,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Icon(
                      Icons.search,
                      size: 24,
                      color: Colors.deepOrange.withOpacity(0.7),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Searching...',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding the best results for you',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SearchScreenController controller) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
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
              color: Colors.red.withValues(alpha: 0.7),
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
    return SingleChildScrollView(
      key: const ValueKey('initial'),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated search illustration
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.withOpacity(0.15),
                          Colors.orange.withOpacity(0.10),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search,
                      size: 56,
                      color: Colors.deepOrange,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Discover Cricket",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Search for tournaments, live matches,\nteams, and players",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            // Quick action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.emoji_events,
                  label: 'Tournaments',
                  color: Colors.purple,
                  onTap: () {
                    // Set filter to tournaments and focus search
                    // controller.selectedFilter.value = SearchFilter.tournaments;
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.sports_cricket,
                  label: 'Live Matches',
                  color: Colors.red,
                  onTap: () {
                    // Set filter to live and focus search
                    // controller.selectedFilter.value = SearchFilter.live;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(SearchScreenController controller) {
    return SingleChildScrollView(
      key: const ValueKey('empty'),
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated empty illustration
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 52,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              "No Results Found",
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                "'${controller.searchText.value}'",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "We couldn't find any matches\nfor your search term",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Search suggestions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, 
                        size: 20, 
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Suggestions",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "• Try different keywords\n• Check your spelling\n• Use broader terms\n• Remove some filters",
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.blue[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchScreenController controller) {
    return Column(
      key: const ValueKey('results'),
      children: [
        // Results count header
        if (controller.totalResultsCount.value > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${controller.totalResultsCount.value} results found',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  'for "${controller.searchText.value}"',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              SearchItem item = controller.searchResults[index];
              
              // Get enhanced match state for matches
              CompleteMatchResultModel? matchState;
              if (item is SearchMatch) {
                matchState = controller.getMatchState(item.matchId);
              }
              
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: SearchResultTile(
                      searchItem: item,
                      matchState: matchState, // Pass enhanced match state
                      showHistory: true, // Enable history section
                      onTap: () => controller.onSearchResultTap(item),
                      onHistoryTap: () => controller.onHistoryTap(item),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
            color: Colors.grey.withValues(alpha: 0.2),
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
                    color: color.withValues(alpha: 0.1),
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
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
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
              color: Colors.red.withValues(alpha: 0.7),
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
