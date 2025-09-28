import 'package:cric_live/utils/import_exports.dart';

import 'user_role.dart';

class TournamentView extends StatelessWidget {
  const TournamentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TournamentController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CommonAppHeader(
        title: 'Tournament',
        subtitle: 'Tournament details and matches',
        leadingIcon: Icons.emoji_events,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
        // Debug information
        log("Tournament View - isLoading: ${controller.isLoading.value}");
        log("Tournament View - tournament: ${controller.tournament.value}");
        log("Tournament View - tournamentId: ${controller.tournamentId}");
        log("Tournament View - hostId: ${controller.hostId}");

        if (controller.isLoading.value) {
          return TournamentWidgets.loadingState(
            title: 'Loading Tournament...',
            subtitle: 'Please wait while we fetch the details',
          );
        }

        if (controller.tournament.value == null) {
          return _buildErrorState(controller);
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshData();
          },
          child: _buildTournamentContent(controller),
        );
      })),
      floatingActionButton: Obx(() {
        // Add debugging for FloatingActionButton visibility
        log("🎯 FloatingActionButton Debug:");
        log("   - canCreateMatches: ${controller.canCreateMatches}");
        log("   - userRole: ${controller.userRole.value}");
        log("   - hasAdminAccess: ${controller.hasAdminAccess}");
        
        if (!controller.canCreateMatches) {
          log("   - FAB Hidden (no create access)");
          return const SizedBox.shrink();
        }
        
        log("   - FAB Visible (create access granted)");
        return FloatingActionButton(
          onPressed: () async {
            dynamic result = await Get.toNamed(
              NAV_CREATE_MATCH,
              arguments: {"tournamentId": controller.tournamentId},
            );
            if (result != null) {
              controller.refreshData();
            }
          },
          backgroundColor: Colors.deepOrange,
          child: const Icon(Icons.add, color: Colors.white),
        );
      }),
    );
  }

  Widget _buildErrorState(TournamentController controller) {
    return TournamentWidgets.emptyState(
      icon: Icons.error_outline,
      title: "Tournament Not Found",
      subtitle: "Unable to load tournament details",
      iconColor: Colors.red.withValues(alpha: 0.7),
      action: ElevatedButton.icon(
        onPressed: () => controller.refreshData(),
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(
          "Try Again",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTournamentContent(TournamentController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCurrentTimeCard(),
        const SizedBox(height: 12),
        _buildTournamentInfo(controller),
        const SizedBox(height: 16),
        _buildMatchesSection(controller),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildCurrentTimeCard() {
    return Card(
      elevation: 1,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.access_time_filled,
              color: Colors.blue.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Date & Time',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  StreamBuilder<DateTime>(
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                      (_) => DateTime.now(),
                    ),
                    initialData: DateTime.now(),
                    builder: (context, snapshot) {
                      final now = snapshot.data ?? DateTime.now();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE, MMM d, yy').format(now),
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            DateFormat('h:mm:ss a').format(now),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfo(TournamentController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Tournament Details",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => Column(
                children: [
                  TournamentWidgets.infoRow(
                    "Location",
                    controller.tournament.value?.location ?? "N/A",
                    Icons.location_on,
                  ),
                  TournamentWidgets.infoRow(
                    "Format",
                    controller.tournament.value?.format ?? "N/A",
                    Icons.sports_cricket,
                  ),
                  TournamentWidgets.infoRow(
                    "Start Date & Time",
                    TournamentWidgets.formatCompactDateTime(
                      controller.tournament.value?.startDate,
                    ),
                    Icons.event,
                    valueColor: Colors.green.shade700,
                  ),
                  TournamentWidgets.infoRow(
                    "End Date & Time",
                    TournamentWidgets.formatCompactDateTime(
                      controller.tournament.value?.endDate,
                    ),
                    Icons.event_busy,
                    valueColor: Colors.red.shade700,
                  ),
                  TournamentWidgets.infoRow(
                    "Duration",
                    TournamentWidgets.formatTournamentDateRange(
                      controller.tournament.value?.startDate,
                      controller.tournament.value?.endDate,
                    ),
                    Icons.calendar_month,
                  ),
                  TournamentWidgets.infoRow(
                    "Status",
                    TournamentWidgets.formatTimeUntilStart(
                      controller.tournament.value?.startDate,
                    ),
                    Icons.schedule,
                    valueColor: _getStatusColor(
                      controller.tournament.value?.startDate,
                    ),
                  ),
                  // Show role information for all users
                  GestureDetector(
                    onTap: () => controller.showRoleInfoDialog(),
                    child: TournamentWidgets.infoRow(
                      "Your Role",
                      controller.userRoleText,
                      controller.userRole.value == UserRole.viewer
                          ? Icons.visibility
                          : controller.userRole.value == UserRole.host
                              ? Icons.admin_panel_settings
                              : Icons.edit,
                      valueColor: controller.userRole.value == UserRole.viewer
                          ? Colors.blue.shade600
                          : controller.userRole.value == UserRole.host
                              ? Colors.deepOrange
                              : Colors.green,
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

  Widget _buildMatchesSection(TournamentController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.sports_cricket, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Matches",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    "${controller.matches.length}",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.matches.isEmpty) {
              return TournamentWidgets.emptyState(
                icon: Icons.sports_cricket_outlined,
                title: "No matches scheduled",
                subtitle: controller.canCreateMatches
                    ? "Get started by creating your first match"
                    : controller.userRole.value == UserRole.viewer
                        ? "No matches available to view yet"
                        : "No matches created yet",
                action: controller.canCreateMatches
                    ? ElevatedButton.icon(
                        onPressed: () async {
                          dynamic result = await Get.toNamed(
                            NAV_CREATE_MATCH,
                            arguments: {
                              "tournamentId": controller.tournamentId,
                            },
                          );
                          if (result != null) {
                            controller.refreshData();
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(
                          "Create Match",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : null,
              );
            }

            return Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.matches.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final match = controller.matches[index];
                    return TournamentWidgets.animatedListItem(
                      child: _buildMatchCard(match, controller, context),
                      index: index,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMatchCard(
    MatchModel match,
    TournamentController controller,
    BuildContext context,
  ) {
    final team1 = match.team1Name ?? 'Team A';
    final team2 = match.team2Name ?? 'Team B';

    return Tooltip(
      message:
          match.matchDate != null
              ? 'Full Match Details:\n${TournamentWidgets.formatDetailedMatchDate(match.matchDate)}\nTap to view match details'
              : 'Match date and time not set yet',
      preferBelow: false,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Icon(
            Icons.sports_cricket,
            color: Colors.blue.shade600,
            size: 20,
          ),
        ),
        title: Text(
          '$team1 vs $team2',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Row
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    match.matchDate != null
                        ? TournamentWidgets.formatDateOnly(match.matchDate)
                        : 'Date not set',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Time Row
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.green[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    match.matchDate != null
                        ? TournamentWidgets.formatTimeOnly(match.matchDate)
                        : 'Time not set',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              // Debug match control access
              log("🎖️ Match Status Chip Debug for ${match.team1Name ?? 'Team1'} vs ${match.team2Name ?? 'Team2'}:");
              log("   - canControlMatches: ${controller.canControlMatches}");
              log("   - match.status: ${match.status}");
              log("   - userRole: ${controller.userRole.value}");
              log("   - Status chip tap enabled: ${controller.canControlMatches ? 'YES' : 'NO'}");
              
              // For viewers/spectators, show status chip but without tap functionality
              final chip = TournamentWidgets.statusChip(
                TournamentWidgets.statusText(match.status),
                TournamentWidgets.statusColor(match.status),
                onTap: controller.canControlMatches
                    ? () {
                        log("🎖️ Status chip tapped for match ${match.id} - User has control access");
                        controller.matchState(match);
                      }
                    : null, // No tap functionality for viewers
              );
              
              // Add a tooltip for viewers to explain they can only view matches
              if (!controller.canControlMatches) {
                return Tooltip(
                  message: 'You can only view matches as a spectator. Tap the match row to view details.',
                  child: chip,
                );
              }
              
              return chip;
            }),
            // Delete button for tournament admins/scorers (exclude live matches)
            Obx(() {
              // Debug delete button visibility
              log("🗑️ Delete Button Debug for ${match.team1Name ?? 'Team1'} vs ${match.team2Name ?? 'Team2'}:");
              log("   - canDeleteMatches: ${controller.canDeleteMatches}");
              log("   - match.status: ${match.status}");
              log("   - is live match: ${match.status?.toLowerCase() == 'live'}");
              bool showDeleteButton = controller.canDeleteMatches && match.status?.toLowerCase() != 'live';
              log("   - Delete button visible: $showDeleteButton");
              
              if (showDeleteButton) {
                return Row(
                  children: [
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap:
                          () => _showDeleteMatchConfirmation(
                            context,
                            match,
                            controller,
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
          ],
        ),
        onTap: () => controller.viewMatch(match),
      ),
    );
  }

  /// Get color based on tournament status
  Color _getStatusColor(DateTime? startDate) {
    if (startDate == null) return Colors.grey;

    final now = DateTime.now();
    final diff = startDate.difference(now);

    if (diff.isNegative) {
      return Colors.green; // Tournament started
    } else if (diff.inDays <= 1) {
      return Colors.orange; // Starting soon
    } else {
      return Colors.blue; // Future tournament
    }
  }

  /// Show confirmation dialog for match deletion in tournament
  void _showDeleteMatchConfirmation(
    BuildContext context,
    MatchModel match,
    TournamentController controller,
  ) {
    final team1Name = match.team1Name ?? 'Team A';
    final team2Name = match.team2Name ?? 'Team B';
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
              'Are you sure you want to delete this match from the tournament?',
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
}
