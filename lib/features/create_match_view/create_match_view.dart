import 'package:cric_live/utils/import_exports.dart';

class CreateMatchView extends StatelessWidget {
  CreateMatchView({super.key});

  // Make form key static to persist across rebuilds
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                appBar: const CommonAppHeader(
                  title: 'Create Match',
                  subtitle: 'Set up a new cricket match',
                  leadingIcon: Icons.sports_cricket,
                ),

                body: _buildBody(context, controller),
                bottomNavigationBar: _buildActionButtons(
                  context,
                  controller,
                  _formKey,
                ),
              ),
            ),
          ),
    );
  }

  /// Comprehensive form validation function
  bool _validateForm(
    GlobalKey<FormState> formKey,
    CreateMatchController controller,
  ) {
    // First validate the form fields (like overs input)
    if (!formKey.currentState!.validate()) {
      _showValidationError('Please fix the form errors above.');
      return false;
    }

    // Then validate business logic
    String? validationError = controller.validateMatchCreation();
    if (validationError != null) {
      _showValidationError(validationError);
      return false;
    }

    return true;
  }

  /// Show validation error with consistent styling
  void _showValidationError(String message) {
    Get.snackbar(
      '⚠️ Validation Error',
      message,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      borderColor: Colors.red.shade300,
      borderWidth: 1,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.error_outline, color: Colors.red.shade600),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CreateMatchController controller,
    GlobalKey<FormState> formKey,
  ) {
    // Check if basic setup is complete for enabling buttons
    final bool basicSetupComplete =
        controller.team1.isNotEmpty &&
        controller.team2.isNotEmpty &&
        controller.controllerOvers.text.isNotEmpty &&
        controller.team1['teamId'] != controller.team2['teamId'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Button 1: Schedule Match
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    basicSetupComplete
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: basicSetupComplete ? 2 : 0,
              ),
              onPressed:
                  basicSetupComplete
                      ? () {
                        if (_validateForm(formKey, controller)) {
                          controller.onCreateMatch(isScheduled: true);
                        }
                      }
                      : null,
              icon: const Icon(Icons.schedule, size: 20),
              label:
                  !controller.isScheduledMatch.value
                      ? Text(
                        controller.isSchedulingDateTimeValid 
                            ? "Schedule Match" 
                            : "Schedule Match (Select Date & Time)",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      )
                      : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 16),
          // Button 2: Proceed to Toss
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    basicSetupComplete
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: basicSetupComplete ? 3 : 0,
              ),
              onPressed:
                  basicSetupComplete
                      ? () {
                        if (_validateForm(formKey, controller)) {
                          controller.onCreateMatch(isScheduled: false);
                        }
                      }
                      : null,
              icon: const Icon(Icons.sports_cricket, size: 20),
              label:
                  !controller.isCreatingMatch.value
                      ? const Text(
                        "Proceed to Toss",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                      : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
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
            // Match Settings Section
            _buildMatchSettingsSection(context, controller),
            const SizedBox(height: 24),
            // Date/Time Selection Section (shown when scheduling or toggled)
            Obx(() {
              if (controller.isDateTimeRequired.value) {
                // For scheduled matches - date/time is REQUIRED
                return Column(
                  children: [
                    _buildRequiredDateTimeSection(context, controller),
                    const SizedBox(height: 24),
                  ],
                );
              } else if (controller.showDateTimeSelection.value) {
                // For immediate matches - date/time is optional
                return Column(
                  children: [
                    _buildDateTimeSelectionSection(context, controller),
                    const SizedBox(height: 24),
                  ],
                );
              } else {
                // Show toggle to add optional date/time
                return _buildDateTimeToggleSection(context, controller);
              }
            }),
            // Overs Section
            _buildOversSection(context, controller),
            const SizedBox(height: 24),
            // Match Preview Section
            _buildMatchPreviewSection(context, controller),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  bool _isMatchReady(CreateMatchController controller) {
    return controller.team1.isNotEmpty &&
        controller.team2.isNotEmpty &&
        controller.controllerOvers.text.isNotEmpty &&
        controller.team1['teamId'] != controller.team2['teamId'];
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
              'Set up teams and match settings',
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
    final bool teamsValid =
        controller.team1.isNotEmpty &&
        controller.team2.isNotEmpty &&
        controller.team1['teamId'] != controller.team2['teamId'];
    final bool showError =
        controller.team1.isNotEmpty &&
        controller.team2.isNotEmpty &&
        controller.team1['teamId'] == controller.team2['teamId'];

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
        // Error message for same team selection
        if (showError) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please select different teams. Both teams cannot be the same.',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Success message for valid team selection
        if (teamsValid) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Teams selected: ${controller.team1['teamName']} vs ${controller.team2['teamName']}',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildMatchSettingsSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          '2. Match Settings',
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
        Obx(() => _buildSectionHeader(
          context, 
          (controller.isDateTimeRequired.value || controller.showDateTimeSelection.value) ? '4. Match Format' : '3. Match Format', 
          Icons.timer_rounded
        )),
        const SizedBox(height: 16),

        _buildModernSelectionCard(
          context: context,
          title: 'Number of Overs',
          child: TextFormField(
            controller: controller.controllerOvers,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter overs (1-50)',
              hintText: 'e.g., 20 for T20, 50 for ODI',
              helperText: 'Number of overs per team',
              prefixIcon: const Icon(Icons.sports_cricket_rounded),
              suffixText: 'overs',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
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
              if (overs == null || overs <= 0) {
                return 'Overs must be a positive number';
              }
              if (overs > 50) {
                return 'Maximum 50 overs allowed';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}$')),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
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
        Obx(() => _buildSectionHeader(
          context, 
          (controller.isDateTimeRequired.value || controller.showDateTimeSelection.value) ? '5. Match Summary' : '4. Match Summary', 
          Icons.preview_rounded
        )),
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
                  'Match Settings Configured',
                  true, // Match settings are always available
                ),
                _buildProgressItem(
                  'Match Format Set',
                  controller.controllerOvers.text.isNotEmpty,
                ),
                // Show date/time progress for scheduled matches or when optional selection is shown
                Obx(() => (controller.isDateTimeRequired.value || controller.showDateTimeSelection.value)
                    ? _buildProgressItem(
                        'Date & Time Selected',
                        controller.selectedMatchDate.value != null && controller.selectedMatchTime.value != null,
                      )
                    : const SizedBox.shrink()),

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
                        Text(
                          '${controller.controllerOvers.text} overs per team',
                        ),
                        // Show scheduled date/time if applicable
                        Obx(() => (controller.isDateTimeRequired.value || controller.showDateTimeSelection.value) && 
                               controller.scheduledDateTime != null
                            ? Text(
                                'Scheduled: ${DateFormat('MMM dd, yyyy \'at\' h:mm a').format(controller.scheduledDateTime!)}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const SizedBox.shrink()),
                        Text(
                          controller.isDateTimeRequired.value 
                              ? 'Ready to schedule match' 
                              : 'Ready for toss and player selection',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  int? runs = int.tryParse(value);
                  if (runs == null || runs < 0 || runs > 6) {
                    return '0-6 only';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-6]$')),
                ],
              ),
            ),
          ],
        ],
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

  Widget _buildDateTimeToggleSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      children: [
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: controller.toggleDateTimeSelection,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Match (Optional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set a specific date and time for your match',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRequiredDateTimeSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          '3. Schedule Match (Required)',
          Icons.schedule_rounded,
        ),
        const SizedBox(height: 8),
        // Required notice
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Date and time selection is required for scheduled matches',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        _buildModernSelectionCard(
          context: context,
          title: 'Select Date & Time *',
          child: Column(
            children: [
              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildDateTimeSelector(
                      context: context,
                      title: 'Match Date *',
                      icon: Icons.calendar_today_rounded,
                      value: controller.selectedMatchDate.value != null
                          ? DateFormat('EEE, MMM dd, yyyy')
                              .format(controller.selectedMatchDate.value!)
                          : 'Required - Select Date',
                      isSelected: controller.selectedMatchDate.value != null,
                      onTap: controller.selectMatchDate,
                      isRequired: true,
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _buildDateTimeSelector(
                      context: context,
                      title: 'Match Time *',
                      icon: Icons.access_time_rounded,
                      value: controller.selectedMatchTime.value != null
                          ? controller.selectedMatchTime.value!.format(context)
                          : 'Required - Select Time',
                      isSelected: controller.selectedMatchTime.value != null,
                      onTap: controller.selectMatchTime,
                      isRequired: true,
                    )),
                  ),
                ],
              ),
              
              // Selected DateTime Preview
              Obx(() {
                if (controller.scheduledDateTime != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Match Scheduled for:',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, MMMM dd, yyyy \'at\' h:mm a')
                                    .format(controller.scheduledDateTime!),
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectionSection(
    BuildContext context,
    CreateMatchController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionHeader(
                context,
                '3. Schedule Match (Optional)',
                Icons.schedule_rounded,
              ),
            ),
            IconButton(
              onPressed: controller.clearDateTimeSelection,
              icon: Icon(
                Icons.close_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Remove scheduling',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildModernSelectionCard(
          context: context,
          title: 'Select Date & Time',
          child: Column(
            children: [
              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildDateTimeSelector(
                      context: context,
                      title: 'Match Date',
                      icon: Icons.calendar_today_rounded,
                      value: controller.selectedMatchDate.value != null
                          ? DateFormat('EEE, MMM dd, yyyy')
                              .format(controller.selectedMatchDate.value!)
                          : 'Select Date',
                      isSelected: controller.selectedMatchDate.value != null,
                      onTap: controller.selectMatchDate,
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _buildDateTimeSelector(
                      context: context,
                      title: 'Match Time',
                      icon: Icons.access_time_rounded,
                      value: controller.selectedMatchTime.value != null
                          ? controller.selectedMatchTime.value!.format(context)
                          : 'Select Time',
                      isSelected: controller.selectedMatchTime.value != null,
                      onTap: controller.selectMatchTime,
                    )),
                  ),
                ],
              ),
              
              // Selected DateTime Preview
              Obx(() {
                if (controller.scheduledDateTime != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Match Scheduled for:',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, MMMM dd, yyyy \'at\' h:mm a')
                                    .format(controller.scheduledDateTime!),
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : isRequired && !isSelected
                  ? Colors.red.shade50.withOpacity(0.5)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.5)
                : isRequired && !isSelected
                    ? Colors.red.shade400
                    : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected || (isRequired && !isSelected) ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isRequired && !isSelected
                            ? Colors.red.shade700
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : isRequired && !isSelected
                        ? Colors.red.shade700
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
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
