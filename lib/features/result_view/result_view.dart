import 'package:cric_live/utils/import_exports.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResultController>(
      init: ResultController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CommonAppHeader(
            title: 'Match Result',
            subtitle: 'Complete match summary',
            leadingIcon: Icons.emoji_events,
            actions: [
              IconButton(
                onPressed: () => Get.offAllNamed(NAV_DASHBOARD_PAGE),
                icon: const Icon(Icons.home_rounded),
                tooltip: 'Home',
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingView();
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorView(controller);
            }

            if (!controller.hasMatchData) {
              return _buildNoDataView();
            }

            return _buildResultContent(controller);
            }),
          ),
        );
      },
    );
  }


  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
          SizedBox(height: 16),
          Text(
            'Loading match result...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ResultController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80.sp,
              color: Colors.red[300],
            ),
            SizedBox(height: 24.h),
            Text(
              'Error Loading Result',
              style: GoogleFonts.nunito(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              controller.errorMessage.value,
              style: GoogleFonts.nunito(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: controller.refreshMatchData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_cricket_rounded,
              size: 80.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24.h),
            Text(
              'No Match Data',
              style: GoogleFonts.nunito(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Match result data is not available',
              style: GoogleFonts.nunito(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(ResultController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshMatchData,
      color: Colors.deepOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchHeader(controller),
            SizedBox(height: 20.h),
            _buildMatchSummaryCard(controller),
            SizedBox(height: 20.h),
            _buildTeamScoresSection(controller),
            SizedBox(height: 20.h),
            _buildMatchDetailsSection(controller),
            SizedBox(height: 20.h),
            _buildPerformanceSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader(ResultController controller) {
    final result = controller.matchResult.value!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrange, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.matchTitle,
            style: GoogleFonts.nunito(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          if (result.location?.isNotEmpty == true)
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                SizedBox(width: 4.w),
                Text(
                  result.location!,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          if (result.date != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 16,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(result.date!),
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
          if (result.matchType?.isNotEmpty == true) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                const Icon(
                  Icons.sports_cricket,
                  color: Colors.white70,
                  size: 16,
                ),
                SizedBox(width: 4.w),
                Text(
                  result.matchType!.toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchSummaryCard(ResultController controller) {
    if (controller.resultSummary.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              controller.resultSummary,
              style: GoogleFonts.nunito(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoresSection(ResultController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Scores',
          style: GoogleFonts.nunito(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        if (controller.hasTeamData(1)) _buildTeamScoreCard(controller, 1),
        if (controller.hasTeamData(1) && controller.hasTeamData(2))
          SizedBox(height: 12.h),
        if (controller.hasTeamData(2)) _buildTeamScoreCard(controller, 2),
      ],
    );
  }

  Widget _buildTeamScoreCard(ResultController controller, int inningNo) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: inningNo == 1 ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                inningNo.toString(),
                style: GoogleFonts.nunito(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: inningNo == 1 ? Colors.blue[800] : Colors.green[800],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getTeamName(inningNo),
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${controller.getTeamScore(inningNo)} (${controller.getTeamOversDisplay(inningNo)} overs)',
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchDetailsSection(ResultController controller) {
    final result = controller.matchResult.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Details',
          style: GoogleFonts.nunito(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (result.tossSummary.isNotEmpty)
                _buildDetailRow('Toss', result.tossSummary),
              if (result.tossSummary.isNotEmpty &&
                  result.playerOfTheMatch?.isNotEmpty == true)
                const Divider(),
              if (result.playerOfTheMatch?.isNotEmpty == true)
                _buildDetailRow(
                  'Player of the Match',
                  result.playerOfTheMatch!,
                ),
              if (result.status?.isNotEmpty == true) ...[
                const Divider(),
                _buildDetailRow('Status', result.status!.toUpperCase()),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(ResultController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: GoogleFonts.nunito(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.deepOrange,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.deepOrange,
                labelStyle: GoogleFonts.nunito(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.nunito(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: controller.getTeamName(1)),
                  Tab(text: controller.getTeamName(2)),
                ],
              ),
              SizedBox(
                height: 400.h,
                child: TabBarView(
                  children: [
                    _buildTeamPerformance(controller, 1),
                    _buildTeamPerformance(controller, 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamPerformance(ResultController controller, int inningNo) {
    if (!controller.hasTeamData(inningNo)) {
      return Center(
        child: Text(
          'No data available for ${controller.getTeamName(inningNo)}',
          style: GoogleFonts.nunito(fontSize: 16.sp, color: Colors.grey[600]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildBattingPerformanceCard(controller, inningNo),
          SizedBox(height: 16.h),
          _buildBowlingPerformanceCard(controller, inningNo),
        ],
      ),
    );
  }

  Widget _buildBattingPerformanceCard(
    ResultController controller,
    int inningNo,
  ) {
    final battingResults = controller.getBattingResults(inningNo);

    if (battingResults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'No batting data available',
          style: GoogleFonts.nunito(fontSize: 16.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Batting Performance',
              style: GoogleFonts.nunito(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: battingResults.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final player = battingResults[index];
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.playerName ?? 'Unknown',
                            style: GoogleFonts.nunito(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (player.dismissalInfo?.isNotEmpty == true) ...[
                            SizedBox(height: 2.h),
                            Text(
                              player.dismissalInfo!,
                              style: GoogleFonts.nunito(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.runs ?? 0}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.balls ?? 0}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.fours ?? 0}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          color: Colors.green[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.sixes ?? 0}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          color: Colors.purple[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBowlingPerformanceCard(
    ResultController controller,
    int inningNo,
  ) {
    final bowlingResults = controller.getBowlingResults(inningNo);

    if (bowlingResults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'No bowling data available',
          style: GoogleFonts.nunito(fontSize: 16.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Bowling Performance',
              style: GoogleFonts.nunito(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red[800],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bowlingResults.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final player = bowlingResults[index];
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        player.playerName ?? 'Unknown',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        player.oversDisplay ?? '0',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.runs ?? 0}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.wickets ?? 0}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        player.economyRate?.toStringAsFixed(2) ?? '0.00',
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
