import 'package:cric_live/utils/import_exports.dart';

class TeamCard extends StatefulWidget {
  final TeamSelectionModel team;
  final VoidCallback? onTap;
  final VoidCallback? onViewPlayers;
  final VoidCallback? onDeleteTeam;
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
    this.onDeleteTeam,
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
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

  }

  @override
  void didUpdateWidget(TeamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    return Material(
      color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapCancel: _handleTapCancel,
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
        margin:
            widget.margin ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Logo and Title
                Row(
                  children: [
                    _buildSimpleTeamLogo(theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSimpleTeamName(theme),
                          if (team.tournamentName != null) ...[
                            const SizedBox(height: 4),
                            _buildSimpleTournamentInfo(theme),
                          ],
                          if (team.captain != null || team.coach != null) ...[
                            const SizedBox(height: 6),
                            _buildSimpleTeamInfo(theme),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onViewPlayers != null)
                          _buildViewPlayersButton(theme),
                        if (widget.onViewPlayers != null && widget.onDeleteTeam != null)
                          const SizedBox(width: 8),
                        if (widget.onDeleteTeam != null)
                          _buildDeleteButton(colorScheme),
                      ],
                    ),
                  ],
                ),

                if (showStats && team.totalMatches != null) ...[
                  const SizedBox(height: 10),
                  _buildSimpleStats(theme),
                ],

              ],
            ),
          ),
        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTeamLogo(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getTeamColor(theme.colorScheme).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getTeamColor(theme.colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTeamName(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            team.displayName,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              height: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check_circle,
            size: 20,
            color: theme.colorScheme.primary,
          ),
      ],
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

  Widget _buildViewPlayersButton(ThemeData theme) {
    return GestureDetector(
      onTap: widget.onViewPlayers,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.visibility_outlined,
          size: 18,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // Show confirmation dialog before deleting
        _showDeleteConfirmation();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.delete_outline,
          size: 18,
          color: Colors.red.shade600,
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Delete Team'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${team.teamName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              widget.onDeleteTeam?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.0,
            ),
          ),
        ],
      ),
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
