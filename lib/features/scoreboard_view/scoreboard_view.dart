import 'package:cric_live/utils/import_exports.dart';

/// Enhanced Scoreboard View with fixed layout issues and improved UI
class ScoreboardView extends StatelessWidget {
  const ScoreboardView({super.key});

  /// Enhanced color scheme for different ball types
  Color _getBallColor(BuildContext context, String ball) {
    final theme = Theme.of(context);

    if (ball.contains('W')) {
      return Colors.red.shade600; // Wicket
    } else if (ball.contains('WD') || ball.contains('NB')) {
      return Colors.orange.shade600; // Wide or No Ball
    } else if (ball == '4') {
      return Colors.green.shade600; // Boundary
    } else if (ball == '6') {
      return Colors.purple.shade600; // Six
    } else if (ball == '•') {
      return Colors.grey.shade500; // Dot ball
    } else {
      return theme.colorScheme.primary; // Regular runs
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScoreboardController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final dialogResult = await _showBackButtonDialog(context, controller);
        if (dialogResult == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: const CommonAppHeader(
          title: 'Scoreboard',
          subtitle: 'Live match scoring',
          leadingIcon: Icons.sports_cricket,
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final padding = screenWidth < 360 ? 8.0 : screenWidth < 480 ? 12.0 : 16.0;
              
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (padding * 2),
                  ),
                  child:
                      isLandscape
                          ? _buildLandscapeLayout(context, controller)
                          : _buildPortraitLayout(context, controller),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Score Section
        _buildMainScoreSection(context, controller),

        const SizedBox(height: 8),

        // Stats Section
        _buildStatsSection(context, controller),

        const SizedBox(height: 8),

        // Action Buttons
        _buildActionSection(context, controller),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Score and Stats
        Expanded(
          flex: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMainScoreSection(context, controller),
              const SizedBox(height: 8),
              _buildStatsSection(context, controller),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right side - Action Buttons
        Expanded(flex: 6, child: _buildActionSection(context, controller)),
      ],
    );
  }

  Widget _buildMainScoreSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 360 ? 8.0 : screenWidth < 480 ? 12.0 : 16.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Teams Header
          Obx(
            () => Text(
              "${controller.team1.value} vs ${controller.team2.value}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          const SizedBox(height: 12),

          // Main Score
          Obx(
            () => FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${controller.totalRuns.value}/${controller.wickets.value}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Match Info Row
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  context,
                  "Overs",
                  "${controller.currentOvers.value}/${controller.totalOvers.value}",
                ),
                _buildInfoItem(
                  context,
                  "Inning",
                  "${controller.inningNo.value}${controller.inningNo.value == 1 ? 'st' : 'nd'}",
                ),
                _buildInfoItem(
                  context,
                  "CRR",
                  controller.crr.value.isFinite && !controller.crr.value.isNaN
                      ? controller.crr.value.toStringAsFixed(2)
                      : "-",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current Over
        _buildCurrentOverSection(context, controller),

        const SizedBox(height: 8),

        // Player Stats
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBattingSection(context, controller)),
            const SizedBox(width: 8),
            Expanded(child: _buildBowlingSection(context, controller)),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentOverSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_cricket,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Current Over",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              List<String> ballSequence =
                  (controller.oversState['ballSequence'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              bool isOverComplete = controller.oversState['isOverComplete'] == true;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ball sequence with improved layout
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Display actual ball sequence
                          for (int i = 0; i < ballSequence.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildBallIndicatorLarge(
                                    context,
                                    ballSequence[i],
                                    _getBallColor(context, ballSequence[i]),
                                    true,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${i + 1}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Fill remaining slots with empty circles
                          for (int i = ballSequence.length; i < 6; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildBallIndicatorLarge(
                                    context,
                                    "-",
                                    Colors.grey.shade300,
                                    false,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${i + 1}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Show new bowler selection button when over is completed
                  Obx(() {
                    if (controller.isOverCompleted || isOverComplete) {
                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.onTapSelectNewBowler(),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.orange.shade500,
                                    Colors.orange.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade300,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sports_cricket,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Over Completed!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Tap to select new bowler",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBallIndicatorLarge(
    BuildContext context,
    String text,
    Color color,
    bool isFilled,
  ) {
    // Determine size based on text length
    final isLongText = text.length > 2;
    final indicatorWidth = isLongText ? 42.0 : 32.0;
    final indicatorHeight = isLongText ? 32.0 : 32.0;
    final baseFontSize = isLongText ? 9.0 : 12.0;
    
    return Container(
      width: indicatorWidth,
      height: indicatorHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: isLongText 
            ? BorderRadius.circular(16) 
            : null,
        shape: isLongText ? BoxShape.rectangle : BoxShape.circle,
        border:
            !isFilled
                ? Border.all(color: Colors.grey.shade400, width: 2)
                : null,
        boxShadow:
            isFilled
                ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
                : null,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(isLongText ? 2.0 : 1.0),
            child: Text(
              text,
              style: TextStyle(
                color: isFilled ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: baseFontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBattingSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_cricket,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "Batting",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => _buildPlayerStatsCompact(
                    context,
                    controller.strikerBatsman.value,
                    controller.strikerBatsmanState,
                    true,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => _buildPlayerStatsCompact(
                    context,
                    controller.nonStrikerBatsman.value,
                    controller.nonStrikerBatsmanState,
                    false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowlingSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_baseball,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "Bowling",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Obx(() => _buildBowlerStatsCompact(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatsCompact(
    BuildContext context,
    String playerName,
    RxMap<String, double> stats,
    bool isStriker,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isStriker ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border:
            isStriker
                ? Border.all(color: Colors.green.shade300, width: 1)
                : Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isStriker)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              if (isStriker) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  playerName.isEmpty ? "Select Player" : playerName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isStriker
                            ? Colors.green.shade800
                            : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStatItem(
                context,
                "R",
                "${stats['runs']?.toInt() ?? 0}",
              ),
              _buildSmallStatItem(
                context,
                "B",
                "${stats['balls']?.toInt() ?? 0}",
              ),
              _buildSmallStatItem(
                context,
                "4s",
                "${stats['fours']?.toInt() ?? 0}",
              ),
              _buildSmallStatItem(
                context,
                "6s",
                "${stats['sixes']?.toInt() ?? 0}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBowlerStatsCompact(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade300, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.bowler.value.isEmpty
                ? "Select Bowler"
                : controller.bowler.value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade800,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStatItem(
                context,
                "O",
                controller.bowlerState['overs']?.toStringAsFixed(1) ?? '0.0',
              ),
              _buildSmallStatItem(
                context,
                "R",
                "${controller.bowlerState['runs']?.toInt() ?? 0}",
              ),
              _buildSmallStatItem(
                context,
                "W",
                "${controller.bowlerState['wickets']?.toInt() ?? 0}",
              ),
              _buildSmallStatItem(
                context,
                "ER",
                controller.bowlerState['ER']?.toStringAsFixed(1) ?? '0.0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Match Completed - Show message if user chose to stay
            Obx(() {
              if (controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Match Completed!",
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "All actions are disabled except undo.",
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            
            // Run Buttons - Main Priority (disabled when over completed or match completed with stay choice)
            Obx(() => Opacity(
              opacity: (controller.isOverCompleted || (controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd)) ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: controller.isOverCompleted || (controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd),
                child: _buildMainRunButtons(context, controller),
              ),
            )),

            const SizedBox(height: 10),

            // Extras Row (with selective disabling - undo always enabled)
            Obx(() => _buildExtrasSection(context, controller)),

            const SizedBox(height: 8),

            // Special Actions Row (disabled when over completed or match completed with stay choice, but allow undo)
            Obx(() => _buildSpecialActionsSection(context, controller)),
            
            // Show disabled message when over is completed or match is completed
            Obx(() {
              if (controller.isOverCompleted) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "Scoring disabled - Select new bowler to continue",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.undo,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "Match completed - Only undo is available to continue scoring",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
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
    );
  }

  Widget _buildMainRunButtons(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal spacing and button size
        const int buttonCount = 7;
        const int spacingCount = 6; // 6 spaces between 7 buttons
        const double minButtonSize = 30.0;
        const double maxButtonSize = 50.0;
        
        // Calculate spacing that fits available width
        double spacing = 3.0;
        double totalSpacing = spacing * spacingCount;
        double availableForButtons = constraints.maxWidth - totalSpacing;
        double buttonSize = (availableForButtons / buttonCount).clamp(minButtonSize, maxButtonSize);
        
        // Recalculate with actual button size to ensure we don't overflow
        double totalButtonWidth = buttonSize * buttonCount;
        double remainingWidth = constraints.maxWidth - totalButtonWidth - 4; // Safety margin
        spacing = (remainingWidth / spacingCount).clamp(2.0, 6.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRunButton(context, "0", 0, controller, buttonSize),
              SizedBox(width: spacing),
              _buildRunButton(context, "1", 1, controller, buttonSize),
              SizedBox(width: spacing),
              _buildRunButton(context, "2", 2, controller, buttonSize),
              SizedBox(width: spacing),
              _buildRunButton(context, "3", 3, controller, buttonSize),
              SizedBox(width: spacing),
              _buildRunButton(
                context,
                "4",
                4,
                controller,
                buttonSize,
                isSpecial: true,
              ),
              SizedBox(width: spacing),
              _buildRunButton(context, "5", 5, controller, buttonSize),
              SizedBox(width: spacing),
              _buildRunButton(
                context,
                "6",
                6,
                controller,
                buttonSize,
                isSpecial: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRunButton(
    BuildContext context,
    String text,
    int runs,
    ScoreboardController controller,
    double size, {
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: () => DebouncingUtil.debounceTap(
        'run_button_$runs',
        () => controller.onTapRun(runs: runs),
        delay: const Duration(milliseconds: 150),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSpecial ? Theme.of(context).primaryColor : Colors.white,
          border: Border.all(
            color:
                isSpecial
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: (isSpecial ? Theme.of(context).primaryColor : Colors.grey)
                  .withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSpecial ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtrasSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    final isDisabled = controller.isOverCompleted || (controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd);
    final isMatchCompletedAndStaying = controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Wide button - can be disabled
          Obx(
            () => Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: isDisabled,
                child: _buildToggleButton(
                  context,
                  "Wide",
                  controller.isWideSelected.value,
                  () {
                    controller.isWideSelected.value =
                        !controller.isWideSelected.value;
                    controller.isNoBallSelected.value = false;
                    controller.isByeSelected.value = false;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // No Ball button - can be disabled
          Obx(
            () => Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: isDisabled,
                child: _buildToggleButton(
                  context,
                  "No Ball",
                  controller.isNoBallSelected.value,
                  () {
                    controller.isNoBallSelected.value =
                        !controller.isNoBallSelected.value;
                    controller.isWideSelected.value = false;
                    controller.isByeSelected.value = false;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Bye button - can be disabled
          Obx(
            () => Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: isDisabled,
                child: _buildToggleButton(
                  context,
                  "Bye",
                  controller.isByeSelected.value,
                  () {
                    controller.isByeSelected.value =
                        !controller.isByeSelected.value;
                    controller.isWideSelected.value = false;
                    controller.isNoBallSelected.value = false;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Undo button - ALWAYS ENABLED (even when match is completed and user chose to stay)
          _buildActionButton(
            context,
            "Undo",
            Icons.undo,
            () => controller.undoBall(),
            isMatchCompletedAndStaying ? Colors.green.shade700 : Colors.grey.shade700, // Highlight undo when it's the only option
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialActionsSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    final isDisabled = controller.isOverCompleted || (controller.isMatchCompleted && controller.userChoseStayAfterMatchEnd);
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Opacity(
                  opacity: isDisabled ? 0.5 : 1.0,
                  child: IgnorePointer(
                    ignoring: isDisabled,
                    child: Obx(() => _buildActionButtonWithLoader(
                      context,
                      "Wicket",
                      Icons.close,
                      () => controller.onTapWicket(wicketType: "random"),
                      Colors.red,
                      controller.isWicketLoading.value,
                    )),
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: isDisabled ? 0.5 : 1.0,
                  child: IgnorePointer(
                    ignoring: isDisabled,
                    child: _buildActionButton(
                      context,
                      "Swap",
                      Icons.swap_horiz,
                      () => controller.onTapSwap(),
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1, 
          child: _buildMainActionButton(context, controller) // Main button always enabled
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () => DebouncingUtil.debounceTap(
        'toggle_button_${text.toLowerCase().replaceAll(' ', '_')}',
        onTap,
        delay: const Duration(milliseconds: 100),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => DebouncingUtil.debounceTap(
        'action_button_${text.toLowerCase().replaceAll(' ', '_')}',
        onTap,
        delay: const Duration(milliseconds: 500),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonWithLoader(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
    Color color,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading ? null : () => DebouncingUtil.debounceTap(
        'action_button_${text.toLowerCase().replaceAll(' ', '_')}',
        onTap,
        delay: const Duration(milliseconds: 500),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isLoading 
              ? color.withValues(alpha: 0.2) 
              : color.withValues(alpha: 0.1),
          border: Border.all(
            color: isLoading ? color.withValues(alpha: 0.5) : color, 
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              isLoading ? "Processing..." : text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLoading ? color.withValues(alpha: 0.7) : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Obx(
      () {
        final isSecondInning = controller.inningNo.value == 2;
        final buttonText = isSecondInning ? "End Match" : "Next Inning";
        final buttonIcon = isSecondInning ? Icons.stop_circle : Icons.arrow_forward;
        
        return Container(
          height: 44, // Fixed compact height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isSecondInning ? Colors.red.shade600 : Theme.of(context).primaryColor,
                isSecondInning ? Colors.red.shade700 : Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(22), // More rounded for modern look
            boxShadow: [
              BoxShadow(
                color: (isSecondInning ? Colors.red.shade300 : Theme.of(context).primaryColor.withValues(alpha: 0.4)),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.isMainButtonLoading.value ? null : () => DebouncingUtil.debounceTap(
                'main_action_button',
                () => controller.onTapMainButton(),
                delay: const Duration(milliseconds: 1000),
              ),
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Network icon for 2nd inning
                    if (isSecondInning) ...[
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    
                    // Main button icon or loader
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: controller.isMainButtonLoading.value
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              buttonIcon,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Button text
                    Flexible(
                      child: Text(
                        controller.isMainButtonLoading.value ? "Processing..." : buttonText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: controller.isMainButtonLoading.value 
                              ? Colors.white.withValues(alpha: 0.8) 
                              : Colors.white,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  /// Shows dialog when user presses back button during scoring
  Future<bool?> _showBackButtonDialog(BuildContext context, ScoreboardController controller) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_outlined,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Match in Progress",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "The match is currently being scored. What would you like to do?",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Choose one of the following options:",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "• Resume: Continue scoring and save progress",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "• End Match: Finish and save the match",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "• Cancel: Go back to scoring",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                await controller.resumeMatch();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.green.shade300),
                ),
              ),
              child: Text(
                "Resume",
                style: GoogleFonts.poppins(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                await controller.endMatchFromDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "End Match",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }
}
