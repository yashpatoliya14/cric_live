import 'package:cric_live/utils/import_exports.dart';

class CreateMatchView extends StatelessWidget {
  CreateMatchView({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GetX<CreateMatchController>(
      builder:
          (controller) => Form(
            key: _formKey,
            child: SafeArea(
              top: false,
              child: Scaffold(
                backgroundColor: colorScheme.surface,
                appBar: _buildModernAppBar(context),

                body: _buildBody(context, controller),
                bottomNavigationBar: _buildActionButtons(context, controller),
              ),
            ),
          ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          // Button 1: Schedule Match
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                // Add logic to save the match as "scheduled"
                controller.onCreateMatch(isScheduled: true);
              },
              child: Text("Schedule Match"),
            ),
          ),
          const SizedBox(width: 16),
          // Button 2: Proceed to Toss
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                controller.onCreateMatch(isScheduled: false);
              },
              child: Text("Proceed to Toss"),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        APPBAR_CREATE_MATCH,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, CreateMatchController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderCard(context),
            const SizedBox(height: 20),

            // Team Selection Section
            _buildTeamSelectionSection(context, controller),
            const SizedBox(height: 24),
            // Toss and Decision Section
            // _buildTossDecisionSection(context, controller),
            const SizedBox(height: 24),
            // Match Settings Section
            _buildMatchSettingsSection(context, controller),
            const SizedBox(height: 24),
            // Overs Section
            _buildOversSection(context, controller),
            const SizedBox(height: 24),
            // Player Selection Section
            // _buildPlayerSelectionSection(context, controller),
            const SizedBox(height: 24),
            // Match Preview Section
            _buildMatchPreviewSection(context, controller),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  // In the _buildFloatingActionButton method

  Widget _buildFloatingActionButton(
    BuildContext context,
    CreateMatchController controller,
  ) {
    final theme = Theme.of(context);
    // You can adjust this logic based on what's needed before the toss
    final isReadyForToss =
        controller.team1.isNotEmpty &&
        controller.team2.isNotEmpty &&
        controller.controllerOvers.text.isNotEmpty;

    return FloatingActionButton.extended(
      // The onPressed function is the key change here
      onPressed:
          isReadyForToss
              ? () {
                // Run validation before navigating
                String? validationError = controller.validatePreTossSettings();
                if (validationError != null) {
                  Get.snackbar("Validation Error", validationError /* ... */);
                  return;
                }
                // Navigate to the new Toss Decision page
                Get.toNamed(NAV_TOSS_DECISION);
              }
              : null,
      backgroundColor:
          isReadyForToss ? theme.colorScheme.primary : theme.disabledColor,
      // ... other properties
      label: Text(
        isReadyForToss ? "Proceed to Toss" : "Complete Setup", // Changed text
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  bool _isMatchReady(CreateMatchController controller) {
    return controller.team1.isNotEmpty &&
        controller.team2.isNotEmpty &&
        controller.controllerOvers.text.isNotEmpty &&
        controller.batsmanList.length == 2 &&
        controller.bowlerList.isNotEmpty;
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_cricket_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Create New Cricket Match',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up teams, toss, and match settings',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelectionSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '1. Select Teams', Icons.groups_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModernTeamSelector(
                context: context,
                title: controller.team1['teamName'] ?? "Select Team A",
                subtitle: "Home Team",
                isSelected: controller.team1.isNotEmpty,
                icon: Icons.home_rounded,
                onPressed: () async {
                  final result = await Get.toNamed(
                    NAV_SELECT_TEAM,
                    arguments: {"tournamentId": controller.tournamentId},
                  );
                  if (result != null && result is Map) {
                    controller.setTeam1(Map<String, dynamic>.from(result));
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModernTeamSelector(
                context: context,
                title: controller.team2['teamName'] ?? "Select Team B",
                subtitle: "Away Team",
                isSelected: controller.team2.isNotEmpty,
                icon: Icons.flight_takeoff_rounded,
                onPressed: () async {
                  final result = await Get.toNamed(
                    NAV_SELECT_TEAM,
                    arguments: {"tournamentId": controller.tournamentId},
                  );
                  if (result != null && result is Map) {
                    controller.setTeam2(Map<String, dynamic>.from(result));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTeamSelector({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? theme.colorScheme.primaryContainer : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : icon,
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTossDecisionSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          '2. Toss & Decision',
          Icons.casino_rounded,
        ),
        const SizedBox(height: 16),

        // Toss Winner Selection
        _buildModernSelectionCard(
          context: context,
          title: 'Toss Winner',
          child: _buildModernRadioGroup(
            context: context,
            title1: controller.team1['teamName'] ?? TEAM_A,
            title2: controller.team2['teamName'] ?? TEAM_B,
            currentValue: controller.tossWinnerTeam.value,
            onChanged: controller.onTossWinnerTeamChanged,
          ),
        ),

        const SizedBox(height: 12),

        // Bat or Bowl Decision
        _buildModernSelectionCard(
          context: context,
          title: 'Choose to Bat or Bowl',
          child: _buildModernRadioGroup(
            context: context,
            title1: BAT,
            title2: BOWL,
            currentValue: controller.batOrBowl.value,
            onChanged: controller.onbatOrBowlChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchSettingsSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          '3. Match Settings',
          Icons.settings_rounded,
        ),
        const SizedBox(height: 16),

        _buildModernSelectionCard(
          context: context,
          title: 'Extra Runs Configuration',
          child: Column(
            children: [
              _buildModernToggleOption(
                context: context,
                title: 'No-ball Runs',
                subtitle: 'Allow extra runs for no-balls',
                value: controller.isNoBall.value,
                onChanged: controller.onNoBallChanged,
                inputController: controller.controllerNoBallRun,
                icon: Icons.sports_baseball_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernToggleOption(
                context: context,
                title: 'Wide Runs',
                subtitle: 'Allow extra runs for wides',
                value: controller.isWide.value,
                onChanged: controller.onWideChanged,
                inputController: controller.controllerWideRun,
                icon: Icons.open_in_full_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOversSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '4. Match Format', Icons.timer_rounded),
        const SizedBox(height: 16),

        _buildModernSelectionCard(
          context: context,
          title: 'Number of Overs',
          child: TextFormField(
            controller: controller.controllerOvers,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter overs (1-100)',
              hintText: 'e.g., 20',
              prefixIcon: Icon(Icons.sports_cricket_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number of overs';
              }
              int? overs = int.tryParse(value);
              if (overs == null || overs <= 0 || overs > 50) {
                return 'Please enter a valid number (1-50)';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}$')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSelectionSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '5. Select Players', Icons.people_rounded),
        const SizedBox(height: 16),

        _buildEnhancedPlayerSelector(
          context: context,
          label: 'Opening Batsmen',
          subtitle: 'Select 2 batsmen to start the innings',
          playerNames:
              controller.batsmanList.isNotEmpty
                  ? '${controller.batsmanList[0].playerName ?? ""} & ${controller.batsmanList.length > 1 ? controller.batsmanList[1].playerName ?? "" : "Select 2nd"}'
                  : null,
          icon: Icons.sports_cricket_rounded,
          isSelected: controller.batsmanList.length == 2,
          onTap: () => controller.selectBatsman(),
        ),

        const SizedBox(height: 12),

        _buildEnhancedPlayerSelector(
          context: context,
          label: 'Opening Bowler',
          subtitle: 'Select 1 bowler to start the bowling',
          playerNames:
              controller.bowler.value.isNotEmpty
                  ? controller.bowler.value
                  : null,
          icon: Icons.sports_baseball_rounded,
          isSelected: controller.bowlerList.isNotEmpty,
          onTap: () => controller.selectBowler(),
        ),
      ],
    );
  }

  Widget _buildMatchPreviewSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    final isComplete = _isMatchReady(controller);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '6. Match Summary', Icons.preview_rounded),
        const SizedBox(height: 16),

        Card(
          elevation: isComplete ? 3 : 1,
          color:
              isComplete
                  ? Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.5)
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isComplete
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      color: isComplete ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isComplete ? 'Ready to Start!' : 'Setup in Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isComplete ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildProgressItem(
                  'Teams Selected',
                  controller.team1.isNotEmpty && controller.team2.isNotEmpty,
                ),
                _buildProgressItem(
                  'Toss & Decision',
                  controller.tossWinnerTeam.value.isNotEmpty,
                ),
                _buildProgressItem(
                  'Match Format',
                  controller.controllerOvers.text.isNotEmpty,
                ),
                _buildProgressItem(
                  'Players Selected',
                  controller.batsmanList.length == 2 &&
                      controller.bowlerList.isNotEmpty,
                ),

                if (isComplete) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Match Preview:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${controller.team1['teamName'] ?? ''} vs ${controller.team2['teamName'] ?? ''}',
                        ),
                        Text('${controller.controllerOvers.text} overs match'),
                        Text(
                          'Toss: ${controller.tossWinnerTeam.value} chose to ${controller.batOrBowl.value.toLowerCase()}',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepProgress(
    BuildContext context,
    CreateMatchController controller,
  ) {
    int currentStep = _getCurrentStep(controller);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: StepProgressIndicator(currentStep: currentStep, totalSteps: 6),
    );
  }

  int _getCurrentStep(CreateMatchController controller) {
    // Step 1: Teams selected
    if (controller.team1.isEmpty || controller.team2.isEmpty) {
      return 1;
    }

    // Step 2: Toss and decision
    if (controller.tossWinnerTeam.value.isEmpty ||
        controller.batOrBowl.value.isEmpty) {
      return 2;
    }

    // Step 3: Match settings (optional, so we can skip to step 4)
    // Step 4: Overs configured
    if (controller.controllerOvers.text.isEmpty) {
      return 4;
    }

    // Step 5: Players selected
    if (controller.batsmanList.length < 2 || controller.bowlerList.isEmpty) {
      return 5;
    }

    // Step 6: Ready to start
    return 6;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSelectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildModernRadioGroup({
    required BuildContext context,
    required String title1,
    required String title2,
    required String currentValue,
    required Function onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedRadioOption(
              context: context,
              title: title1,
              value: title1,
              groupValue: currentValue,
              onChanged: onChanged,
              icon: _getRadioIcon(title1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEnhancedRadioOption(
              context: context,
              title: title2,
              value: title2,
              groupValue: currentValue,
              onChanged: onChanged,
              icon: _getRadioIcon(title2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String title,
    required String value,
    required String groupValue,
    required Function onChanged,
  }) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:
            isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (val) => onChanged(val),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color:
                isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
          ),
        ),
        activeColor: theme.colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildModernToggleOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function onChanged,
    required TextEditingController inputController,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            value
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              value
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    value
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: value, onChanged: (val) => onChanged(val)),
            ],
          ),
          if (value) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: inputController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Runs',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  isDense: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]{1}$')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedPlayerSelector({
    required BuildContext context,
    required String label,
    required String subtitle,
    required String? playerNames,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 3 : 1,
      margin: EdgeInsets.zero,
      color:
          isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
              : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : icon,
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playerNames ?? subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.8)
                                : theme.colorScheme.onSurfaceVariant,
                        fontStyle:
                            playerNames != null
                                ? FontStyle.normal
                                : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRadioOption({
    required BuildContext context,
    required String title,
    required String value,
    required String groupValue,
    required Function onChanged,
    required IconData? icon,
  }) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary.withOpacity(0.2)
                          : theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData? _getRadioIcon(String title) {
    // Return appropriate icons based on the title
    if (title.toLowerCase().contains('bat')) {
      return Icons.sports_cricket_rounded;
    } else if (title.toLowerCase().contains('bowl')) {
      return Icons.sports_baseball_rounded;
    } else if (title.toLowerCase().contains('team')) {
      return Icons.groups_rounded;
    }
    return null; // No icon for generic options
  }

  Widget _buildProgressItem(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isCompleted ? Colors.green : Colors.grey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Legacy methods kept for compatibility but not used in new design
  _buildCircleAvatar({
    required String title,
    required Function onPressed,
    bool isSelected = false,
  }) {
    return Column(
      children: [
        CircleAvatar(
          maxRadius: 50,
          backgroundColor: isSelected ? Colors.green.shade100 : null,
          child: IconButton(
            padding: EdgeInsets.all(38),
            icon: Icon(
              isSelected ? Icons.check : Icons.add,
              color: isSelected ? Colors.green.shade700 : null,
            ),
            onPressed: () => onPressed(),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.green.shade700 : null,
          ),
        ),
        if (isSelected)
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Selected",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // Legacy method kept for compatibility
  _buildRadioButton({
    required String title1,
    required String title2,
    required String currentValue,
    required Function onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            value: title1,
            groupValue: currentValue,
            onChanged: (value) => onChanged(value),
            title: Text(title1),
          ),
        ),
        Expanded(
          child: RadioListTile(
            value: title2,
            groupValue: currentValue,
            onChanged: (value) => onChanged(value),
            title: Text(title2),
          ),
        ),
      ],
    );
  }

  // Legacy method kept for compatibility
  _buildTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 2, color: Colors.blueGrey, child: Text("")),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
        Expanded(
          child: Container(height: 2, color: Colors.blueGrey, child: Text("")),
        ),
      ],
    );
  }

  // Legacy method kept for compatibility
  Widget _buildChecklistItem(String title, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
