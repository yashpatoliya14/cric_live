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
            appBar: AppBar(
              title: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.dynamicMatchTitle,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (controller.matchSubtitle.isNotEmpty)
                    Text(
                      controller.matchSubtitle,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              )),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                if (controller.isLive == true)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  children: [
                    // Match info header
                    Obx(() => _buildMatchInfoHeader(controller)),
                    // Tab bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.deepOrange,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        labelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.scoreboard, size: 16),
                                SizedBox(width: 6),
                                Text("Scoreboard"),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timeline, size: 16),
                                SizedBox(width: 6),
                                Text("Overs"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading match result...'),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refreshMatchData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!controller.hasMatchData) {
                return Center(child: Text('No match data available'));
              }

              return TabBarView(
                children: [
                  _buildScoreboardTab(controller),
                  _buildOversTab(controller),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  ///first page
  Widget _buildScoreboardTab(MatchController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshMatchData();
      },
      color: Colors.deepOrange,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatItem('Total Runs', stats['totalRuns'].toString(), Icons.sports_cricket),
              _buildStatItem('Total Wickets', stats['totalWickets'].toString(), Icons.close),
              _buildStatItem('Boundaries', stats['totalBoundaries'].toString(), Icons.arrow_forward),
              _buildStatItem('Sixes', stats['totalSixes'].toString(), Icons.keyboard_double_arrow_up),
              if (stats['highestScore'] > 0)
                _buildStatItem('Highest Score', stats['highestScore'].toString(), Icons.star),
              if (stats['highestTeamScore'] > 0)
                _buildStatItem('Highest Team Score', stats['highestTeamScore'].toString(), Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }
          const SizedBox(height: 16),

          // Team 1 Innings
          if (controller.hasTeamData(1)) _buildEnhancedTeamInningsCard(controller, 1),

          // Team 2 Innings
          if (controller.hasTeamData(2)) _buildEnhancedTeamInningsCard(controller, 2),
        ],
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
          colors: [
            Colors.deepOrange.shade400,
            Colors.deepOrange.shade600,
          ],
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
          Row(
            children: [
              Expanded(
                child: _buildEnhancedTeamScoreDisplay(
                  controller.getTeamName(1),
                  controller.getTeamDetailedScore(1),
                  controller.getTeamRunRate(1),
                  true,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'VS',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (controller.isLive == true)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              Expanded(
                child: _buildEnhancedTeamScoreDisplay(
                  controller.getTeamName(2),
                  controller.getTeamDetailedScore(2),
                  controller.getTeamRunRate(2),
                  false,
                ),
              ),
            ],
          ),
          
          // Enhanced toss and result info
          if (controller.detailedTossInfo.isNotEmpty || controller.matchResultDescription.isNotEmpty) ..[            const SizedBox(height: 16),
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
                  if (controller.detailedTossInfo.isNotEmpty && controller.matchResultDescription.isNotEmpty)
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
              Icon(
                Icons.info_outline,
                color: Colors.deepOrange,
                size: 20,
              ),
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
          ...stats.entries.map((entry) => Padding(
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
          )),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedTeamScoreDisplay(String teamName, String score, String runRate, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          teamName,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          score,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: isLeft ? TextAlign.start : TextAlign.end,
        ),
        if (runRate.isNotEmpty)
          Text(
            runRate,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            textAlign: isLeft ? TextAlign.start : TextAlign.end,
          ),
      ],
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
          Icon(
            Icons.emoji_events,
            color: Colors.green.shade600,
            size: 24,
          ),
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
          Icon(
            Icons.star,
            color: Colors.amber.shade600,
            size: 24,
          ),
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatItem('Total Runs', stats['totalRuns'].toString(), Icons.sports_cricket),
              _buildStatItem('Total Wickets', stats['totalWickets'].toString(), Icons.close),
              _buildStatItem('Boundaries', stats['totalBoundaries'].toString(), Icons.arrow_forward),
              _buildStatItem('Sixes', stats['totalSixes'].toString(), Icons.keyboard_double_arrow_up),
              if (stats['highestScore'] > 0)
                _buildStatItem('Highest Score', stats['highestScore'].toString(), Icons.star),
              if (stats['highestTeamScore'] > 0)
                _buildStatItem('Highest Team Score', stats['highestTeamScore'].toString(), Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.deepOrange,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.deepOrange,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTeamInningsCard(MatchController controller, int inningNo) {
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
        data: Theme.of(context).copyWith(
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
                colors: inningNo == 1 
                    ? [Colors.deepOrange.shade300, Colors.deepOrange.shade500]
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
            children: [
              Text(
                controller.getTeamName(inningNo),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.getTeamDetailedScore(inningNo),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              // Additional team stats
              Row(
                children: [
                  if (controller.getTeamRunRate(inningNo).isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.getTeamRunRate(inningNo),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  if (controller.getTeamRequiredRunRate(inningNo).isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.getTeamRequiredRunRate(inningNo),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
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
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No batting data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(Get.context!).colorScheme.secondary,
          ),
          columns: [
            DataColumn(label: Text("Batsman")),
            DataColumn(label: Text("Runs")),
            DataColumn(label: Text("Balls")),
            DataColumn(label: Text("4s")),
            DataColumn(label: Text("6s")),
            DataColumn(label: Text("SR")),
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
    );
  }

  Widget _buildBowlingTable(MatchController controller, int inningNo) {
    List<PlayerBowlingResultModel> bowlingResults = controller
        .getBowlingResults(inningNo);

    if (bowlingResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No bowling data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 30,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(Get.context!).colorScheme.secondary,
          ),
          columns: [
            DataColumn(label: Text("Bowler")),
            DataColumn(label: Text("Overs")),
            DataColumn(label: Text("R")),
            DataColumn(label: Text("W")),
            DataColumn(label: Text("ER")),
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
    );
  }

  Widget _buildOversTab(MatchController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(Get.context!).primaryColor,
            tabs: [
              Tab(text: controller.getTeamName(1)),
              Tab(text: controller.getTeamName(2)),
            ],
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
    );
  }

  Widget _buildInningsOvers(MatchController controller, int inningNo) {
    List<OverSummaryModel> overs = controller.getTeamOvers(inningNo);

    if (overs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No over data available for ${controller.getTeamName(inningNo)}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Over $overNum",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$runs runs",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    if (bowlerName != null)
                      Text(
                        bowlerName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.end,
                    children:
                        balls.isNotEmpty
                            ? balls
                                .map((ball) => _buildBall(context, ball))
                                .toList()
                            : [
                              Text(
                                'No balls data',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                  ),
                ),
              ],
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
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        DataCell(Center(child: Text(o))),
        DataCell(Center(child: Text(r))),
        DataCell(
          Center(
            child: Text(w, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(Center(child: Text(er))),
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                dismissal,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        DataCell(Center(child: Text(r))),
        DataCell(Center(child: Text(b))),
        DataCell(Center(child: Text(fours))),
        DataCell(Center(child: Text(sixes))),
        DataCell(Center(child: Text(sr))),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.matchFormat,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (controller.venue.isNotEmpty)
                  Text(
                    controller.venue,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          // Toss info
          if (controller.tossInfo.isNotEmpty)
            Expanded(
              child: Text(
                controller.tossInfo,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }
}
