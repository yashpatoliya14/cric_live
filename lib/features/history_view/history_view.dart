import 'package:cric_live/utils/import_exports.dart';
import 'package:intl/intl.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    return Container(
      color: Colors.blue.shade50,
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.getMatchesState();
        },
        color: Colors.deepOrange,
        child: _buildBody(context, controller),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingView(context);
      }

      // Handle error state
      if (controller.error.value.isNotEmpty) {
        return _buildErrorView(context, controller);
      }

      // Handle empty state
      if (controller.matchesState.isEmpty) {
        return _buildEmptyView(context, controller);
      }

      // Group matches by date
      final groupedMatches = _groupMatchesByDate(
        controller.matchesState,
        controller.matches,
      );

      // Show matches with timeline design
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedMatches.length,
        itemBuilder: (context, index) {
          final entry = groupedMatches[index];
          return _buildDateGroup(context, entry['date'], entry['matches']);
        },
      );
    });
  }

  List<Map<String, dynamic>> _groupMatchesByDate(
    List<dynamic> matchesState,
    List<dynamic> matches,
  ) {
    final Map<String, List<Map<String, dynamic>>> groupedMap = {};

    for (int i = 0; i < matchesState.length && i < matches.length; i++) {
      final match = matchesState[i];
      final matchData = matches[i];

      // Get date from match data
      DateTime matchDate = DateTime.now(); // Default to now
      if (matchData.matchDate != null) {
        matchDate = matchData.matchDate!;
      } else if (match.date != null) {
        matchDate = match.date!;
      }

      final dateKey = DateFormat('yyyy-MM-dd').format(matchDate);

      if (!groupedMap.containsKey(dateKey)) {
        groupedMap[dateKey] = [];
      }

      groupedMap[dateKey]!.add({
        'match': match,
        'matchData': matchData,
        'date': matchDate,
      });
    }

    // Convert to list and sort by date (newest first)
    final groupedList =
        groupedMap.entries.map((entry) {
          return {'date': entry.key, 'matches': entry.value};
        }).toList();

    groupedList.sort(
      (a, b) => (b['date'] as String).compareTo(a['date'] as String),
    );

    return groupedList;
  }

  Widget _buildDateGroup(
    BuildContext context,
    String dateKey,
    List<Map<String, dynamic>> matches,
  ) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final matchDate = DateTime(date.year, date.month, date.day);

    String dateLabel;
    if (matchDate == today) {
      dateLabel = 'Today';
    } else if (matchDate == yesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('MMM dd, yyyy').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Container(
          margin: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepOrange.shade200),
                ),
                child: Text(
                  dateLabel,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.deepOrange.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade300),
              ),
            ],
          ),
        ),
        // Matches for this date
        ...matches.map(
          (matchEntry) => _buildHistoryMatchCard(
            context,
            matchEntry['match'],
            matchEntry['matchData'],
            matches.indexOf(matchEntry) == matches.length - 1,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistoryMatchCard(
    BuildContext context,
    dynamic match,
    dynamic matchData,
    bool isLast,
  ) {
    final isCompleted = match.status?.toLowerCase() == 'completed';

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? Colors.green.shade400
                          : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 60, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 16),
          // Match card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap:
                      () => Get.toNamed(
                        NAV_MATCH_VIEW,
                        arguments: {"matchId": matchData.id},
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Match header
                        _buildHistoryMatchHeader(context, match),
                        const SizedBox(height: 12),
                        // Teams and scores
                        _buildHistoryTeamsSection(context, match),
                        const SizedBox(height: 12),
                        // Result
                        _buildHistoryResult(context, match),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryMatchHeader(BuildContext context, dynamic match) {
    final status = match.status?.toLowerCase() ?? 'unknown';
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'live':
        statusColor = Colors.red;
        statusIcon = Icons.radio_button_checked;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
    }

    return Row(
      children: [
        Icon(statusIcon, size: 16, color: statusColor),
        const SizedBox(width: 6),
        Text(
          status.toUpperCase(),
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: statusColor,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        Text(
          'T20 Match',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTeamsSection(BuildContext context, dynamic match) {
    return Column(
      children: [
        _buildHistoryTeamRow(
          context,
          match.team1Innings?.teamName ?? 'Team 1',
          match.team1Innings?.scoreDisplay ?? '0/0',
          match.team1Innings?.overs?.toString() ?? '0.0',
          Colors.deepOrange.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'vs',
          style: GoogleFonts.nunito(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        _buildHistoryTeamRow(
          context,
          match.team2Innings?.teamName ?? 'Team 2',
          match.team2Innings?.scoreDisplay ?? '0/0',
          match.team2Innings?.overs?.toString() ?? '0.0',
          Colors.blue.shade400,
        ),
      ],
    );
  }

  Widget _buildHistoryTeamRow(
    BuildContext context,
    String teamName,
    String score,
    String overs,
    Color teamColor,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: teamColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            teamName,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$score ($overs)',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryResult(BuildContext context, dynamic match) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              match.resultDescription ??
                  match.matchSummary ??
                  'Match completed',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading match history...',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, HistoryController controller) {
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
              'Failed to load history',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading your match history.',
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
                  await controller.getMatchesState();
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

  Widget _buildEmptyView(BuildContext context, HistoryController controller) {
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'No Match History',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t played any matches yet.\nStart your cricket journey by creating a match!',
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
                      await controller.getMatchesState();
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
}
