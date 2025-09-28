import 'package:cric_live/utils/import_exports.dart';

class MatchView extends StatelessWidget {
  const MatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MatchController>(
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.blue.shade50,
            extendBodyBehindAppBar: false,
            appBar: CommonAppHeader(
              title: controller.isLiveMatch.value ? 'Live Cricket Match' : 'Cricket Match',
              subtitle: 'Match Details',
              leadingIcon: Icons.arrow_back,
              actions: [
                // Live badge - only show when match is live
                Obx(() {
                  if (controller.isLiveMatch.value) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                // Refresh button - only show when match is live
                Obx(() {
                  if (controller.isLiveMatch.value) {
                    return IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      tooltip: 'Refresh match data',
                      onPressed: () {
                        controller.refreshMatchData();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                // Enhanced match info header with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepOrange.shade400,
                        Colors.deepOrange.shade600,
                        Colors.deepOrange.shade700,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Obx(() => _buildMatchInfoHeader(controller)),
                      // Enhanced Tab bar with modern design
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 1,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepOrange.shade400,
                                Colors.deepOrange.shade600,
                                Colors.deepOrange.shade700,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade700,
                          labelStyle: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                          unselectedLabelStyle: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.1,
                          ),
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          splashBorderRadius: BorderRadius.circular(20),
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          tabs: [
                            Tab(
                              height: 44,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.scoreboard_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Scoreboard",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              height: 44,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.analytics_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Statistics",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                // Tab bar view content
                Expanded(
                  child: Obx(() {
                    // Enhanced loading state with modern design
                    if (controller.isLoading.value &&
                        !controller.hasMatchData) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.grey.shade50, Colors.white],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated loading container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepOrange.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(
                                        color: Colors.deepOrange,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.deepOrange
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Icon(
                                      Icons.sports_cricket_rounded,
                                      color: Colors.deepOrange,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Loading Match Data',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Fetching live cricket scores...',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Loading dots animation placeholder
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  3,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.withValues(
                                        alpha: 0.3,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Enhanced error state with better UX
                    if (controller.errorMessage.value.isNotEmpty &&
                        !controller.hasMatchData) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.grey.shade50, Colors.white],
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Error illustration container
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.red.shade50,
                                        Colors.red.shade100,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.red.shade400,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        color: Colors.red.shade300,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  'Connection Failed',
                                  style: GoogleFonts.nunito(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  child: Text(
                                    'Unable to load match data. Please check your internet connection and try again.',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (controller
                                    .errorMessage
                                    .value
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 300,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      controller.errorMessage.value,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 32),
                                // Enhanced retry button
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepOrange.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: controller.refreshMatchData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.refresh_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Try Again',
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Go back button
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Go Back',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Enhanced empty state with modern design
                    if (!controller.hasMatchData) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.grey.shade50, Colors.white],
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Empty state illustration
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade50,
                                        Colors.blue.shade100,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.sports_cricket_rounded,
                                            color: Colors.blue.shade300,
                                            size: 64,
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade300,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'No Data',
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  'No Match Data Available',
                                  style: GoogleFonts.nunito(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  child: Text(
                                    'This match may not have started yet or the data is still being processed. Try refreshing in a moment.',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Action buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Refresh button
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.deepOrange.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: controller.refreshMatchData,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepOrange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 28,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.refresh_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Refresh',
                                              style: GoogleFonts.nunito(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Go back button
                                    OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade700,
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_back_rounded,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Go Back',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Always show content if data is available (even during background updates)
                    return TabBarView(
                      children: [
                        _buildScoreboardTab(controller),
                        _buildPlayerStatsTab(controller),
                      ],
                    );
                  }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///Enhanced scoreboard tab with modern design
  Widget _buildScoreboardTab(MatchController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade50, Colors.white, Colors.white],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          controller.refreshMatchData();
        },
        color: Colors.deepOrange,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 24.0,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Enhanced Match Summary Card
            _buildEnhancedMatchSummaryCard(controller),
            const SizedBox(height: 20),

            // Match Information Card with better spacing
            _buildMatchInfoCard(controller),
            const SizedBox(height: 18),

            // Match Result/Status with enhanced design
            if (controller.resultSummary.isNotEmpty) ...[
              _buildResultCard(controller),
              const SizedBox(height: 16),
            ],

            // Player of the Match with enhanced design
            if (controller.playerOfTheMatch.isNotEmpty) ...[
              _buildPlayerOfMatchCard(controller),
              const SizedBox(height: 16),
            ],

            // Enhanced Match Statistics
            _buildEnhancedMatchStatsCard(controller),
            const SizedBox(height: 20),

            // Team Innings with improved spacing
            if (controller.hasTeamData(1)) ...[
              _buildEnhancedTeamInningsCard(controller, 1),
              const SizedBox(height: 16),
            ],

            if (controller.hasTeamData(2)) ...[
              _buildEnhancedTeamInningsCard(controller, 2),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMatchSummaryCard(MatchController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade300,
            Colors.deepOrange.shade500,
            Colors.deepOrange.shade700,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced match header with match type and status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.matchResult.value?.formatDisplay ?? 'T20 Match',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (controller.matchResult.value?.isLive == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LIVE',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Current over display for live matches
          if (controller.matchResult.value?.isLive == true &&
              controller.matchResult.value?.currentOverDisplay != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_cricket, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'This Over: ${controller.matchResult.value!.currentOverDisplay!}',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Teams and enhanced scores
          LayoutBuilder(
            builder: (context, constraints) {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    _buildEnhancedTeamScoreDisplay(
                      controller.getTeamName(1),
                      controller.getTeamDetailedScore(1),
                      controller.getTeamRunRate(1),
                      true,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VS',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          if (controller.isLive == true) ...[
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LIVE',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildEnhancedTeamScoreDisplay(
                      controller.getTeamName(2),
                      controller.getTeamDetailedScore(2),
                      controller.getTeamRunRate(2),
                      false,
                    ),
                  ],
                ),
              );
            },
          ),

          // Enhanced toss and result info
          if (controller.detailedTossInfo.isNotEmpty ||
              controller.matchResultDescription.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (controller.detailedTossInfo.isNotEmpty)
                    Text(
                      controller.detailedTossInfo,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (controller.detailedTossInfo.isNotEmpty &&
                      controller.matchResultDescription.isNotEmpty)
                    const SizedBox(height: 8),
                  if (controller.matchResultDescription.isNotEmpty)
                    Text(
                      controller.matchResultDescription,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchInfoCard(MatchController controller) {
    final stats = controller.enhancedMatchStats;
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.deepOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Match Information',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    entry.value,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTeamScoreDisplay(
    String teamName,
    String score,
    String runRate,
    bool isLeft,
  ) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teamName,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isLeft ? TextAlign.start : TextAlign.end,
            ),
            const SizedBox(height: 4),
            Text(
              score,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isLeft ? TextAlign.start : TextAlign.end,
            ),
            if (runRate.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                runRate,
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: isLeft ? TextAlign.start : TextAlign.end,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMatchStatsCard(MatchController controller) {
    final matchResult = controller.matchResult.value;
    if (matchResult == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.deepOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Match Statistics',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enhanced statistics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 4.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              if (matchResult.totalRuns != null)
                _buildStatItem(
                  'Total Runs',
                  matchResult.totalRuns.toString(),
                  Icons.sports_cricket,
                ),
              if (matchResult.totalWickets != null)
                _buildStatItem(
                  'Total Wickets',
                  matchResult.totalWickets.toString(),
                  Icons.sports_baseball,
                ),
              if (matchResult.calculatedMatchBoundaries > 0)
                _buildStatItem(
                  'Total 4s',
                  matchResult.calculatedMatchBoundaries.toString(),
                  Icons.crop_free,
                ),
              if (matchResult.calculatedMatchSixes > 0)
                _buildStatItem(
                  'Total 6s',
                  matchResult.calculatedMatchSixes.toString(),
                  Icons.crop_3_2,
                ),
              if (matchResult.calculatedHighestIndividualScore > 0)
                _buildStatItem(
                  'Highest Score',
                  matchResult.calculatedHighestIndividualScore.toString(),
                  Icons.emoji_events,
                ),
              if (matchResult.calculatedHighestTeamScore > 0)
                _buildStatItem(
                  'Highest Team Score',
                  matchResult.calculatedHighestTeamScore.toString(),
                  Icons.groups,
                ),
            ],
          ),

          // Live match specific statistics
          if (matchResult.isLive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Match Stats',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (matchResult.currentBattingTeam != 'Unknown')
                        Expanded(
                          child: Text(
                            'Batting: ${matchResult.currentBattingTeam}',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      if (matchResult.currentBowlingTeam != 'Unknown')
                        Expanded(
                          child: Text(
                            'Bowling: ${matchResult.currentBowlingTeam}',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                  if (matchResult.runsToWin != null &&
                      matchResult.runsToWin! > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.flag, size: 14, color: Colors.red.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Runs needed: ${matchResult.runsToWin}',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                        if (matchResult.ballsRemaining != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Balls left: ${matchResult.ballsRemaining}',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (matchResult.team2RequiredRunRate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.speed, size: 14, color: Colors.red.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Required RR: ${matchResult.team2RequiredRunRate!.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.deepOrange),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.grey.shade800,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(MatchController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.resultSummary,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerOfMatchCard(MatchController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.playerOfTheMatch,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTeamInningsCard(
    MatchController controller,
    int inningNo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    inningNo == 1
                        ? [
                          Colors.deepOrange.shade300,
                          Colors.deepOrange.shade500,
                        ]
                        : [Colors.blue.shade300, Colors.blue.shade500],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                controller.getTeamName(inningNo).isNotEmpty
                    ? controller.getTeamName(inningNo)[0].toUpperCase()
                    : 'T',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.getTeamName(inningNo),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                controller.getTeamDetailedScore(inningNo),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              // Additional team stats with responsive layout
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (controller.getTeamRunRate(inningNo).isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        controller.getTeamRunRate(inningNo),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  if (controller.getTeamRequiredRunRate(inningNo).isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        controller.getTeamRequiredRunRate(inningNo),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          children: [
            _buildBattingTable(controller, inningNo),
            if (controller.getBowlingResults(inningNo).isNotEmpty)
              _buildBowlingTable(controller, inningNo),
          ],
        ),
      ),
    );
  }

  Widget _buildBattingTable(MatchController controller, int inningNo) {
    List<PlayerBattingResultModel> battingResults = controller
        .getBattingResults(inningNo);

    if (battingResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.sports_cricket, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No batting data available',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.sports_cricket, color: Colors.deepOrange, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Batting Performance',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 580),
                  child: DataTable(
                    columnSpacing: 12,
                    headingRowHeight: 48,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 56,
                    headingRowColor: WidgetStateProperty.all(
                      Colors.deepOrange.shade50,
                    ),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    columns: [
                      DataColumn(
                        label: Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: Text(
                            "Batsman",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Runs",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Balls",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "4s",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "6s",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "SR",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                    ],
                    rows:
                        battingResults
                            .map(
                              (player) => _buildBatsmanRow(
                                player.playerName ?? 'Unknown',
                                player.dismissalInfo,
                                (player.runs ?? 0).toString(),
                                (player.balls ?? 0).toString(),
                                (player.fours ?? 0).toString(),
                                (player.sixes ?? 0).toString(),
                                player.strikeRate?.toStringAsFixed(1) ?? '0.0',
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBowlingTable(MatchController controller, int inningNo) {
    List<PlayerBowlingResultModel> bowlingResults = controller
        .getBowlingResults(inningNo);

    if (bowlingResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.sports, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No bowling data available',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.sports, color: Colors.blue.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Bowling Performance',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 480),
                  child: DataTable(
                    columnSpacing: 14,
                    headingRowHeight: 48,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 56,
                    headingRowColor: WidgetStateProperty.all(
                      Colors.blue.shade50,
                    ),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    columns: [
                      DataColumn(
                        label: Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: Text(
                            "Bowler",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Overs",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Runs",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Wickets",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Economy",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                    rows:
                        bowlingResults
                            .map(
                              (player) => _buildBowlerRow(
                                player.playerName ?? 'Unknown',
                                player.oversDisplay,
                                (player.runs ?? 0).toString(),
                                (player.wickets ?? 0).toString(),
                                player.economyRate?.toStringAsFixed(2) ??
                                    '0.00',
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsTab(MatchController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade50, Colors.white, Colors.white],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          controller.refreshMatchData();
        },
        color: Colors.deepOrange,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Overall Match Statistics
            _buildPlayerStatsSummaryCard(controller),
            const SizedBox(height: 16),

            // Team Performance Comparison
            _buildTeamComparisonCard(controller),
            const SizedBox(height: 16),

            // Top Performers
            _buildTopPerformersCard(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatsSummaryCard(MatchController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Match Statistics Summary',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatChip(
                'Total Boundaries',
                '${controller.matchResult.value?.calculatedMatchBoundaries ?? 0}',
                Colors.green,
              ),
              _buildStatChip(
                'Total Sixes',
                '${controller.matchResult.value?.calculatedMatchSixes ?? 0}',
                Colors.purple,
              ),
              _buildStatChip(
                'Highest Score',
                '${controller.matchResult.value?.calculatedHighestIndividualScore ?? 0}',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamComparisonCard(MatchController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Team Performance Comparison',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTeamStatColumn(
                  controller.getTeamName(1).isNotEmpty
                      ? controller.getTeamName(1)
                      : 'Team 1',
                  controller.matchResult.value?.team1Innings?.totalRuns ?? 0,
                  controller.matchResult.value?.team1Innings?.wickets ?? 0,
                  controller.matchResult.value?.team1Innings?.totalBoundaries ??
                      0,
                  controller.matchResult.value?.team1Innings?.totalSixes ?? 0,
                  Colors.blue,
                ),
              ),
              Container(
                width: 1,
                height: 120,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildTeamStatColumn(
                  controller.getTeamName(2).isNotEmpty
                      ? controller.getTeamName(2)
                      : 'Team 2',
                  controller.matchResult.value?.team2Innings?.totalRuns ?? 0,
                  controller.matchResult.value?.team2Innings?.wickets ?? 0,
                  controller.matchResult.value?.team2Innings?.totalBoundaries ??
                      0,
                  controller.matchResult.value?.team2Innings?.totalSixes ?? 0,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersCard(MatchController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.purple.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                'Key Performance Highlights',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildPerformanceItem(
            'Highest Individual Score',
            '${controller.matchResult.value?.calculatedHighestIndividualScore ?? 0}',
            Icons.star,
            Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildPerformanceItem(
            'Highest Team Score',
            '${controller.matchResult.value?.calculatedHighestTeamScore ?? 0}',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildPerformanceItem(
            'Current Run Rate',
            _getCurrentRunRate(controller),
            Icons.speed,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStatColumn(
    String teamName,
    int score,
    int wickets,
    int boundaries,
    int sixes,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          teamName,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          score.toString(),
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          '$wickets wickets',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '4s: $boundaries',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '6s: $sixes',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  DataRow _buildBowlerRow(
    String name,
    String o,
    String r,
    String w,
    String er,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              name,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                o,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              r,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: w != '0' ? Colors.red.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                w,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: w != '0' ? Colors.red.shade700 : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              er,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildBatsmanRow(
    String name,
    String dismissal,
    String r,
    String b,
    String fours,
    String sixes,
    String sr,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (dismissal.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dismissal,
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                r,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.deepOrange.shade700,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              b,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    fours != '0' ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fours,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color:
                      fours != '0'
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    sixes != '0' ? Colors.purple.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                sixes,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color:
                      sixes != '0'
                          ? Colors.purple.shade700
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              sr,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentRunRate(MatchController controller) {
    final matchResult = controller.matchResult.value;
    if (matchResult == null) return '0.00';

    if (matchResult.isLive) {
      // For live matches, use the appropriate current run rate
      if (matchResult.currentInning == 2 && matchResult.team2RunRate != null) {
        return matchResult.team2RunRate!.toStringAsFixed(2);
      } else if (matchResult.currentInning == 1 &&
          matchResult.team1RunRate != null) {
        return matchResult.team1RunRate!.toStringAsFixed(2);
      }
    }

    // For completed matches or fallback, calculate overall run rate
    final totalRuns =
        (matchResult.team1Innings?.totalRuns ?? 0) +
        (matchResult.team2Innings?.totalRuns ?? 0);
    final totalOvers =
        (matchResult.team1Innings?.overs ?? 0) +
        (matchResult.team2Innings?.overs ?? 0);

    if (totalOvers > 0) {
      return (totalRuns / totalOvers).toStringAsFixed(2);
    }

    return '0.00';
  }

  Widget _buildMatchInfoHeader(MatchController controller) {
    if (!controller.hasMatchData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Main info row
          Row(
            children: [
              // Match format and venue
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.matchFormat,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (controller.location.isNotEmpty)
                      Text(
                        controller.location,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Toss info
              if (controller.tossInfo.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: Text(
                    controller.tossInfo,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
            ],
          ),

          // Match IDs row
          const SizedBox(height: 6),
          Row(
            children: [
              // Local Match ID
              if (controller.matchIdDisplay != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tag,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Match ID: ${controller.matchIdDisplay}',
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Online Match ID (if available)
              if (controller.onlineMatchId != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online: ${controller.onlineMatchId}',
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
