import 'package:cric_live/features/match_view/match_controller.dart';
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
            appBar: AppBar(
              title: Obx(
                () => Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.dynamicMatchTitle,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (controller.matchSubtitle.isNotEmpty)
                        Text(
                          controller.matchSubtitle,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                if (controller.isLive == true)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => controller.refreshMatchData(),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Match info header
                    Obx(() => _buildMatchInfoHeader(controller)),
                    // Tab bar
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange.shade400,
                              Colors.deepOrange.shade600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        labelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.scoreboard, size: 16),
                                SizedBox(width: 6),
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
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timeline, size: 16),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "Overs",
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
            ),
            body: Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: const FullScreenLoader(
                    message:
                        'Loading match details...\nPlease wait while we fetch the latest data',
                    loaderColor: Colors.deepOrange,
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Oops! Something went wrong',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage.value,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
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
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Try Again',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (!controller.hasMatchData) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.sports_cricket,
                              color: Colors.grey.shade600,
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Match Data Available',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This match doesn\'t have any data yet.\nCheck back later for updates.',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
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
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Refresh',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.only(top: 8),
                child: TabBarView(
                  children: [
                    _buildScoreboardTab(controller),
                    _buildOversTab(controller),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  ///first page
  Widget _buildScoreboardTab(MatchController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          controller.refreshMatchData();
        },
        color: Colors.deepOrange,
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: 16.0,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Match Summary Card
            _buildEnhancedMatchSummaryCard(controller),
            const SizedBox(height: 16),

            // Match Information Card
            _buildMatchInfoCard(controller),
            const SizedBox(height: 16),

            // Match Result/Status
            if (controller.resultSummary.isNotEmpty)
              _buildResultCard(controller),

            // Player of the Match
            if (controller.playerOfTheMatch.isNotEmpty)
              _buildPlayerOfMatchCard(controller),

            // Enhanced Match Statistics
            _buildEnhancedMatchStatsCard(controller),
            const SizedBox(height: 16),

            // Team 1 Innings
            if (controller.hasTeamData(1))
              _buildEnhancedTeamInningsCard(controller, 1),

            // Team 2 Innings
            if (controller.hasTeamData(2))
              _buildEnhancedTeamInningsCard(controller, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMatchSummaryCard(MatchController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced match header with detailed info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.detailedMatchInfo,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Teams and enhanced scores
          IntrinsicHeight(
            child: Row(
              children: [
                _buildEnhancedTeamScoreDisplay(
                  controller.getTeamName(1),
                  controller.getTeamDetailedScore(1),
                  controller.getTeamRunRate(1),
                  true,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VS',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      if (controller.isLive == true)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LIVE',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 8,
                            ),
                          ),
                        ),
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
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
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
                fontSize: 14,
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
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isLeft ? TextAlign.start : TextAlign.end,
            ),
            if (runRate.isNotEmpty)
              Text(
                runRate,
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: isLeft ? TextAlign.start : TextAlign.end,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMatchStatsCard(MatchController controller) {
    final stats = controller.matchStatistics;
    if (stats.isEmpty) return const SizedBox.shrink();

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
          const SizedBox(height: 16),
          // Grid layout for better organization
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final crossAxisCount = availableWidth > 350 ? 2 : 1;
              final childAspectRatio = availableWidth > 350 ? 3.2 : 5.0;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  _buildStatItem(
                    'Total Runs',
                    stats['totalRuns'].toString(),
                    Icons.sports_cricket,
                  ),
                  _buildStatItem(
                    'Total Wickets',
                    stats['totalWickets'].toString(),
                    Icons.close,
                  ),
                  _buildStatItem(
                    'Boundaries',
                    stats['totalBoundaries'].toString(),
                    Icons.arrow_forward,
                  ),
                  _buildStatItem(
                    'Sixes',
                    stats['totalSixes'].toString(),
                    Icons.keyboard_double_arrow_up,
                  ),
                  if (stats['highestScore'] > 0)
                    _buildStatItem(
                      'Highest Score',
                      stats['highestScore'].toString(),
                      Icons.star,
                    ),
                  if (stats['highestTeamScore'] > 0)
                    _buildStatItem(
                      'Highest Team Score',
                      stats['highestTeamScore'].toString(),
                      Icons.emoji_events,
                    ),
                ],
              );
            },
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.deepOrange, size: 14),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Colors.deepOrange,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 8,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
          initiallyExpanded: inningNo == 1,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16),
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
          title: Flexible(
            child: Column(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.getTeamRunRate(inningNo).isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
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
                      if (controller
                          .getTeamRequiredRunRate(inningNo)
                          .isNotEmpty)
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
                ),
              ],
            ),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 600),
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 48,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                headingRowColor: WidgetStateProperty.all(
                  Colors.deepOrange.shade50,
                ),
                columns: [
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 120),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 480),
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 48,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                columns: [
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 120),
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
                            player.economyRate?.toStringAsFixed(2) ?? '0.00',
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOversTab(MatchController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    height: 36,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          controller.getTeamName(1).isEmpty
                              ? 'Team 1'
                              : controller.getTeamName(1),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    height: 36,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          controller.getTeamName(2).isEmpty
                              ? 'Team 2'
                              : controller.getTeamName(2),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildInningsOvers(controller, 1),
                  _buildInningsOvers(controller, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInningsOvers(MatchController controller, int inningNo) {
    List<OverSummaryModel> overs = controller.getTeamOvers(inningNo);

    if (overs.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Over Data Available',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Over-by-over data for ${controller.getTeamName(inningNo)} is not available yet.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        itemCount: overs.length,
        itemBuilder: (context, index) {
          OverSummaryModel over = overs[index];
          return _buildOverCard(
            context,
            over.overNumber ?? 0,
            over.calculatedTotalRuns,
            over.displayBallResults,
            bowlerName: over.bowlerName ?? 'Unknown',
          );
        },
      ),
    );
  }

  Widget _buildOverCard(
    BuildContext context,
    int overNum,
    int runs,
    List<String> balls, {
    String? bowlerName,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Over info section with fixed width
                  Container(
                    width: 100,
                    constraints: const BoxConstraints(minWidth: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Over $overNum",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$runs runs",
                          style: GoogleFonts.nunito(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        if (bowlerName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            bowlerName,
                            style: GoogleFonts.nunito(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Balls section with flexible layout
                  Expanded(
                    child:
                        balls.isNotEmpty
                            ? Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              alignment: WrapAlignment.end,
                              children:
                                  balls
                                      .map((ball) => _buildBall(context, ball))
                                      .toList(),
                            )
                            : Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'No balls data',
                                style: GoogleFonts.nunito(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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

  Widget _buildBall(BuildContext context, String result) {
    Color color;
    Color textColor = Colors.white;

    switch (result.toUpperCase()) {
      case 'W':
      case '1W':
      case '2W':
      case '3W':
      case '4W':
      case '6W':
        color = Colors.red.shade700;
        break;
      case '4':
        color = Colors.green.shade700;
        break;
      case '6':
        color = Colors.purple.shade700;
        break;
      case 'WD':
      case 'NB':
        color = Colors.orange.shade600;
        break;
      case '•':
      case '0':
        color = Colors.grey.shade400;
        textColor = Colors.black87;
        break;
      default:
        if (result.contains('4')) {
          color = Colors.green.shade700;
        } else if (result.contains('6')) {
          color = Colors.purple.shade700;
        } else {
          color = Colors.blue.shade600;
        }
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            result,
            style: GoogleFonts.nunito(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
            maxLines: 1,
          ),
        ),
      ),
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
            constraints: const BoxConstraints(maxWidth: 120),
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
            constraints: const BoxConstraints(maxWidth: 140),
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

  Widget _buildMatchInfoHeader(MatchController controller) {
    if (!controller.hasMatchData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
    );
  }
}
