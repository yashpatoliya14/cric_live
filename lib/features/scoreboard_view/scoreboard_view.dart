import 'package:cric_live/utils/import_exports.dart';
import 'package:cric_live/utils/responsive_utils.dart';

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
      onPopInvoked: (didPop) async {
        final result = await controller.onWillPopScope();

        Get.back();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            APPBAR_SCOREBOARD,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.rFont(20),
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: context.adaptivePadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                        context.adaptivePadding.vertical,
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

        SizedBox(height: context.rSpacing(8)),

        // Stats Section
        _buildStatsSection(context, controller),

        SizedBox(height: context.rSpacing(8)),

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
              SizedBox(height: context.rSpacing(8)),
              _buildStatsSection(context, controller),
            ],
          ),
        ),

        SizedBox(width: context.rSpacing(8)),

        // Right side - Action Buttons
        Expanded(flex: 6, child: _buildActionSection(context, controller)),
      ],
    );
  }

  Widget _buildMainScoreSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: context.adaptivePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(context.rRadius(16)),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(16),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          SizedBox(height: context.rSpacing(12)),

          // Main Score
          Obx(
            () => FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${controller.totalRuns.value}/${controller.wickets.value}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(48),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: context.rSpacing(12)),

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
                  controller.CRR.value.isFinite && !controller.CRR.value.isNaN
                      ? controller.CRR.value.toStringAsFixed(2)
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
              fontSize: context.rFont(12),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.rSpacing(2)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14),
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

        SizedBox(height: context.rSpacing(8)),

        // Player Stats
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBattingSection(context, controller)),
            SizedBox(width: context.rSpacing(8)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.rRadius(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: context.adaptivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Current Over",
              style: TextStyle(
                fontSize: context.rFont(16),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: context.rSpacing(8)),
            Obx(() {
              List<String> ballSequence =
                  (controller.oversState['ballSequence'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display actual ball sequence
                    for (int i = 0; i < ballSequence.length; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(3),
                        ),
                        child: _buildBallIndicatorLarge(
                          context,
                          ballSequence[i],
                          _getBallColor(context, ballSequence[i]),
                          true,
                        ),
                      ),
                    // Fill remaining slots with empty circles
                    for (int i = ballSequence.length; i < 6; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(3),
                        ),
                        child: _buildBallIndicatorLarge(
                          context,
                          "-",
                          Colors.grey.shade300,
                          false,
                        ),
                      ),
                  ],
                ),
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
    return Container(
      width: context.rWidth(32),
      height: context.rWidth(32),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
        child: Text(
          text,
          style: TextStyle(
            color: isFilled ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: context.rFont(12),
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
        borderRadius: BorderRadius.circular(context.rRadius(12)),
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
        padding: context.adaptivePadding / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_cricket,
                  color: Colors.green,
                  size: context.rWidth(16),
                ),
                SizedBox(width: context.rSpacing(4)),
                Flexible(
                  child: Text(
                    "Batting",
                    style: TextStyle(
                      fontSize: context.rFont(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rSpacing(6)),
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
                SizedBox(height: context.rSpacing(4)),
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
        borderRadius: BorderRadius.circular(context.rRadius(12)),
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
        padding: context.adaptivePadding / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_baseball,
                  color: Colors.red,
                  size: context.rWidth(16),
                ),
                SizedBox(width: context.rSpacing(4)),
                Flexible(
                  child: Text(
                    "Bowling",
                    style: TextStyle(
                      fontSize: context.rFont(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rSpacing(6)),
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
      padding: EdgeInsets.all(context.rSpacing(6)),
      decoration: BoxDecoration(
        color: isStriker ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.rRadius(6)),
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
              if (isStriker) SizedBox(width: context.rSpacing(4)),
              Expanded(
                child: Text(
                  playerName.isEmpty ? "Select Player" : playerName,
                  style: TextStyle(
                    fontSize: context.rFont(12),
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
          SizedBox(height: context.rSpacing(4)),
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
      padding: EdgeInsets.all(context.rSpacing(6)),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(context.rRadius(6)),
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
              fontSize: context.rFont(12),
              fontWeight: FontWeight.w600,
              color: Colors.red.shade800,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: context.rSpacing(4)),
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
            fontSize: context.rFont(10),
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: context.rFont(11),
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
        borderRadius: BorderRadius.circular(context.rRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: context.adaptivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Run Buttons - Main Priority
            _buildMainRunButtons(context, controller),

            SizedBox(height: context.rSpacing(10)),

            // Extras Row
            _buildExtrasSection(context, controller),

            SizedBox(height: context.rSpacing(8)),

            // Special Actions Row
            _buildSpecialActionsSection(context, controller),
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
        // Calculate button size based on available space
        final availableWidth = constraints.maxWidth - (context.rSpacing(4) * 6);
        final buttonSize = (availableWidth / 7).clamp(32.0, 56.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRunButton(context, "0", 0, controller, buttonSize),
              SizedBox(width: context.rSpacing(4)),
              _buildRunButton(context, "1", 1, controller, buttonSize),
              SizedBox(width: context.rSpacing(4)),
              _buildRunButton(context, "2", 2, controller, buttonSize),
              SizedBox(width: context.rSpacing(4)),
              _buildRunButton(context, "3", 3, controller, buttonSize),
              SizedBox(width: context.rSpacing(4)),
              _buildRunButton(
                context,
                "4",
                4,
                controller,
                buttonSize,
                isSpecial: true,
              ),
              SizedBox(width: context.rSpacing(4)),
              _buildRunButton(context, "5", 5, controller, buttonSize),
              SizedBox(width: context.rSpacing(4)),
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
      onTap: () => controller.onTapRun(runs: runs),
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
                fontSize: context.rFont(20),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(
            () => _buildToggleButton(
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
          SizedBox(width: context.rSpacing(8)),
          Obx(
            () => _buildToggleButton(
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
          SizedBox(width: context.rSpacing(8)),
          Obx(
            () => _buildToggleButton(
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
          SizedBox(width: context.rSpacing(8)),
          _buildActionButton(
            context,
            "Undo",
            Icons.undo,
            () => controller.undoBall(),
            Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialActionsSection(
    BuildContext context,
    ScoreboardController controller,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionButton(
                  context,
                  "Wicket",
                  Icons.close,
                  () => controller.onTapWicket(wicketType: "random"),
                  Colors.red,
                ),
                SizedBox(width: context.rSpacing(8)),
                _buildActionButton(
                  context,
                  "Swap",
                  Icons.swap_horiz,
                  () => controller.onTapSwap(),
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.rSpacing(12)),
        Expanded(flex: 1, child: _buildMainActionButton(context, controller)),
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
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rSpacing(12),
          vertical: context.rSpacing(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(context.rRadius(20)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: context.rFont(12),
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
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rSpacing(12),
          vertical: context.rSpacing(8),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(context.rRadius(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: context.rWidth(16)),
            SizedBox(width: context.rSpacing(4)),
            Text(
              text,
              style: TextStyle(
                fontSize: context.rFont(12),
                fontWeight: FontWeight.w600,
                color: color,
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
      () => ElevatedButton(
        onPressed: () => controller.onTapMainButton(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: context.rSpacing(12),
            horizontal: context.rSpacing(8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.rRadius(12)),
          ),
          elevation: 4,
        ),
        child: FittedBox(
          child: Text(
            controller.inningNo.value == 1 ? "Next\nInning" : "End\nMatch",
            style: TextStyle(
              fontSize: context.rFont(14),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
