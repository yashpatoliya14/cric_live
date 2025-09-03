import 'package:cric_live/utils/import_exports.dart';

class TossDecisionView extends StatelessWidget {
  // The controller is passed from the parent view to manage state

  const TossDecisionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the controller that was created by the previous page.
    // This allows us to share state seamlessly.
    final controller = Get.find<CreateMatchController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Toss & Players"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            children: [
              // --- Toss Section ---
              _buildSectionHeader(
                context,
                '2. Toss & Decision',
                Icons.casino_rounded,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              // --- Player Selection Section ---
              _buildSectionHeader(
                context,
                '3. Select Players',
                Icons.people_rounded,
              ),
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
          ),
        ),
      ),
      // ...
      floatingActionButton: Obx(() {
        // The UI just reads the isReady flag.
        // The worker in the controller updates this flag automatically.
        return FloatingActionButton.extended(
          onPressed:
              controller.isReady.value ? () => controller.startMatch() : null,
          backgroundColor:
              controller.isReady.value
                  ? theme.colorScheme.primary
                  : theme.disabledColor,
          // ... rest of your UI code
          label: Text(
            controller.isReady.value ? "Start Match" : "Select Players",
            // ...
          ),
        );
      }),
      //...
    );
  }
  // Helper methods that were moved from create_match_view.dart
  // These are now specific to this widget.

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
    if (title.toLowerCase().contains('bat')) {
      return Icons.sports_cricket_rounded;
    } else if (title.toLowerCase().contains('bowl')) {
      return Icons.sports_baseball_rounded;
    } else if (title.toLowerCase().contains('team')) {
      return Icons.groups_rounded;
    }
    return null;
  }
}
