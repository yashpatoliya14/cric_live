import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchView extends StatefulWidget {
  const DisplayLiveMatchView({super.key});

  @override
  State<DisplayLiveMatchView> createState() => _DisplayLiveMatchViewState();
}

class _DisplayLiveMatchViewState extends State<DisplayLiveMatchView> {
  late ScrollController _scrollController;
  late DisplayLiveMatchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DisplayLiveMatchController>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      _controller.loadMoreMatches();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          // Content area
          Expanded(
            child: Obx(
              () => RefreshIndicator(
                onRefresh: () async {
                  await _controller.forceRefresh();
                },
                color: Colors.deepOrange,
                child: _buildReactiveBody(context, _controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reactive body with live update indicators
  Widget _buildReactiveBody(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
    return Column(
      children: [
        // Live update status bar (only show when refreshing manually)
        if (controller.isRefreshing.value)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.deepOrange.shade100, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange.shade400),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Updating live matches...',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ],
            ),
          ),
        
        // Main content
        Expanded(
          child: _buildBody(context, controller),
        ),
        
        // Live polling indicator at bottom (subtle)
        if (controller.isPollingActive.value && !controller.isInitialLoading.value)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(
                top: BorderSide(color: Colors.green.shade100, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Live updates active',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
    // Only show full screen loader on initial load
    if (controller.isInitialLoading.value) {
      return _buildLoadingView(context);
    }

    // Handle error state (only if we have no data to show)
    if (controller.error.value.isNotEmpty && controller.matches.isEmpty) {
      return _buildErrorView(context, controller);
    }

    // Show matches content (with reactive updates)
    return _buildMatchesContent(context, controller);
  }

  Widget _buildMatchesContent(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
    // Handle empty state - check both matches and matchesState
    if (controller.matches.isEmpty && controller.matchesState.isEmpty) {
      return _buildEmptyView(context, controller);
    }

    // If we have matches but no match states, use basic match data
    if (controller.matches.isNotEmpty && controller.matchesState.isEmpty) {
      return _buildPaginatedMatchesList(
        controller,
        itemBuilder: (context, index) {
          if (index >= controller.matches.length) {
            return _buildPaginationLoader(controller);
          }
          final match = controller.matches[index];
          return _buildBasicMatchCard(context, match);
        },
        itemCount: controller.matches.length + (controller.hasMoreMatches.value ? 1 : 0),
      );
    }

    // Show matches with complete state data
    return _buildPaginatedMatchesList(
      controller,
      itemBuilder: (context, index) {
        if (index >= controller.matchesState.length) {
          return _buildPaginationLoader(controller);
        }
        final matchState = controller.matchesState[index];
        final match = controller.matches[index];
        return _buildModernMatchCard(context, matchState, match);
      },
      itemCount: controller.matchesState.length + (controller.hasMoreMatches.value ? 1 : 0),
    );
  }

  Widget _buildModernMatchCard(
    BuildContext context,
    dynamic match,
    dynamic matchData,
  ) {
    return UniversalMatchTile(
      matchData: match ?? matchData,
      displayMode: MatchTileDisplayMode.live,
      onTap: () => Get.toNamed(
        NAV_MATCH_VIEW,
        arguments: {
          'matchId': matchData?.id ?? match?.id,
          'isLive': true,
        },
      ),
      showHistory: false, // No history button in live view
      showMatchIds: true, // Show IDs for debugging/tracking
      showTimeline: true, // Show timeline indicator
      statusColor: _getStatusColorLive(
        (match?.status ?? matchData?.status ?? 'unknown').toString().toLowerCase(),
      ),
    );
  }

  /// Basic match card for when detailed state data is not available
  Widget _buildBasicMatchCard(BuildContext context, MatchModel match) {
    final status = match.status?.toLowerCase() ?? 'unknown';

    return UniversalMatchTile(
      matchData: match,
      displayMode: MatchTileDisplayMode.live,
      onTap: () => Get.toNamed(
        NAV_MATCH_VIEW,
        arguments: {'matchId': match.id, 'isLive': true},
      ),
      showHistory: false, // No history button in live view
      showMatchIds: true, // Show IDs for debugging/tracking
      showTimeline: true, // Show timeline indicator
      statusColor: _getStatusColorLive(status),
    );
  }

  /// Build paginated matches list with scroll controller
  Widget _buildPaginatedMatchesList(
    DisplayLiveMatchController controller, {
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
  }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemBuilder: itemBuilder,
      itemCount: itemCount,
    );
  }

  /// Build pagination loader widget
  Widget _buildPaginationLoader(DisplayLiveMatchController controller) {
    if (!controller.hasMoreMatches.value) {
      return const SizedBox.shrink(); // Don't show anything if no more matches
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      alignment: Alignment.center,
      child: Obx(() => controller.isLoadingMore.value
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange.shade400),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading more matches...',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink()),
    );
  }





  Widget _buildLoadingView(BuildContext context) {
    return const FullScreenLoader(
      message: 'Loading live matches...',
      loaderColor: Colors.deepOrange,
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load live matches. Please check your internet connection.',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await controller.forceRefresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.deepOrange.shade100,
                    Colors.deepOrange.shade50.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sports_cricket,
                  size: 64,
                  color: Colors.deepOrange.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Live Matches',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no live matches at the moment.\nCreate a new match to get started!',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.forceRefresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Refresh',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(NAV_CREATE_MATCH),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create Match',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Map live status to color similar to history view
  Color _getStatusColorLive(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade400;
      case 'live':
        return Colors.red.shade400;
      case 'scheduled':
        return Colors.blue.shade400;
      case 'resume':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
