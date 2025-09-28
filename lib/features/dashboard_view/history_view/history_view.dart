import 'package:cric_live/utils/import_exports.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    return SafeArea(
      bottom: true, // Ensure bottom safe area
      child: Container(
        color: Colors.blue.shade50,
        child: Column(
          children: [
            // Section selector
            _buildSectionSelector(controller),
            // Content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (controller.selectedSection.value == "tournaments") {
                    await controller.fetchTournaments();
                  } else {
                    await controller.refreshMatches();
                  }
                },
                color: Colors.deepOrange,
                child: _buildBody(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSelector(HistoryController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
    HistoryController controller,
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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

  Widget _buildBody(BuildContext context, HistoryController controller) {
    return Obx(() {
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
    });
  }

  Widget _buildMatchesContent(
    BuildContext context,
    HistoryController controller,
  ) {
    // Handle empty state
    if (controller.matches.isEmpty) {
      return _buildEmptyView(context, controller);
    }

    // Group matches by date using MatchModel
    final groupedMatches = _groupMatchesByDate(controller.matches);

    // Show matches with timeline design
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ), // Added bottom padding
      itemCount: groupedMatches.length,
      itemBuilder: (context, index) {
        final entry = groupedMatches[index];
        return _buildDateGroup(
          context,
          entry['date'],
          entry['matches'],
          controller,
        );
      },
    );
  }

  Widget _buildTournamentsContent(
    BuildContext context,
    HistoryController controller,
  ) {
    // Handle empty state
    if (controller.tournaments.isEmpty) {
      return _buildEmptyTournamentsView(context, controller);
    }

    // Show tournaments with modern design
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ), // Added bottom padding
      itemBuilder: (context, index) {
        final tournament = controller.tournaments[index];
        return _buildHistoryTournamentCard(context, tournament, controller);
      },
      itemCount: controller.tournaments.length,
    );
  }

  List<Map<String, dynamic>> _groupMatchesByDate(List<MatchModel> matches) {
    final Map<String, List<MatchModel>> groupedMap = {};

    for (final match in matches) {
      // Get date from MatchModel, ensuring we have a valid date
      DateTime matchDate = match.matchDate ?? DateTime.now();

      final dateKey = DateFormat('yyyy-MM-dd').format(matchDate);

      if (!groupedMap.containsKey(dateKey)) {
        groupedMap[dateKey] = [];
      }

      groupedMap[dateKey]!.add(match);
    }

    // Convert to list and sort by date (newest first)
    final groupedList =
        groupedMap.entries.map((entry) {
          // Sort matches within each day by time (latest first)
          final sortedMatches =
              entry.value.toList()..sort((a, b) {
                final aDate = a.matchDate ?? DateTime.now();
                final bDate = b.matchDate ?? DateTime.now();
                return bDate.compareTo(aDate);
              });

          return {
            'date': entry.key,
            'matches': sortedMatches,
            'actualDate': DateTime.parse(entry.key),
          };
        }).toList();

    // Sort groups by date (newest first)
    groupedList.sort(
      (a, b) =>
          (b['actualDate'] as DateTime).compareTo(a['actualDate'] as DateTime),
    );

    return groupedList;
  }

  Widget _buildDateGroup(
    BuildContext context,
    String dateKey,
    List<MatchModel> matches,
    HistoryController controller,
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
    } else if (now.difference(matchDate).inDays <= 7) {
      dateLabel = DateFormat('EEEE, MMM dd').format(date); // "Monday, Jan 15"
    } else {
      dateLabel = DateFormat('MMM dd, yyyy').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header with match count
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateLabel,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.deepOrange.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${matches.length}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
        ...matches.asMap().entries.map(
          (entry) => _buildHistoryMatchCard(
            context,
            entry.value,
            entry.key == matches.length - 1,
            controller,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistoryMatchCard(
    BuildContext context,
    MatchModel match,
    bool isLast,
    HistoryController controller,
  ) {
    final status = match.status?.toLowerCase() ?? 'unknown';

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: UniversalMatchTile(
        matchData: match,
        displayMode: MatchTileDisplayMode.history,
        onTap: () {
          if (status == 'scheduled') {
            controller.navScheduled(match.id!);
          } else if (status == 'resume') {
            controller.navResume(match);
          } else if (status == 'completed') {
            // For completed matches, navigate to match view instead of result page
            if (match.id != null) {
              final matchIdInt =
                  match.id is int
                      ? match.id
                      : int.tryParse(match.id.toString()) ?? 0;

              if (matchIdInt != null && matchIdInt > 0) {
                Get.toNamed(NAV_MATCH_VIEW, arguments: {"matchId": matchIdInt});
              } else {
                Get.snackbar(
                  'Navigation Error',
                  'Invalid match ID. Cannot open match view.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
              }
            }
          } else {
            // For other statuses, navigate to match view
            Get.toNamed(NAV_MATCH_VIEW, arguments: {"matchId": match.id});
          }
        },
        onHistoryTap: () {
          // Navigate to match result/details
          Get.toNamed(NAV_RESULT, arguments: {"matchId": match.id});
        },
        onDeleteTap: () {
          // Show delete confirmation dialog
          _showDeleteMatchConfirmation(context, match, controller);
        },
        showHistory:
            status == 'completed', // Only show history for completed matches
        showMatchIds: true, // Show match IDs in history
        showTimeline: true, // Show timeline indicator
        showDeleteButton: true, // Show delete button for all matches in history
        statusColor: _getStatusColor(status),
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
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

  Widget _buildLoadingView(BuildContext context) {
    return const FullScreenLoader(
      message: 'Loading match history...',
      loaderColor: Colors.deepOrange,
    );
  }

  Widget _buildErrorView(BuildContext context, HistoryController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ), // Added bottom padding
      child: Center(
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
                    await controller.getMatches();
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
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, HistoryController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ), // Added bottom padding
      child: Center(
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
                child: Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
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
                        await controller.refreshMatches();
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
      ),
    );
  }

  Widget _buildHistoryTournamentCard(
    BuildContext context,
    CreateTournamentModel tournament,
    HistoryController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            controller.navigateToTournamentView(tournament);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament header - compact
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tournament format badge
                    if (tournament.format != null &&
                        tournament.format!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepOrange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tournament.format!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.deepOrange.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade600,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tournament name - smaller
                Text(
                  tournament.name ?? 'Tournament',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Tournament info in compact format
                Row(
                  children: [
                    // Location info
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tournament.location ?? 'TBD',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date info
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatTournamentDateRange(
                                tournament.startDate,
                                tournament.endDate,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Action row with view details and delete button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: Colors.deepOrange.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View Details',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap:
                          () => _showDeleteTournamentConfirmation(
                            context,
                            tournament,
                            controller,
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
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

  String _formatTournamentDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Date TBD';
    }

    final start = DateFormat('MMM d').format(startDate);
    final end = DateFormat('MMM d, yyyy').format(endDate);

    // If same month and year, show "Jan 15-20, 2024"
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      final startDay = startDate.day;
      final endFormatted = DateFormat('d, yyyy').format(endDate);
      return '$start-$endFormatted';
    }

    return '$start - $end';
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
    HistoryController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            32,
            32,
            32,
            132,
          ), // Added extra bottom padding
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
                'No Tournament History',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You haven\'t participated in any tournaments yet. Join tournaments to see your history here!',
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

  /// Show confirmation dialog for match deletion
  void _showDeleteMatchConfirmation(
    BuildContext context,
    MatchModel match,
    HistoryController controller,
  ) {
    final team1Name =
        match.matchState?.team1Innings?.teamName ?? match.team1Name ?? 'Team 1';
    final team2Name =
        match.matchState?.team2Innings?.teamName ?? match.team2Name ?? 'Team 2';
    final matchTitle = '$team1Name vs $team2Name';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text(
              'Delete Match',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this match?',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sports_cricket,
                    color: Colors.deepOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      matchTitle,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMatch(match);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog for tournament deletion
  void _showDeleteTournamentConfirmation(
    BuildContext context,
    CreateTournamentModel tournament,
    HistoryController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text(
              'Delete Tournament',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this tournament?',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tournament.name ?? 'Tournament',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will delete all associated matches and data. This action cannot be undone.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteTournament(tournament);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
