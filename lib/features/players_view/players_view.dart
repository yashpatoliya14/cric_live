import 'package:cric_live/utils/import_exports.dart';

class PlayersView extends StatelessWidget {
  const PlayersView({super.key});

  @override
  Widget build(BuildContext context) {
    final int teamId = Get.arguments['teamId'];
    final bool isView = Get.arguments['isView'];
    final controller = Get.put(
      PlayersController(teamId: teamId, isView: isView),
    );

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: const CommonAppHeader(
        title: 'Team Players',
        subtitle: 'Squad Members',
        leadingIcon: Icons.group,
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
        try {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState(controller);
          }

          if (controller.players.isEmpty) {
            return _buildEmptyState();
          }

          return _buildPlayersList(controller);
        } catch (e) {
          return _buildErrorStateWithMessage('An unexpected error occurred');
        }
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const FullScreenLoader(
      message: 'Loading Players...',
      loaderColor: Colors.deepOrange,
    );
  }

  Widget _buildErrorState(PlayersController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
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
              "Something went wrong",
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
              onPressed: () => controller.refreshPlayers(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
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
                color: Colors.deepOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_off,
                size: 48,
                color: Colors.deepOrange.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Players Found",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This team doesn't have any players yet.",
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

  Widget _buildPlayersList(PlayersController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshPlayers(),
      color: Colors.deepOrange,
      backgroundColor: Colors.white,
      child: Builder(
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats header
                _buildStatsHeader(controller),
                const SizedBox(height: 20),

                // Players grid
                Expanded(
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveUtils.width(context, 1) > 600 ? 3 : 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: controller.players.length,
                    itemBuilder: (context, index) {
                      final player = controller.players[index];
                      return _buildPlayerCard(player, index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(PlayersController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.group, color: Colors.deepOrange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Players",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${controller.players.length}",
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.deepOrange,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  controller.hasMinimumPlayers
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.teamStatus,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    controller.hasMinimumPlayers
                        ? Colors.green[700]
                        : Colors.orange[700],
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayersModel player, int index) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Add player details navigation if needed
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player avatar and number
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange.withValues(alpha: 0.8),
                            Colors.deepOrange.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Player ${index + 1}",
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Player name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player.playerName ?? "Unknown Player",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "ID: ${player.teamPlayerId ?? 'N/A'}",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.deepOrange[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Tap for details",
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange[600],
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorStateWithMessage(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
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
}
