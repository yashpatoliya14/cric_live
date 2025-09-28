import 'package:cric_live/utils/import_exports.dart';

class ShiftInningView extends StatelessWidget {
  const ShiftInningView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShiftInningController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Second Inning Setup',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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

          return _SimplifiedMainView(controller: controller);
        }),
      ),
    );
  }
}

// Simplified Main View
class _SimplifiedMainView extends StatelessWidget {
  final ShiftInningController controller;

  const _SimplifiedMainView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Overview Card - Simplified
          _SimpleMatchCard(controller: controller),
          const SizedBox(height: 24),

          // Player Selection - Simplified
          _SimplePlayerSelection(controller: controller),
          const SizedBox(height: 32),

          // Start Button - Simplified
          _SimpleStartButton(controller: controller),
        ],
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

  // Responsive helper methods
  double _getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  bool _isTablet(BuildContext context) => _getScreenWidth(context) >= 768;
  bool _isDesktop(BuildContext context) => _getScreenWidth(context) >= 1024;
  
  EdgeInsets _getAdaptivePadding(BuildContext context) {
    if (_isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    if (_isTablet(context)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    return const EdgeInsets.all(16);
  }
  
  double _getMaxContentWidth(BuildContext context) {
    if (_isDesktop(context)) return 800;
    if (_isTablet(context)) return 600;
    return double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.02),
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Enhanced Header with responsive design
          _EnhancedAppHeader(controller: controller),
          
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _getMaxContentWidth(context),
                ),
                child: SingleChildScrollView(
                  padding: _getAdaptivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Match Overview Card with enhanced design
                      _EnhancedMatchOverviewCard(controller: controller),
                      SizedBox(height: _isTablet(context) ? 32 : 24),

                      // Setup Progress with better spacing
                      _SetupProgressCard(controller: controller),
                      SizedBox(height: _isTablet(context) ? 32 : 24),

                      // Player Selection with improved layout
                      _PlayerSelectionSection(controller: controller),
                      SizedBox(height: _isTablet(context) ? 40 : 32),

                      // Action Button with better sizing
                      _StartInningButton(controller: controller),
                      SizedBox(height: _isTablet(context) ? 32 : 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced App Header Component
class _EnhancedAppHeader extends StatelessWidget {
  final ShiftInningController controller;
  
  const _EnhancedAppHeader({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 20 : 16,
          ),
          child: Row(
            children: [
              // Back Button with enhanced style
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: isTablet ? 24 : 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Header Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.swap_horiz_rounded,
                            size: isTablet ? 24 : 20,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Second Inning Setup',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 24 : 20,
                                ),
                              ),
                              Text(
                                'Configure batting order and opening bowler',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

// Enhanced Match Overview Card
class _EnhancedMatchOverviewCard extends StatelessWidget {
  final ShiftInningController controller;

  const _EnhancedMatchOverviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Card(
      elevation: isTablet ? 6 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 28 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.8),
              theme.colorScheme.primaryContainer.withOpacity(0.4),
              theme.colorScheme.surface.withOpacity(0.9),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Obx(
          () => Column(
            children: [
              // Inning indicator with enhanced design
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sports_cricket,
                      size: isTablet ? 20 : 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      "Second Inning",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              
              // Teams layout with enhanced spacing
              isDesktop ? 
                Row(
                  children: [
                    Expanded(
                      child: _EnhancedTeamCard(
                        teamName: controller.team1.value,
                        isBatting: controller.battingTeamId == controller.team1Id,
                        label: controller.battingTeamId == controller.team1Id ? "Batting" : "Bowling",
                        isTablet: isTablet,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: _VSIndicator(theme: theme, isTablet: isTablet),
                    ),
                    Expanded(
                      child: _EnhancedTeamCard(
                        teamName: controller.team2.value,
                        isBatting: controller.battingTeamId == controller.team2Id,
                        label: controller.battingTeamId == controller.team2Id ? "Batting" : "Bowling",
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ) :
                Column(
                  children: [
                    _EnhancedTeamCard(
                      teamName: controller.team1.value,
                      isBatting: controller.battingTeamId == controller.team1Id,
                      label: controller.battingTeamId == controller.team1Id ? "Batting" : "Bowling",
                      isTablet: isTablet,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                      child: _VSIndicator(theme: theme, isTablet: isTablet),
                    ),
                    _EnhancedTeamCard(
                      teamName: controller.team2.value,
                      isBatting: controller.battingTeamId == controller.team2Id,
                      label: controller.battingTeamId == controller.team2Id ? "Batting" : "Bowling",
                      isTablet: isTablet,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced VS Indicator
class _VSIndicator extends StatelessWidget {
  final ThemeData theme;
  final bool isTablet;
  
  const _VSIndicator({required this.theme, required this.isTablet});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        "VS",
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontSize: isTablet ? 18 : 14,
          letterSpacing: 1,
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

// Enhanced Team Card
class _EnhancedTeamCard extends StatelessWidget {
  final String teamName;
  final bool isBatting;
  final String label;
  final bool isTablet;

  const _EnhancedTeamCard({
    required this.teamName,
    required this.isBatting,
    required this.label,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: isBatting
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              )
            : LinearGradient(
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: isBatting
              ? theme.colorScheme.primary.withOpacity(0.6)
              : theme.colorScheme.outline.withOpacity(0.3),
          width: isBatting ? 2 : 1,
        ),
        boxShadow: isBatting
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Team Avatar with enhanced design
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              gradient: isBatting
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        theme.colorScheme.outline.withOpacity(0.7),
                        theme.colorScheme.outline.withOpacity(0.5),
                      ],
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isBatting ? theme.colorScheme.primary : theme.colorScheme.outline)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                teamName.isNotEmpty ? teamName.substring(0, 1).toUpperCase() : 'T',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          
          // Team Name
          Text(
            teamName.isNotEmpty ? teamName : "Loading...",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isBatting ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontSize: isTablet ? 18 : 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          
          // Role Badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              gradient: isBatting
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        theme.colorScheme.outline,
                        theme.colorScheme.outline.withOpacity(0.8),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isBatting ? theme.colorScheme.primary : theme.colorScheme.outline)
                      .withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isBatting ? Icons.sports_cricket : Icons.sports_baseball,
                  size: isTablet ? 16 : 14,
                  color: Colors.white,
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
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
            isTablet: MediaQuery.of(context).size.width >= 768,
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
            isTablet: MediaQuery.of(context).size.width >= 768,
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
  final bool isTablet;

  const _EnhancedPlayerSelectorTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.playerNames,
    required this.isLoading,
    required this.onTap,
    required this.isCompleted,
    required this.isTablet,
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
            elevation: widget.isCompleted ? (widget.isTablet ? 4 : 3) : (widget.isTablet ? 2 : 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 12),
              side: BorderSide(
                color:
                    widget.isCompleted
                        ? Colors.green.withOpacity(0.5)
                        : theme.colorScheme.outline.withOpacity(0.2),
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
                borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
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
                            padding: EdgeInsets.all(widget.isTablet ? 12 : 8),
                            decoration: BoxDecoration(
                              color:
                                  widget.isCompleted
                                      ? Colors.green.withOpacity(0.1)
                                      : theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(widget.isTablet ? 12 : 8),
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
                                size: widget.isTablet ? 24 : 20,
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
                                    fontSize: widget.isTablet ? 18 : 16,
                                  ),
                                ),
                                SizedBox(height: widget.isTablet ? 6 : 4),
                                Text(
                                  widget.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: widget.isTablet ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child:
                                widget.isLoading
                                    ? SizedBox(
                                      key: const ValueKey('loading'),
                                      width: widget.isTablet ? 24 : 20,
                                      height: widget.isTablet ? 24 : 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : widget.isCompleted
                                    ? Icon(
                                      key: const ValueKey('completed'),
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: widget.isTablet ? 28 : 24,
                                    )
                                    : Icon(
                                      key: const ValueKey('arrow'),
                                      Icons.arrow_forward_ios,
                                      color: theme.colorScheme.outline,
                                      size: widget.isTablet ? 18 : 16,
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
                                    SizedBox(height: widget.isTablet ? 16 : 12),
                                    Wrap(
                                      spacing: widget.isTablet ? 12 : 8,
                                      runSpacing: widget.isTablet ? 12 : 8,
                                      children:
                                          widget.playerNames
                                              .where((name) => name.isNotEmpty)
                                              .map(
                                                (name) =>
                                                    _PlayerChip(name: name, isTablet: widget.isTablet),
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
  final bool isTablet;

  const _PlayerChip({required this.name, required this.isTablet});

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
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 16 : 12,
              vertical: widget.isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(widget.isTablet ? 20 : 16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: widget.isTablet ? 6 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: widget.isTablet ? 16 : 14,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                SizedBox(width: widget.isTablet ? 8 : 6),
                Text(
                  widget.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: widget.isTablet ? 14 : 12,
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

// Enhanced Setup Progress Card
class _EnhancedSetupProgressCard extends StatelessWidget {
  final ShiftInningController controller;

  const _EnhancedSetupProgressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Obx(() {
      final hasBatsmen = controller.strikerBatsman.value.isNotEmpty &&
          controller.nonStrikerBatsman.value.isNotEmpty;
      final hasBowler = controller.bowler.value.isNotEmpty;
      final completedSteps = (hasBatsmen ? 1 : 0) + (hasBowler ? 1 : 0);
      final progress = completedSteps / 2;

      return Card(
        elevation: isTablet ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            gradient: progress == 1.0
                ? LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      color: progress == 1.0
                          ? Colors.green.withOpacity(0.2)
                          : theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      progress == 1.0 ? Icons.check_circle : Icons.checklist_rtl,
                      color: progress == 1.0 ? Colors.green : theme.colorScheme.primary,
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Setup Progress",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          progress == 1.0
                              ? "All players selected! Ready to start."
                              : "Select players to continue",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 10,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: progress == 1.0
                          ? Colors.green
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "$completedSteps/2",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20 : 16),
              
              // Enhanced Progress Bar
              Container(
                height: isTablet ? 8 : 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: progress == 1.0
                            ? [Colors.green, Colors.green.shade600]
                            : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              
              // Progress Steps
              Row(
                children: [
                  Expanded(
                    child: _EnhancedProgressStep(
                      icon: Icons.sports_cricket,
                      label: "Opening Batsmen",
                      subtitle: "${controller.strikerBatsman.value.isNotEmpty && controller.nonStrikerBatsman.value.isNotEmpty ? 2 : controller.strikerBatsman.value.isNotEmpty || controller.nonStrikerBatsman.value.isNotEmpty ? 1 : 0}/2 selected",
                      isCompleted: hasBatsmen,
                      isTablet: isTablet,
                    ),
                  ),
                  SizedBox(width: isTablet ? 24 : 16),
                  Expanded(
                    child: _EnhancedProgressStep(
                      icon: Icons.sports_baseball,
                      label: "Opening Bowler",
                      subtitle: controller.bowler.value.isNotEmpty ? "Selected" : "Not selected",
                      isCompleted: hasBowler,
                      isTablet: isTablet,
                    ),
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

// Enhanced Progress Step
class _EnhancedProgressStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isCompleted;
  final bool isTablet;

  const _EnhancedProgressStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isCompleted,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : theme.colorScheme.outline.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isTablet ? 12 : 8),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : theme.colorScheme.outline.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              size: isTablet ? 24 : 20,
              color: isCompleted ? Colors.white : theme.colorScheme.outline,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isCompleted ? Colors.green : theme.colorScheme.onSurface,
              fontSize: isTablet ? 14 : 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: isTablet ? 12 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Enhanced Player Selection Section
class _EnhancedPlayerSelectionSection extends StatelessWidget {
  final ShiftInningController controller;

  const _EnhancedPlayerSelectionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group_add,
                  color: theme.colorScheme.primary,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Players",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 22 : 18,
                      ),
                    ),
                    Text(
                      "Choose opening batsmen and bowler for the second inning",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Player selection tiles
        Obx(() => Column(
          children: [
            _EnhancedPlayerSelectorTile(
              title: "Opening Batsmen",
              subtitle: "Select 2 opening batsmen for ${controller.battingTeamName}",
              icon: Icons.sports_cricket,
              playerNames: [
                controller.strikerBatsman.value,
                controller.nonStrikerBatsman.value,
              ],
              isLoading: controller.isSelectingBatsmen.value,
              onTap: () => controller.selectBatsman(),
              isCompleted: controller.strikerBatsman.value.isNotEmpty &&
                  controller.nonStrikerBatsman.value.isNotEmpty,
              isTablet: isTablet,
            ),
            SizedBox(height: isTablet ? 20 : 16),
            _EnhancedPlayerSelectorTile(
              title: "Opening Bowler",
              subtitle: "Select 1 opening bowler for ${controller.bowlingTeamName}",
              icon: Icons.sports_baseball,
              playerNames: [controller.bowler.value],
              isLoading: controller.isSelectingBowler.value,
              onTap: () => controller.selectBowler(),
              isCompleted: controller.bowler.value.isNotEmpty,
              isTablet: isTablet,
            ),
          ],
        )),
      ],
    );
  }
}

// Enhanced Start Inning Button
class _EnhancedStartInningButton extends StatelessWidget {
  final ShiftInningController controller;

  const _EnhancedStartInningButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Obx(() {
      final isReady = controller.isReadyToStart;
      final isLoading = controller.isLoading.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: isTablet ? 64 : 56,
        child: ElevatedButton(
          onPressed: !isLoading ? () => controller.shiftInning() : null, // Force start enabled
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary, // Always enabled for force start
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: isTablet ? 6 : 4, // Always elevated
            shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? Row(
                    key: const ValueKey('loading'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isTablet ? 24 : 20,
                        height: isTablet ? 24 : 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 12),
                      Text(
                        "Starting Second Inning...",
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: ValueKey('button-$isReady'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          key: ValueKey(isReady),
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        "Start Second Inning",
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

// Simplified Match Card
class _SimpleMatchCard extends StatelessWidget {
  final ShiftInningController controller;

  const _SimpleMatchCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Second Inning',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Teams
          Text(
            '${controller.team1.value} vs ${controller.team2.value}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          Text(
            '${controller.battingTeamName} to bat',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ));
  }
}

// Simplified Player Selection
class _SimplePlayerSelection extends StatelessWidget {
  final ShiftInningController controller;

  const _SimplePlayerSelection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Players',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        // Opening Batsmen Card
        Obx(() => _PlayerCard(
          title: 'Opening Batsmen',
          subtitle: '${controller.battingTeamName}',
          icon: Icons.sports_cricket,
          players: [
            controller.strikerBatsman.value,
            controller.nonStrikerBatsman.value,
          ],
          isLoading: controller.isSelectingBatsmen.value,
          onTap: () => controller.selectBatsman(),
          isCompleted: controller.strikerBatsman.value.isNotEmpty && 
                      controller.nonStrikerBatsman.value.isNotEmpty,
        )),
        
        const SizedBox(height: 16),
        
        // Opening Bowler Card
        Obx(() => _PlayerCard(
          title: 'Opening Bowler',
          subtitle: '${controller.bowlingTeamName}',
          icon: Icons.sports_baseball,
          players: [controller.bowler.value],
          isLoading: controller.isSelectingBowler.value,
          onTap: () => controller.selectBowler(),
          isCompleted: controller.bowler.value.isNotEmpty,
        )),
      ],
    );
  }
}

// Simple Player Card
class _PlayerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> players;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isCompleted;

  const _PlayerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.players,
    required this.isLoading,
    required this.onTap,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPlayers = players.any((p) => p.isNotEmpty);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.withValues(alpha: 0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCompleted 
                        ? Colors.green.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : icon,
                      color: isCompleted ? Colors.green : theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                ],
              ),
              
              if (hasPlayers) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: players
                      .where((p) => p.isNotEmpty)
                      .map((player) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              player,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Start Button
class _SimpleStartButton extends StatelessWidget {
  final ShiftInningController controller;

  const _SimpleStartButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isLoading = controller.isLoading.value;

      return Container(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => controller.shiftInning(),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Starting...',
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
                    Icon(
                      Icons.play_arrow,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Second Inning',
                      style: TextStyle(
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
              !isLoading ? () => controller.shiftInning() : null, // Force start enabled
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary, // Always enabled for force start
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 4, // Always elevated
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
                      "Start Second Inning",
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
