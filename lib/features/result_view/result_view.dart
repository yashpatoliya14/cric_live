import 'package:cric_live/utils/import_exports.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResultController>(
      init: ResultController(),
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.blue.shade50,
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
                        title: _buildEnhancedTitle(controller),
                        titlePadding: const EdgeInsets.only(
                          left: 16,
                          bottom: 60,
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
                              // Background cricket elements
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Icon(
                                  Icons.sports_cricket,
                                  size: 120,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              Positioned(
                                left: -20,
                                bottom: -20,
                                child: Icon(
                                  Icons.emoji_events,
                                  size: 80,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.home, color: Colors.white),
                            onPressed: () {
                              Get.offAllNamed(NAV_DASHBOARD_PAGE);
                            },
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelColor: Colors.deepOrange,
                            unselectedLabelColor: Colors.white,
                            labelStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.0,
                            ),
                            unselectedLabelStyle: GoogleFonts.nunito(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.0,
                            ),
                            tabs: const [
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text("Scoreboard"),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text("Overs"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
              body: Obx(() {
                try {
                  if (controller.isLoading.value) {
                    return _buildLoadingState();
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorState(controller);
                  }

                  if (!controller.hasMatchData) {
                    return _buildEmptyState();
                  }

                  return TabBarView(
                    children: [
                      _buildScoreboardTab(controller),
                      _buildOversTab(controller),
                    ],
                  );
                } catch (e) {
                  return _buildErrorStateWithMessage(
                    'An unexpected error occurred',
                  );
                }
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTitle(ResultController controller) {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.matchTitle,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Match Result",
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const FullScreenLoader(
      message: 'Loading Match Result...',
      loaderColor: Colors.deepOrange,
    );
  }

  Widget _buildErrorState(ResultController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Failed to Load Result",
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshMatchData,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                "Retry",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(20),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Error",
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_cricket,
                size: 48,
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Match Data",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Match result data is not available yet.",
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

  ///first page
  Widget _buildScoreboardTab(ResultController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshMatchData,
      color: Colors.deepOrange,
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Match Result Summary
          if (controller.resultSummary.isNotEmpty)
            _buildResultSummaryCard(controller),
          const SizedBox(height: 16),

          // Team 1 Innings
          if (controller.hasTeamData(1)) _buildTeamInningsCard(controller, 1),

          // Team 2 Innings
          if (controller.hasTeamData(2)) _buildTeamInningsCard(controller, 2),
        ],
      ),
    );
  }

  Widget _buildResultSummaryCard(ResultController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, color: Colors.green[700], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              controller.resultSummary,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.green[800],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInningsCard(ResultController controller, int inningNo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(),
          initiallyExpanded: inningNo == 1,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          title: _buildTeamHeader(controller, inningNo),
          children: [
            const Divider(height: 1),
            _buildBattingTable(controller, inningNo),
            if (controller.getBowlingResults(inningNo).isNotEmpty) ...[
              const Divider(height: 1),
              _buildBowlingTable(controller, inningNo),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader(ResultController controller, int inningNo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$inningNo",
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getTeamName(inningNo),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${controller.getTeamScore(inningNo)} (${controller.getTeamOversDisplay(inningNo)} overs)",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattingTable(ResultController controller, int inningNo) {
    List<PlayerBattingResultModel> battingResults = controller
        .getBattingResults(inningNo);

    if (battingResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
            const SizedBox(width: 8),
            Text(
              'No batting data available',
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Batting Performance",
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 16,
                headingRowHeight: 48,
                dataRowMaxHeight: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: [
                  DataColumn(
                    label: Text(
                      "Batsman",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Runs",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Balls",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "4s",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "6s",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "SR",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
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
        ],
      ),
    );
  }

  Widget _buildBowlingTable(ResultController controller, int inningNo) {
    List<PlayerBowlingResultModel> bowlingResults = controller
        .getBowlingResults(inningNo);

    if (bowlingResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
            const SizedBox(width: 8),
            Text(
              'No bowling data available',
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Bowling Performance",
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 16,
                headingRowHeight: 48,
                dataRowMaxHeight: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: [
                  DataColumn(
                    label: Text(
                      "Bowler",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Overs",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Runs",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Wickets",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "ER",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.0,
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
        ],
      ),
    );
  }

  Widget _buildOversTab(ResultController controller) {
    return Container(
      color: Colors.blue.shade50,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.deepOrange,
                labelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.0,
                ),
                unselectedLabelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.0,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(controller.getTeamName(1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(controller.getTeamName(2)),
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

  Widget _buildInningsOvers(ResultController controller, int inningNo) {
    List<OverSummaryModel> overs = controller.getTeamOvers(inningNo);

    if (overs.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Over Data',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No over data available for ${controller.getTeamName(inningNo)}',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildOverCard(
    BuildContext context,
    int overNum,
    int runs,
    List<String> balls, {
    String? bowlerName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Over $overNum",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$runs runs",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                      ),
                      if (bowlerName != null)
                        Text(
                          "Bowler: $bowlerName",
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children:
                    balls.isNotEmpty
                        ? balls
                            .map((ball) => _buildBall(context, ball))
                            .toList()
                        : [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No ball data',
                              style: GoogleFonts.nunito(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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

    return CircleAvatar(
      radius: 14,
      backgroundColor: color,
      child: Text(
        result,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
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
          Text(
            name,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[800],
              height: 1.0,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              o,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              r,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              w,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange,
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              er,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.0,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey[800],
                  height: 1.0,
                ),
              ),
              Text(
                dismissal,
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Center(
            child: Text(
              r,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.deepOrange,
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              b,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              fours,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              sixes,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.purple[700],
                height: 1.0,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              sr,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
