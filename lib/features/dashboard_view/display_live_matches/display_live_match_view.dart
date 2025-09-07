import 'package:cric_live/utils/import_exports.dart';

class DisplayLiveMatchView extends StatelessWidget {
  const DisplayLiveMatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DisplayLiveMatchController>();
    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          // Section selector
          _buildSectionSelector(controller),
          // Content area
          Expanded(
            child: Obx(
              () => RefreshIndicator(
                onRefresh: () async {
                  if (controller.selectedSection.value == "tournaments") {
                    await controller.fetchTournaments();
                  } else {
                    await controller.getMatchesState();
                  }
                },
                color: Colors.deepOrange,
                child: _buildBody(context, controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector(DisplayLiveMatchController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildSectionButton(
                controller,
                "matches",
                "Matches",
                Icons.sports_cricket,
              ),
            ),
            Expanded(
              child: _buildSectionButton(
                controller,
                "tournaments",
                "Tournaments",
                Icons.emoji_events,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton(
    DisplayLiveMatchController controller,
    String section,
    String title,
    IconData icon,
  ) {
    final isSelected = controller.selectedSection.value == section;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.switchSection(section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
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

    // Show content based on selected section
    if (controller.selectedSection.value == "tournaments") {
      return _buildTournamentsContent(context, controller);
    } else {
      return _buildMatchesContent(context, controller);
    }
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
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final match = controller.matches[index];
          return _buildBasicMatchCard(context, match);
        },
        itemCount: controller.matches.length,
      );
    }

    // Show matches with complete state data
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final matchState = controller.matchesState[index];
        final match = controller.matches[index];
        return _buildModernMatchCard(context, matchState, match);
      },
      itemCount: controller.matchesState.length,
    );
  }

  Widget _buildTournamentsContent(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
    // Handle empty state
    if (controller.tournaments.isEmpty) {
      return _buildEmptyTournamentsView(context, controller);
    }

    // Show tournaments with modern design
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final tournament = controller.tournaments[index];
        return _buildTournamentCard(context, tournament);
      },
      itemCount: controller.tournaments.length,
    );
  }

  Widget _buildTournamentCard(BuildContext context, dynamic tournament) {
    final status = tournament['status']?.toString().toLowerCase() ?? 'unknown';
    Color statusColor = Colors.grey;
    if (status == 'ongoing') statusColor = Colors.green;
    if (status == 'upcoming') statusColor = Colors.blue;
    if (status == 'completed') statusColor = Colors.grey;

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
          onTap: () {
            // TODO: Navigate to tournament details
            Get.snackbar(
              'Tournament',
              'Opening ${tournament['name']}...',
              backgroundColor: Colors.deepOrange,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade600,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tournament name
                Text(
                  tournament['name'] ?? 'Tournament',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                // Tournament details
                Row(
                  children: [
                    _buildTournamentStat(
                      Icons.groups,
                      '${tournament['teams']} Teams',
                    ),
                    const SizedBox(width: 16),
                    _buildTournamentStat(
                      Icons.sports_cricket,
                      '${tournament['matches']} Matches',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Venue and date
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tournament['venue'] ?? 'TBD',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tournament['startDate'] ?? 'TBD',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.deepOrange),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTournamentsView(
    BuildContext context,
    DisplayLiveMatchController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Live Tournaments',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'There are no live tournaments at the moment. Check back later for exciting tournaments!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => controller.fetchTournaments(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  /// Basic match card for when detailed state data is not available
  Widget _buildBasicMatchCard(BuildContext context, MatchModel match) {
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
                arguments: {'matchId': match.id, 'isLive': true},
              ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    match.status?.toUpperCase() ?? 'MATCH',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Basic match info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.team1Name ?? 'Team 1',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'vs',
                            style: GoogleFonts.nunito(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            match.team2Name ?? 'Team 2',
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.deepOrange.withOpacity(0.2),
                            Colors.deepOrange.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.sports_cricket,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHeader(BuildContext context, dynamic match) {
    final isLive = match?.status?.toLowerCase() == 'live';
    final status = match?.status?.toUpperCase() ?? 'UNKNOWN';
    final venue =
        match?.location ?? match?.team1Innings?.teamName ?? 'Venue TBD';

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
                isLive ? 'LIVE' : status,
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
            Text(
              venue,
              style: GoogleFonts.nunito(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamsSection(BuildContext context, dynamic match) {
    // Safely extract team data with null checks
    final team1Name = match?.team1Innings?.teamName ?? 'Team 1';
    final team1Score = match?.team1Innings?.scoreDisplay ?? '0/0';
    final team1Overs = match?.team1Innings?.overs?.toString() ?? '0.0';

    final team2Name = match?.team2Innings?.teamName ?? 'Team 2';
    final team2Score = match?.team2Innings?.scoreDisplay ?? '0/0';
    final team2Overs = match?.team2Innings?.overs?.toString() ?? '0.0';

    return Column(
      children: [
        _buildTeamRow(context, team1Name, team1Score, team1Overs, true),
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
        _buildTeamRow(context, team2Name, team2Score, team2Overs, false),
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
    final matchSummary =
        match?.matchSummary ?? match?.resultDescription ?? 'Match in progress';

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
              matchSummary,
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
                gradient: RadialGradient(
                  colors: [
                    Colors.deepOrange.shade100,
                    Colors.deepOrange.shade50.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50.withOpacity(0.7),
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
