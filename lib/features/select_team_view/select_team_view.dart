import 'package:cric_live/utils/import_exports.dart';

class SelectTeamView extends StatelessWidget {
  const SelectTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectTeamController());

    return Obx(() {
      // Convert SelectTeamModel to TeamSelectionModel
      final teams =
          controller.teams.map((team) {
            return TeamSelectionModel(
              id: team.id,
              teamId: team.teamId,
              teamName: team.teamName ?? 'Unnamed Team',
              tournamentId: team.tournamentId,
              isActive: true, // Assuming all teams are active by default
              totalPlayers:
                  null, // This data might not be available in the current model
              totalMatches:
                  null, // This data might not be available in the current model
              wins:
                  null, // This data might not be available in the current model
              losses:
                  null, // This data might not be available in the current model
            );
          }).toList();

      return RefreshIndicator(
        onRefresh: () async {
          controller.getAllTeams();
        },
        child: SafeArea(
          top: false,
          child: TeamSelectionWidget(
            title: APPBAR_SELECT_TEAM,
            teams: teams,
            searchHint: 'Search teams',
            isLoading: controller.teams.isEmpty,
            showStats: false, // Hide stats since we don't have the data yet
            onTeamSelected: (selectedTeam) {
              // Return the team data in the expected format
              Get.back(
                result: {
                  "teamId": selectedTeam.teamId,
                  "teamName": selectedTeam.teamName,
                },
              );
            },
            onViewPlayers: (team) {
              Get.toNamed(
                NAV_PLAYERS,
                arguments: {'teamId': team.teamId, 'isView': true},
              );
            },
            onDeleteTeam: (team) {
              // Convert TeamSelectionModel to SelectTeamModel for deletion
              final selectTeamModel = SelectTeamModel(
                id: team.id,
                teamId: team.teamId,
                teamName: team.teamName,
                tournamentId: team.tournamentId,
              );
              controller.deleteTeam(selectTeamModel);
            },
            onCreateTeam: () async {
              final result = await Get.toNamed(NAV_CREATE_TEAM);
              if (result != null) {
                // Team was created successfully, pass the result back to the previous page
                Get.back(result: result);
              } else {
                // User cancelled team creation, just refresh the team list
                controller.getAllTeams();
              }
            },
            emptyState: _buildCustomEmptyState(context),
            loadingWidget: _buildCustomLoading(context),
          ),
        ),
      );
    });
  }

  Widget _buildCustomEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_cricket_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Teams Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first team to get started with cricket matches',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.toNamed(NAV_CREATE_TEAM);
              if (result != null) {
                // Team was created successfully, pass the result back to the previous page
                Get.back(result: result);
              }
              // If result is null (user cancelled), stay on this screen
            },
            icon: Icon(Icons.add_rounded),
            label: Text('Create First Team'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomLoading(BuildContext context) {
    return const FullScreenLoader(
      message:
          'Loading Teams...\nPlease wait while we fetch your cricket teams',
    );
  }
}
