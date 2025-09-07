import 'package:cric_live/utils/import_exports.dart';

class TeamCard extends StatefulWidget {
  final TeamSelectionModel team;
  final VoidCallback? onTap;
  final VoidCallback? onViewPlayers;
  final bool showStats;
  final bool showActions;
  final bool isSelected;
  final EdgeInsets? margin;
  final double? elevation;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.onViewPlayers,
    this.showStats = true,
    this.showActions = true,
    this.isSelected = false,
    this.margin,
    this.elevation,
  });

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _shineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shineAnimation;

  // bool _isHovered = false; // Removed unused field
  // bool _isPressed = false; // Removed unused field

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shineAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TeamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
        _shineController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _shineController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  TeamSelectionModel get team => widget.team;
  bool get isSelected => widget.isSelected;
  bool get showStats => widget.showStats;
  bool get showActions => widget.showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        margin:
            widget.margin ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Logo and Title
                Row(
                  children: [
                    _buildSimpleTeamLogo(theme),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSimpleTeamName(theme),
                          if (team.tournamentName != null) ...[
                            const SizedBox(height: 4),
                            _buildSimpleTournamentInfo(theme),
                          ],
                        ],
                      ),
                    ),
                    _buildSimpleSelectionIndicator(colorScheme),
                  ],
                ),

                if (team.teamDescription != null) ...[
                  const SizedBox(height: 12),
                  _buildSimpleDescription(theme),
                ],

                if (team.captain != null || team.coach != null) ...[
                  const SizedBox(height: 12),
                  _buildSimpleTeamInfo(theme),
                ],

                if (showStats && team.totalMatches != null) ...[
                  const SizedBox(height: 12),
                  _buildSimpleStats(theme),
                ],

                if (showActions) ...[
                  const SizedBox(height: 16),
                  _buildSimpleActionButtons(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTeamLogo(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getTeamColor(theme.colorScheme).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTeamColor(theme.colorScheme).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          team.teamName.isNotEmpty
              ? team.teamName.substring(0, 1).toUpperCase()
              : 'T',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getTeamColor(theme.colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTeamName(ThemeData theme) {
    return Text(
      team.displayName,
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.0,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSimpleTournamentInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        team.tournamentName!,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildSimpleSelectionIndicator(ColorScheme colorScheme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
      ),
      child:
          isSelected
              ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
              : null,
    );
  }

  Widget _buildSimpleDescription(ThemeData theme) {
    return Text(
      team.teamDescription!,
      style: GoogleFonts.nunito(
        fontSize: 14,
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSimpleTeamInfo(ThemeData theme) {
    return Row(
      children: [
        if (team.captain != null) ...[
          Icon(Icons.stars, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            team.captain!,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
        if (team.captain != null && team.coach != null) ...[
          const SizedBox(width: 8),
          Container(width: 1, height: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
        ],
        if (team.coach != null) ...[
          Icon(Icons.person, size: 16, color: theme.colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            team.coach!,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSimpleStats(ThemeData theme) {
    return Row(
      children: [
        _buildSimpleStatItem(
          theme,
          'Matches',
          '${team.totalMatches}',
          theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        _buildSimpleStatItem(
          theme,
          'Win Rate',
          team.formattedWinPercentage,
          Colors.amber,
        ),
        const SizedBox(width: 16),
        _buildSimpleStatItem(
          theme,
          'Players',
          '${team.totalPlayers ?? 0}',
          theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildSimpleStatItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check, size: 20),
            label: Text(
              'Select Team',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (widget.onViewPlayers != null) ...[
          const SizedBox(width: 12),
          IconButton(
            onPressed: widget.onViewPlayers,
            icon: Icon(Icons.visibility, color: theme.colorScheme.primary),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'View Players',
          ),
        ],
      ],
    );
  }

  Color _getTeamColor(ColorScheme colorScheme) {
    if (team.teamColor != null) {
      try {
        return Color(int.parse(team.teamColor!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Fallback to primary color if parsing fails
      }
    }
    return colorScheme.primary;
  }
}
