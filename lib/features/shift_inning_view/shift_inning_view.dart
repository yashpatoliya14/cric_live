import 'package:cric_live/utils/import_exports.dart';

class ShiftInningView extends StatelessWidget {
  const ShiftInningView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShiftInningController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _LoadingView();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _ErrorView(
              message: controller.errorMessage.value,
              onRetry: () => controller.initializeMatch(),
            );
          }

          return _MainView(controller: controller);
        }),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const FullScreenLoader(message: 'Loading match data...');
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
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
}

class _MainView extends StatelessWidget {
  final ShiftInningController controller;

  const _MainView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              "Second Inning Setup",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Match Overview Card
              _MatchOverviewCard(controller: controller),
              const SizedBox(height: 24),

              // Setup Progress
              _SetupProgressCard(controller: controller),
              const SizedBox(height: 24),

              // Player Selection Cards
              _PlayerSelectionSection(controller: controller),
              const SizedBox(height: 32),

              // Action Button
              _StartInningButton(controller: controller),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MatchOverviewCard extends StatelessWidget {
  final ShiftInningController controller;

  const _MatchOverviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Obx(
          () => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TeamCard(
                      teamName: controller.team1.value,
                      isBatting: controller.battingTeamId == controller.team1Id,
                      label:
                          controller.battingTeamId == controller.team1Id
                              ? "Batting"
                              : "Bowling",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "VS",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TeamCard(
                      teamName: controller.team2.value,
                      isBatting: controller.battingTeamId == controller.team2Id,
                      label:
                          controller.battingTeamId == controller.team2Id
                              ? "Batting"
                              : "Bowling",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sports_cricket,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Second Inning",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String teamName;
  final bool isBatting;
  final String label;

  const _TeamCard({
    required this.teamName,
    required this.isBatting,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isBatting
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isBatting
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isBatting ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teamName.isNotEmpty ? teamName : "Loading...",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isBatting ? theme.colorScheme.primary : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isBatting
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isBatting
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupProgressCard extends StatelessWidget {
  final ShiftInningController controller;

  const _SetupProgressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final hasBatsmen =
          controller.strikerBatsman.value.isNotEmpty &&
          controller.nonStrikerBatsman.value.isNotEmpty;
      final hasBowler = controller.bowler.value.isNotEmpty;
      final completedSteps = (hasBatsmen ? 1 : 0) + (hasBowler ? 1 : 0);
      final progress = completedSteps / 2;

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
                  Icon(Icons.checklist_rtl, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Setup Progress",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "$completedSteps/2",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ProgressStep(
                    icon: Icons.sports_cricket,
                    label: "Batsmen",
                    isCompleted: hasBatsmen,
                  ),
                  const SizedBox(width: 24),
                  _ProgressStep(
                    icon: Icons.sports_baseball,
                    label: "Bowler",
                    isCompleted: hasBowler,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ProgressStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCompleted;

  const _ProgressStep({
    required this.icon,
    required this.label,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? Colors.green
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            size: 16,
            color: isCompleted ? Colors.white : theme.colorScheme.outline,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            color:
                isCompleted
                    ? Colors.green
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _PlayerSelectionSection extends StatelessWidget {
  final ShiftInningController controller;

  const _PlayerSelectionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Players",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _EnhancedPlayerSelectorTile(
            title: "Opening Batsmen",
            subtitle:
                "Select 2 opening batsmen for ${controller.battingTeamName}",
            icon: Icons.sports_cricket,
            playerNames: [
              controller.strikerBatsman.value,
              controller.nonStrikerBatsman.value,
            ],
            isLoading: controller.isSelectingBatsmen.value,
            onTap: () => controller.selectBatsman(),
            isCompleted:
                controller.strikerBatsman.value.isNotEmpty &&
                controller.nonStrikerBatsman.value.isNotEmpty,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _EnhancedPlayerSelectorTile(
            title: "Opening Bowler",
            subtitle:
                "Select 1 opening bowler for ${controller.bowlingTeamName}",
            icon: Icons.sports_baseball,
            playerNames: [controller.bowler.value],
            isLoading: controller.isSelectingBowler.value,
            onTap: () => controller.selectBowler(),
            isCompleted: controller.bowler.value.isNotEmpty,
          ),
        ),
      ],
    );
  }
}

class _EnhancedPlayerSelectorTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> playerNames;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isCompleted;

  const _EnhancedPlayerSelectorTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.playerNames,
    required this.isLoading,
    required this.onTap,
    required this.isCompleted,
  });

  @override
  State<_EnhancedPlayerSelectorTile> createState() =>
      _EnhancedPlayerSelectorTileState();
}

class _EnhancedPlayerSelectorTileState
    extends State<_EnhancedPlayerSelectorTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPlayers = widget.playerNames.any((name) => name.isNotEmpty);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: widget.isCompleted ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    widget.isCompleted
                        ? Colors.green.withValues(alpha: 0.5)
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: widget.isCompleted ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        _isPressed
                            ? theme.colorScheme.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  widget.isCompleted
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                widget.icon,
                                key: ValueKey(widget.isCompleted),
                                color:
                                    widget.isCompleted
                                        ? Colors.green
                                        : theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child:
                                widget.isLoading
                                    ? const SizedBox(
                                      key: ValueKey('loading'),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : widget.isCompleted
                                    ? const Icon(
                                      key: ValueKey('completed'),
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    )
                                    : Icon(
                                      key: ValueKey('arrow'),
                                      Icons.arrow_forward_ios,
                                      color: theme.colorScheme.outline,
                                      size: 16,
                                    ),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child:
                            hasPlayers
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          widget.playerNames
                                              .where((name) => name.isNotEmpty)
                                              .map(
                                                (name) =>
                                                    _PlayerChip(name: name),
                                              )
                                              .toList(),
                                    ),
                                  ],
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayerChip extends StatefulWidget {
  final String name;

  const _PlayerChip({required this.name});

  @override
  State<_PlayerChip> createState() => _PlayerChipState();
}

class _PlayerChipState extends State<_PlayerChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartInningButton extends StatelessWidget {
  final ShiftInningController controller;

  const _StartInningButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isReady = controller.isReadyToStart;
      final isLoading = controller.isLoading.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              (isReady && !isLoading) ? () => controller.shiftInning() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isReady
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
            foregroundColor:
                isReady
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.outline,
            elevation: isReady ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child:
              isLoading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Starting Inning...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        isReady
                            ? "Start Second Inning"
                            : "Complete Setup First",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        ),
      );
    });
  }
}
