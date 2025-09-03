import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/team_selection_model.dart';

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
    Key? key,
    required this.team,
    this.onTap,
    this.onViewPlayers,
    this.showStats = true,
    this.showActions = true,
    this.isSelected = false,
    this.margin,
    this.elevation,
  }) : super(key: key);

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard>
    with TickerProviderStateMixin {
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shineAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));

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
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? _pulseAnimation.value : 1.0,
                  child: Stack(
                    children: [
                      // Glassmorphism background
                      _buildGlassmorphismCard(theme, colorScheme),
                      // Shine effect overlay
                      if (isSelected) _buildShineEffect(),
                      // Main content
                      _buildCardContent(theme, colorScheme),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphismCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.15),
                  colorScheme.primaryContainer.withOpacity(0.25),
                  colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.25)
                : Colors.black.withOpacity(0.1),
            blurRadius: isSelected ? 20 : 10,
            offset: Offset(0, isSelected ? 8 : 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildShineEffect() {
    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_shineAnimation.value),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.surface.withOpacity(0.9)
                    : colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Logo and Title
                  Row(
                    children: [
                      Hero(
                        tag: 'team_logo_${team.teamId}',
                        child: _buildEnhancedTeamLogo(theme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEnhancedTeamName(theme),
                            const SizedBox(height: 6),
                            if (team.tournamentName != null)
                              _buildEnhancedTournamentInfo(theme),
                          ],
                        ),
                      ),
                      _buildSelectionIndicator(colorScheme),
                    ],
                  ),

                  if (team.teamDescription != null) ...[
                    const SizedBox(height: 16),
                    _buildDescription(theme),
                  ],

                  if (team.captain != null || team.coach != null) ...[
                    const SizedBox(height: 16),
                    _buildEnhancedTeamInfo(theme),
                  ],

                  if (showStats && team.totalMatches != null) ...[
                    const SizedBox(height: 16),
                    _buildEnhancedStats(theme),
                  ],

                  if (team.badges != null && team.badges!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildEnhancedBadges(theme),
                  ],

                  if (showActions) ...[
                    const SizedBox(height: 20),
                    _buildEnhancedActionButtons(theme),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Legacy methods removed - using enhanced versions instead

  Widget _buildDescription(ThemeData theme) {
    return Text(
      team.teamDescription!,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
            : theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Legacy methods removed - using enhanced versions instead

  // Enhanced UI Methods
  Widget _buildEnhancedTeamLogo(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? 80 : 70,
      height: isSelected ? 80 : 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _getTeamColor(theme.colorScheme),
            _getTeamColor(theme.colorScheme).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTeamColor(theme.colorScheme).withOpacity(0.4),
            blurRadius: isSelected ? 15 : 8,
            offset: Offset(0, isSelected ? 6 : 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: team.teamLogo != null && team.teamLogo!.isNotEmpty
            ? team.teamLogo!.startsWith('http')
                ? Image.network(
                    team.teamLogo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildEnhancedDefaultLogo(theme),
                  )
                : Image.asset(
                    team.teamLogo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildEnhancedDefaultLogo(theme),
                  )
            : _buildEnhancedDefaultLogo(theme),
      ),
    );
  }

  Widget _buildEnhancedDefaultLogo(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTeamColor(theme.colorScheme),
            _getTeamColor(theme.colorScheme).withOpacity(0.8),
            _getTeamColor(theme.colorScheme).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          team.teamName.isNotEmpty
              ? team.teamName.substring(0, 1).toUpperCase()
              : 'T',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTeamName(ThemeData theme) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: isSelected
            ? [theme.colorScheme.primary, theme.colorScheme.secondary]
            : [theme.colorScheme.onSurface, theme.colorScheme.onSurface],
      ).createShader(bounds),
      child: Text(
        team.displayName,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white, // This will be replaced by the shader
          fontSize: isSelected ? 22 : 20,
          letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEnhancedTournamentInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondaryContainer.withOpacity(0.8),
            theme.colorScheme.secondaryContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 14,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            team.tournamentName!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? 50 : 30,
      height: isSelected ? 50 : 30,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              )
            : LinearGradient(
                colors: [
                  colorScheme.outline.withOpacity(0.3),
                  colorScheme.outline.withOpacity(0.2),
                ],
              ),
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: colorScheme.onPrimary,
                size: isSelected ? 24 : 16,
                key: const ValueKey('selected'),
              )
            : Icon(
                Icons.radio_button_unchecked_rounded,
                color: colorScheme.outline,
                size: 16,
                key: const ValueKey('unselected'),
              ),
      ),
    );
  }

  Widget _buildEnhancedTeamInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (team.captain != null) ..._buildInfoChip(
            theme,
            Icons.stars_rounded,
            'Captain',
            team.captain!,
            theme.colorScheme.primary,
          ),
          if (team.captain != null && team.coach != null) ...
            [const SizedBox(width: 12)],
          if (team.coach != null) ..._buildInfoChip(
            theme,
            Icons.person_rounded,
            'Coach',
            team.coach!,
            theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInfoChip(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildEnhancedStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildEnhancedStatItem(
            theme,
            'Matches',
            '${team.totalMatches}',
            Icons.sports_cricket_rounded,
            theme.colorScheme.primary,
          ),
          _buildStatDivider(theme),
          _buildEnhancedStatItem(
            theme,
            'Win Rate',
            team.formattedWinPercentage,
            Icons.emoji_events_rounded,
            Colors.amber,
          ),
          _buildStatDivider(theme),
          _buildEnhancedStatItem(
            theme,
            'Players',
            '${team.totalPlayers ?? 0}',
            Icons.group_rounded,
            theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 2,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.outline.withOpacity(0.1),
            theme.colorScheme.outline.withOpacity(0.3),
            theme.colorScheme.outline.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildEnhancedStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBadges(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: team.badges!.take(3).map((badge) {
        final colors = _getBadgeColors(badge);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getBadgeIcon(badge),
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                badge,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Color> _getBadgeColors(String badge) {
    switch (badge.toLowerCase()) {
      case 'champion':
      case 'winner':
        return [Colors.amber, Colors.amber.shade700];
      case 'runner-up':
      case 'finalist':
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 'best batting':
        return [Colors.green, Colors.green.shade700];
      case 'best bowling':
        return [Colors.blue, Colors.blue.shade700];
      default:
        return [Colors.purple, Colors.purple.shade700];
    }
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge.toLowerCase()) {
      case 'champion':
      case 'winner':
        return Icons.emoji_events_rounded;
      case 'runner-up':
      case 'finalist':
        return Icons.military_tech_rounded;
      case 'best batting':
        return Icons.sports_cricket_rounded;
      case 'best bowling':
        return Icons.sports_baseball_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Widget _buildEnhancedActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.check_circle_outline_rounded,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              label: Text(
                'Select Team',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (widget.onViewPlayers != null) ...[
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              onPressed: widget.onViewPlayers,
              icon: Icon(
                Icons.visibility_rounded,
                color: theme.colorScheme.primary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(14),
              ),
              tooltip: 'View Players',
            ),
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
