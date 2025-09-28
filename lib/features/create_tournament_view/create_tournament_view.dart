import 'package:cric_live/utils/import_exports.dart';

class CreateTournamentView extends StatelessWidget {
  const CreateTournamentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateTournamentController>();

    return Scaffold(
      appBar: const CommonAppHeader(
        title: 'Create Tournament',
        subtitle: 'Organize your cricket tournament',
        leadingIcon: Icons.emoji_events,
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
        if (controller.isLoading.value) {
          return const FullScreenLoader(message: 'Loading users and teams...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(controller),
              const SizedBox(height: 24),
              _buildDateSection(context, controller),
              const SizedBox(height: 24),
              _buildScorersSection(controller),
              const SizedBox(height: 24),
              _buildTeamsSection(controller),
              const SizedBox(height: 32),
              _buildCreateButton(controller),
              const SizedBox(height: 16),
              if (controller.errorMessage.value.isNotEmpty)
                _buildErrorMessage(controller),
              if (controller.successMessage.value.isNotEmpty)
                _buildSuccessMessage(controller),
            ],
          ),
        );
        }),
      ),
    );
  }

  Widget _buildBasicInfoSection(CreateTournamentController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tournament Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Tournament Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_cricket),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.formatController,
              decoration: const InputDecoration(
                labelText: 'Format (e.g., T20, ODI) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_bulleted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    CreateTournamentController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tournament Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () => controller.selectStartDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Start: ${_formatDate(controller.startDate.value)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () => controller.selectEndDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'End: ${_formatDate(controller.endDate.value)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
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

  Widget _buildScorersSection(CreateTournamentController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Scorers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Type a name, username, or email and click Search to find users.',
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.scorerSearchController,
                    decoration: const InputDecoration(
                      labelText: 'Search users...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Type to search by name, username, or email',
                    ),
                    onFieldSubmitted: (_) => controller.searchUsers(),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed:
                        controller.isSearching.value
                            ? null
                            : controller.searchUsers,
                    icon:
                        controller.isSearching.value
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(Icons.search, size: 18),
                    label: Text(
                      controller.isSearching.value ? 'Searching...' : 'Search',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => controller.searchedUsers.isNotEmpty ||
                      controller.lastSearchQuery.value.isNotEmpty
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: controller.clearSearch,
                            icon: Icon(Icons.clear, size: 20),
                            tooltip: 'Clear search',
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUserSuggestions(controller),
            const SizedBox(height: 16),
            _buildSelectedScorers(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSuggestions(CreateTournamentController controller) {
    return Obx(() {
      final List<UserModel> users = controller.searchedUsers;
      final bool isLoading = controller.isSearching.value;
      final String lastQuery = controller.lastSearchQuery.value;

      if (isLoading) {
        return Container(
          height: 120,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      }

      if (users.isEmpty && lastQuery.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No users found. Try a different search.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      }

      if (users.isNotEmpty) {
        return Container(
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = controller.isUserSelected(user);

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    _getAvatarText(user),
                  ),
                ),
                title: Text(
                  user.fullDisplayName.isNotEmpty 
                      ? user.fullDisplayName 
                      : 'Unknown User (${user.userName ?? 'No username'})'
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email ?? 'No email'),
                    if (user.userName != null && user.userName!.isNotEmpty)
                      Text('@${user.userName}', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey.shade600
                        )
                      ),
                  ],
                ),
                trailing:
                    isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue,
                        ),
                onTap: isSelected ? null : () => controller.addScorer(user),
                enabled: !isSelected,
              );
            },
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildSelectedScorers(CreateTournamentController controller) {
    return Obx(() {
      if (controller.selectedScorers.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'No scorers selected. Please search and select at least one scorer.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Scorers:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                controller.selectedScorers.map((user) {
                  return Chip(
                    avatar: CircleAvatar(
                      child: Text(
                        _getAvatarText(user),
                      ),
                    ),
                    label: Text(user.fullDisplayName),
                    onDeleted: () => controller.removeScorer(user),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildTeamsSection(CreateTournamentController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Teams * (Minimum 2)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToSelectTeam(controller),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Select Team'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),

            // Available teams
            // Obx(() {
            //   if (controller.allTeams.isEmpty) {
            //     return Container(
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(
            //         color: Colors.grey.shade100,
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: const Text(
            //         'No teams available. Please create teams first.',
            //         style: TextStyle(color: Colors.grey),
            //       ),
            //     );
            //   }
            //
            //   return Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Available Teams:',
            //         style: TextStyle(fontWeight: FontWeight.w600),
            //       ),
            //       const SizedBox(height: 8),
            //     ],
            //   );
            // }),
            const SizedBox(height: 16),

            // Selected teams
            Obx(() {
              if (controller.selectedTeams.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'Please select at least 2 teams for the tournament.',
                    style: TextStyle(color: Colors.orange),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Teams (${controller.selectedTeams.length}):',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        controller.selectedTeams.map((team) {
                          return Chip(
                            avatar: const Icon(Icons.sports_cricket, size: 18),
                            label: Text(team.name ?? 'Unknown'),
                            onDeleted: () => controller.removeTeam(team),
                            deleteIcon: const Icon(Icons.close, size: 18),
                          );
                        }).toList(),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(CreateTournamentController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              controller.isCreatingTournament.value
                  ? null
                  : controller.isFormValid.value
                  ? controller.createTournament
                  : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              controller.isCreatingTournament.value
                  ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Creating Tournament...'),
                    ],
                  )
                  : const Text(
                    'Create Tournament',
                    style: TextStyle(fontSize: 16),
                  ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(CreateTournamentController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(CreateTournamentController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.successMessage.value,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Navigate to select team view and handle result
  Future<void> _navigateToSelectTeam(
    CreateTournamentController controller,
  ) async {
    final result = await Get.toNamed(
      NAV_SELECT_TEAM,
      arguments: {"wantToStore": false},
    );

    if (result != null && result is Map<String, dynamic>) {
      final teamId = result['teamId'] as int?;
      final teamName = result['teamName'] as String?;

      if (teamId != null && teamName != null) {
        // Create a TeamModel object and add it to selected teams
        TeamModel newTeam = TeamModel(
          id: teamId,
          name: teamName,
          shortName: teamName,
        );

        // Check if team is already selected
        bool alreadySelected = controller.selectedTeams.any(
          (team) => team.id == teamId,
        );

        if (!alreadySelected) {
          controller.addTeam(newTeam);
          Get.snackbar(
            'Team Added',
            '$teamName has been added to the tournament!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Team Already Added',
            '$teamName is already selected for this tournament.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      }
    }
  }

  /// Get appropriate text for user avatar
  String _getAvatarText(UserModel user) {
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName![0].toUpperCase();
    }
    if (user.lastName != null && user.lastName!.isNotEmpty) {
      return user.lastName![0].toUpperCase();
    }
    if (user.userName != null && user.userName!.isNotEmpty) {
      return user.userName![0].toUpperCase();
    }
    return 'U';
  }
}
