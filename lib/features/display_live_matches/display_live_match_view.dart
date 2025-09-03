import 'package:cric_live/features/display_live_matches/display_live_match_controller.dart';
import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchView extends StatelessWidget {
  const DisplayLiveMatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DisplayLiveMatchController>();
    return Obx(
      () => Container(
        color: Colors.blue.shade50,
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getMatchesState();
          },
          color: Colors.deepOrange,
          child: _buildBody(context, controller),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
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

    // Show matches with modern design
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final match = controller.matchesState[index];
        return _buildModernMatchCard(context, match, controller.matches[index]);
      },
      itemCount: controller.matchesState.length,
    );
  }

  Widget _buildModernMatchCard(
    BuildContext context,
    dynamic match,
    dynamic matchData,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap:
              () => Get.toNamed(
                NAV_MATCH_VIEW,
                arguments: {'matchId': matchData.id, 'isLive': true},
              ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header with live indicator and match info
                _buildMatchHeader(context, match),
                const SizedBox(height: 16),
                // Teams and scores
                _buildTeamsSection(context, match),
                const SizedBox(height: 12),
                // Match status and description
                _buildMatchFooter(context, match),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHeader(BuildContext context, dynamic match) {
    final isLive = match.status?.toLowerCase() == 'live';

    return Row(
      children: [
        // Live indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLive ? Colors.red : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              if (isLive) const SizedBox(width: 6),
              Text(
                isLive ? 'LIVE' : match.status?.toUpperCase() ?? 'UNKNOWN',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Match type and venue
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'T20 Match',
              style: GoogleFonts.nunito(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (match.venue != null)
              Text(
                match.venue!,
                style: GoogleFonts.nunito(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamsSection(BuildContext context, dynamic match) {
    return Column(
      children: [
        _buildTeamRow(
          context,
          match.team1Innings?.teamName ?? 'Team 1',
          match.team1Innings?.scoreDisplay ?? '0/0',
          match.team1Innings?.overs?.toString() ?? '0.0',
          true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'vs',
                style: GoogleFonts.nunito(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTeamRow(
          context,
          match.team2Innings?.teamName ?? 'Team 2',
          match.team2Innings?.scoreDisplay ?? '0/0',
          match.team2Innings?.overs?.toString() ?? '0.0',
          false,
        ),
      ],
    );
  }

  Widget _buildTeamRow(
    BuildContext context,
    String teamName,
    String score,
    String overs,
    bool isTop,
  ) {
    return Row(
      children: [
        // Team avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isTop
                      ? [Colors.deepOrange.shade300, Colors.deepOrange.shade500]
                      : [Colors.blue.shade300, Colors.blue.shade500],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              teamName.isNotEmpty ? teamName[0].toUpperCase() : 'T',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Team name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teamName,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$overs overs',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            score,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchFooter(BuildContext context, dynamic match) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.deepOrange.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              match.matchSummary ?? 'Match in progress',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
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
            'Loading live matches...',
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
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.sports_cricket,
                size: 64,
                color: Colors.deepOrange.shade300,
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
