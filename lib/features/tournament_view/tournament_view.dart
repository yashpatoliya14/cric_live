import 'package:cric_live/utils/import_exports.dart';
import 'package:intl/intl.dart';

class TournamentView extends StatelessWidget {
  const TournamentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TournamentController());

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: _buildEnhancedTitle(controller),
                  titlePadding: const EdgeInsets.only(
                    left: 16,
                    bottom: 16,
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
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Icon(
                            Icons.emoji_events,
                            size: 120,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.sports_cricket,
                            size: 80,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        body: Obx(() {
          // Debug information
          log("Tournament View - isLoading: ${controller.isLoading.value}");
          log("Tournament View - tournament: ${controller.tournament.value}");
          log("Tournament View - tournamentId: ${controller.tournamentId}");
          log("Tournament View - hostId: ${controller.hostId}");

          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          if (controller.tournament.value == null) {
            return _buildErrorState(controller);
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            color: Colors.deepOrange,
            backgroundColor: Colors.white,
            child: _buildTournamentContent(controller),
          );
        }),
      ),
      floatingActionButton: Obx(
        () =>
            controller.isUserScorer.value
                ? FloatingActionButton.extended(
                  onPressed: () async {
                    Map<String, dynamic>? result = await Get.toNamed(
                      NAV_CREATE_MATCH,
                      arguments: {"tournamentId": controller.tournamentId},
                    );
                    if (result != null) {
                      controller.refreshData();
                    }
                  },
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text(
                    "Add Match",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                  ),
                  elevation: 4,
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildEnhancedTitle(TournamentController controller) {
    return Obx(
      () => ShaderMask(
        shaderCallback:
            (bounds) => LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isUserScorer.value
                    ? Icons.edit_note
                    : Icons.visibility,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.tournament.value?.name ?? "Tournament",
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.userRoleText,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
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

  Widget _buildLoadingState() {
    return const FullScreenLoader(
      message: 'Loading Tournament...',
      loaderColor: Colors.deepOrange,
    );
  }

  Widget _buildErrorState(TournamentController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              "Tournament Not Found",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Unable to load tournament details",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                "Try Again",
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentContent(TournamentController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTournamentInfo(controller),
          const SizedBox(height: 24),
          _buildMatchesSection(controller),
        ],
      ),
    );
  }

  Widget _buildTournamentInfo(TournamentController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Tournament Details",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: [
                _buildInfoRow(
                  "Location",
                  controller.tournament.value?.location ?? "N/A",
                  Icons.location_on,
                ),
                _buildInfoRow(
                  "Format",
                  controller.tournament.value?.format ?? "N/A",
                  Icons.sports_cricket,
                ),
                _buildInfoRow(
                  "Duration",
                  controller.tournament.value != null
                      ? "${DateFormat('MMM d').format(controller.tournament.value!.startDate)} - ${DateFormat('MMM d, yy').format(controller.tournament.value!.endDate)}"
                      : "N/A",
                  Icons.date_range,
                ),
                if (controller.isUserScorer.value)
                  _buildInfoRow(
                    "Your Role",
                    controller.userRoleText,
                    Icons.admin_panel_settings,
                    valueColor:
                        controller.userRoleText == "Tournament Admin"
                            ? Colors.deepOrange
                            : Colors.green,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: valueColor ?? Colors.grey[800],
                fontWeight:
                    valueColor != null ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesSection(TournamentController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sports, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "Tournament Matches",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    "${controller.matches.length} matches",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.matches.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_cricket_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No matches yet",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.isUserScorer.value
                          ? "Add your first match using the + button"
                          : "No matches have been created for this tournament",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.matches.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final match = controller.matches[index];
                return _buildMatchCard(match, controller);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMatchCard(
    CreateMatchModel match,
    TournamentController controller,
  ) {
    final team1 = match.team1Name ?? 'Team A';
    final team2 = match.team2Name ?? 'Team B';
    final matchDate =
        match.matchDate != null
            ? DateFormat('MMM d').format(match.matchDate!)
            : 'TBD';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.viewMatch(match),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sports_cricket, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$team1 vs $team2',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matchDate,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () =>
                    controller.isUserScorer.value
                        ? ElevatedButton(
                          onPressed: () => controller.startMatch(match),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            "Start",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )
                        : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "View",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey[600],
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
}
