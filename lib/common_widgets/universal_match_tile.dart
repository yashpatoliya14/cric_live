import 'package:cric_live/utils/import_exports.dart';

enum MatchTileDisplayMode {
  live,      // For live match section with timeline
  search,    // For search results
  history,   // For history section with timeline
  compact    // For compact display
}

class UniversalMatchTile extends StatelessWidget {
  final dynamic matchData; // Can be SearchMatch, MatchModel, or dynamic live match data
  final MatchTileDisplayMode displayMode;
  final VoidCallback? onTap;
  @Deprecated('History functionality has been removed')
  final VoidCallback? onHistoryTap;
  final VoidCallback? onDeleteTap; // New delete callback
  @Deprecated('History functionality has been removed')
  final bool showHistory;
  final bool showMatchIds;
  final bool showTimeline;
  final bool showDeleteButton; // New parameter to control delete button visibility
  final Color? statusColor;

  const UniversalMatchTile({
    super.key,
    required this.matchData,
    required this.displayMode,
    this.onTap,
    @Deprecated('History functionality has been removed') this.onHistoryTap,
    this.onDeleteTap,
    @Deprecated('History functionality has been removed') this.showHistory = false,
    this.showMatchIds = true,
    this.showTimeline = false,
    this.showDeleteButton = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case MatchTileDisplayMode.live:
        return _buildLiveTile(context);
      case MatchTileDisplayMode.search:
        return _buildSearchTile(context);
      case MatchTileDisplayMode.history:
        return _buildHistoryTile(context);
      case MatchTileDisplayMode.compact:
        return _buildCompactTile(context);
    }
  }

  // Responsive design utilities

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 
                       screenWidth < 600 ? 1.0 : 
                       screenWidth < 1024 ? 1.1 : 1.15;
    return baseFontSize * scaleFactor;
  }

  double _getResponsivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.7 : 
                       screenWidth < 600 ? 0.8 : 
                       screenWidth < 1024 ? 0.9 : 1.0;
    return basePadding * scaleFactor;
  }

  double _getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.8 : 
                       screenWidth < 600 ? 0.85 : 
                       screenWidth < 1024 ? 0.9 : 1.0;
    return baseIconSize * scaleFactor;
  }

  Widget _buildLiveTile(BuildContext context) {
    final bottomMargin = _getResponsivePadding(context, 10);
    final timelineSize = _getResponsiveIconSize(context, 10);
    final timelineSpacing = _getResponsivePadding(context, 12);
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator for live section
          if (showTimeline) ...[
            Column(
              children: [
                Container(
                  width: timelineSize,
                  height: timelineSize,
                  decoration: BoxDecoration(
                    color: statusColor ?? _getStatusColor(_getStatus()),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
                Container(
                  width: 1.5, 
                  height: _getResponsivePadding(context, 50), 
                  color: Colors.grey.shade300
                ),
              ],
            ),
            SizedBox(width: timelineSpacing),
          ],
          
          // Main card content
          Expanded(
            child: _buildMainCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTile(BuildContext context) {
    final horizontalMargin = _getResponsivePadding(context, 12);
    final verticalMargin = _getResponsivePadding(context, 4);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin, 
        vertical: verticalMargin
      ),
      child: _buildMainCard(context),
    );
  }

  Widget _buildHistoryTile(BuildContext context) {
    final bottomMargin = _getResponsivePadding(context, 12);
    final timelineSize = _getResponsiveIconSize(context, 12);
    final timelineSpacing = _getResponsivePadding(context, 12);
    
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator for history
          if (showTimeline) ...[
            Column(
              children: [
                Container(
                  width: timelineSize,
                  height: timelineSize,
                  decoration: BoxDecoration(
                    color: statusColor ?? _getStatusColor(_getStatus()),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: (statusColor ?? _getStatusColor(_getStatus())).withOpacity(0.25),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1.5, 
                  height: _getResponsivePadding(context, 60), 
                  color: Colors.grey.shade200
                ),
              ],
            ),
            SizedBox(width: timelineSpacing),
          ],
          
          // Main card content
          Expanded(
            child: _buildMainCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTile(BuildContext context) {
    return _buildMainCard(context);
  }

  Widget _buildMainCard(BuildContext context) {
    final cardPadding = _getResponsivePadding(context, 16);
    final borderRadius = _getResponsivePadding(context, 12);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompactHeader(context),
                SizedBox(height: _getResponsivePadding(context, 12)),
                _buildCompactTeamsSection(context),
                if (_shouldShowFooter()) ...[
                  SizedBox(height: _getResponsivePadding(context, 10)),
                  _buildCompactFooter(context),
                ],
                if (showDeleteButton && onDeleteTap != null) ...[
                  SizedBox(height: _getResponsivePadding(context, 8)),
                  _buildDeleteButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowFooter() {
    final result = _getResult();
    final venue = _getVenue();
    return (result != null && result.isNotEmpty) || 
           (venue != null && venue.isNotEmpty) || 
           showMatchIds;
  }

  Widget _buildCompactHeader(BuildContext context) {
    final status = _getStatus();
    final isLive = status.toLowerCase() == 'live';
    final statusFontSize = _getResponsiveFontSize(context, 10);
    final titleFontSize = _getResponsiveFontSize(context, 14);
    final subtitleFontSize = _getResponsiveFontSize(context, 11);
    final dateFontSize = _getResponsiveFontSize(context, 10);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge - more compact
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                status.toUpperCase(),
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: statusFontSize,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Match info - more compact
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTournamentName() ?? 'Cricket Match',
                style: GoogleFonts.nunito(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (_getMatchType() != null) ...[
                const SizedBox(height: 2),
                Text(
                  _getMatchType()!,
                  style: GoogleFonts.nunito(
                    fontSize: subtitleFontSize,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        
        // Date - more compact
        if (_getMatchDate() != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 0.5,
              ),
            ),
            child: Text(
              _formatMatchDate(_getMatchDate()!),
              style: GoogleFonts.nunito(
                fontSize: dateFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildCompactTeamsSection(BuildContext context) {
    return Row(
      children: [
        // Team 1
        Expanded(
          child: _buildCompactTeamInfo(
            context, 
            _getTeam1Name(), 
            _getTeam1Score(), 
            _getTeam1Overs(), 
            true
          ),
        ),
        
        // VS divider - more compact
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          child: Text(
            'VS',
            style: GoogleFonts.nunito(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
              fontSize: _getResponsiveFontSize(context, 10),
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Team 2
        Expanded(
          child: _buildCompactTeamInfo(
            context, 
            _getTeam2Name(), 
            _getTeam2Score(), 
            _getTeam2Overs(), 
            false
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTeamInfo(BuildContext context, String teamName, String? score, String? overs, bool isTeam1) {
    final teamNameFontSize = _getResponsiveFontSize(context, 14);
    final scoreFontSize = _getResponsiveFontSize(context, 16);
    final oversFontSize = _getResponsiveFontSize(context, 10);
    
    return Column(
      crossAxisAlignment: isTeam1 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // Team name
        Text(
          teamName,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: teamNameFontSize,
            color: Colors.grey.shade800,
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: isTeam1 ? TextAlign.left : TextAlign.right,
        ),
        
        const SizedBox(height: 8),
        
        // Score and overs
        if (score != null && score.isNotEmpty && score != '-') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTeam1 ? Colors.blue.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTeam1 ? Colors.blue.shade200 : Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: isTeam1 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: scoreFontSize,
                    color: isTeam1 ? Colors.blue.shade700 : Colors.orange.shade700,
                    height: 1.0,
                  ),
                ),
                if (overs != null && overs.isNotEmpty && overs != '-') ...[
                  const SizedBox(height: 2),
                  Text(
                    '$overs overs',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w500,
                      fontSize: oversFontSize,
                      color: isTeam1 ? Colors.blue.shade600 : Colors.orange.shade600,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 0.5,
              ),
            ),
            child: Text(
              'Not Started',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: oversFontSize,
                color: Colors.grey.shade500,
                height: 1.1,
              ),
            ),
          ),
        ],
      ],
    );
  }



  Widget _buildCompactFooter(BuildContext context) {
    final result = _getResult();
    final venue = _getVenue();
    final resultFontSize = _getResponsiveFontSize(context, 11);
    final venueFontSize = _getResponsiveFontSize(context, 9);
    final chipFontSize = _getResponsiveFontSize(context, 8);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Result - if available
          if (result != null && result.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 12,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    result,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: resultFontSize,
                      color: Colors.grey.shade700,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if ((venue != null && venue.isNotEmpty) || showMatchIds)
              const SizedBox(height: 8),
          ],
          
          // Bottom row with venue and IDs
          if ((venue != null && venue.isNotEmpty) || showMatchIds)
            Row(
              children: [
                // Venue
                if (venue != null && venue.isNotEmpty) ...[
                  Icon(
                    Icons.location_on,
                    size: 10,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venue,
                      style: GoogleFonts.nunito(
                        fontSize: venueFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
                
                // Match IDs - compact chips
                if (showMatchIds) ...[
                  if (venue != null && venue.isNotEmpty)
                    const SizedBox(width: 8),
                  _buildCompactMatchIdChips(context, chipFontSize),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactMatchIdChips(BuildContext context, double fontSize) {
    final localId = _getLocalMatchId();
    final onlineId = _getOnlineMatchId();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (localId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'L:$localId',
              style: GoogleFonts.nunito(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
        
        if (localId != null && onlineId != null)
          const SizedBox(width: 4),
        
        if (onlineId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'O:$onlineId',
              style: GoogleFonts.nunito(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
      ],
    );
  }




  Widget _buildDeleteButton(BuildContext context) {
    final buttonFontSize = _getResponsiveFontSize(context, 11);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade200,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDeleteTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Delete Match',
                    style: GoogleFonts.nunito(
                      fontSize: buttonFontSize,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red.shade500,
                  size: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Data extraction methods that work with different data types
  String _getStatus() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).status ?? 'Unknown';
    } else if (matchData is CompleteMatchResultModel) {
      return (matchData as CompleteMatchResultModel).status ?? 'Unknown';
    } else if (matchData is Map) {
      return matchData['status']?.toString() ?? 'Unknown';
    } else {
      // Try to get status from dynamic object
      try {
        return matchData?.status?.toString() ?? 'Unknown';
      } catch (e) {
        return 'Unknown';
      }
    }
  }

  String _getTeam1Name() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).team1Name ?? 'Team 1';
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.team1Innings?.teamName ?? match.team1Name ?? 'Team 1';
    } else if (matchData is Map) {
      return matchData['team1Name']?.toString() ?? 
             matchData['teamA']?.toString() ?? 
             'Team 1';
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.team1Innings?.teamName != null) {
          return matchData?.matchState?.team1Innings?.teamName?.toString() ?? 'Team 1';
        }
        if (matchData?.matchState?.team1Name != null) {
          return matchData?.matchState?.team1Name?.toString() ?? 'Team 1';
        }
        // Fallback to direct access
        return matchData?.team1Name?.toString() ?? 
               matchData?.teamA?.toString() ?? 
               matchData?.team1Innings?.teamName?.toString() ?? 
               'Team 1';
      } catch (e) {
        return 'Team 1';
      }
    }
  }

  String _getTeam2Name() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).team2Name ?? 'Team 2';
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.team2Innings?.teamName ?? match.team2Name ?? 'Team 2';
    } else if (matchData is Map) {
      return matchData['team2Name']?.toString() ?? 
             matchData['teamB']?.toString() ?? 
             'Team 2';
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.team2Innings?.teamName != null) {
          return matchData?.matchState?.team2Innings?.teamName?.toString() ?? 'Team 2';
        }
        if (matchData?.matchState?.team2Name != null) {
          return matchData?.matchState?.team2Name?.toString() ?? 'Team 2';
        }
        // Fallback to direct access
        return matchData?.team2Name?.toString() ?? 
               matchData?.teamB?.toString() ?? 
               matchData?.team2Innings?.teamName?.toString() ?? 
               'Team 2';
      } catch (e) {
        return 'Team 2';
      }
    }
  }

  String? _getTeam1Score() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).team1Score;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.team1Innings?.scoreDisplay;
    } else if (matchData is Map) {
      return matchData['team1Score']?.toString();
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.team1Innings?.scoreDisplay != null) {
          return matchData?.matchState?.team1Innings?.scoreDisplay?.toString();
        }
        // Fallback to direct access
        return matchData?.team1Innings?.scoreDisplay?.toString() ?? 
               matchData?.team1Score?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getTeam2Score() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).team2Score;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.team2Innings?.scoreDisplay;
    } else if (matchData is Map) {
      return matchData['team2Score']?.toString();
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.team2Innings?.scoreDisplay != null) {
          return matchData?.matchState?.team2Innings?.scoreDisplay?.toString();
        }
        // Fallback to direct access
        return matchData?.team2Innings?.scoreDisplay?.toString() ?? 
               matchData?.team2Score?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getTeam1Overs() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).team1Overs;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.team1Innings?.oversDisplay;
    } else if (matchData is Map) {
      return matchData['team1Overs']?.toString();
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.team1Innings?.oversDisplay != null) {
          return matchData?.matchState?.team1Innings?.oversDisplay?.toString();
        }
        // Fallback to direct access
        return matchData?.team1Innings?.oversDisplay?.toString() ?? 
               matchData?.team1Overs?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getTeam2Overs() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).team2Overs;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.team2Innings?.oversDisplay;
    } else if (matchData is Map) {
      return matchData['team2Overs']?.toString();
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.team2Innings?.oversDisplay != null) {
          return matchData?.matchState?.team2Innings?.oversDisplay?.toString();
        }
        // Fallback to direct access
        return matchData?.team2Innings?.oversDisplay?.toString() ?? 
               matchData?.team2Overs?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getTournamentName() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).tournament;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.matchTitle;
    } else if (matchData is Map) {
      return matchData['tournament']?.toString() ?? 
             matchData['tournamentName']?.toString();
    } else {
      try {
        return matchData?.tournament?.toString() ?? 
               matchData?.tournamentName?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getMatchType() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).format;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.matchType;
    } else if (matchData is Map) {
      return matchData['format']?.toString() ?? 
             matchData['matchType']?.toString();
    } else {
      try {
        return matchData?.format?.toString() ?? 
               matchData?.matchType?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getMatchDate() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).matchDate;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.date?.toIso8601String();
    } else if (matchData is Map) {
      return matchData['matchDate']?.toString();
    } else {
      try {
        return matchData?.matchDate?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getResult() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).result;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.resultDescription ?? match.matchSummary;
    } else if (matchData is Map) {
      return matchData['result']?.toString() ?? 
             matchData['resultDescription']?.toString() ??
             matchData['matchSummary']?.toString();
    } else {
      try {
        // First try to get from matchState (for completed matches)
        if (matchData?.matchState?.resultDescription != null) {
          return matchData?.matchState?.resultDescription?.toString();
        }
        if (matchData?.matchState?.matchSummary != null) {
          return matchData?.matchState?.matchSummary?.toString();
        }
        // Fallback to direct match result
        return matchData?.result?.toString() ?? 
               matchData?.resultDescription?.toString() ??
               matchData?.matchSummary?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getVenue() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).venue;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.location;
    } else if (matchData is Map) {
      return matchData['venue']?.toString() ?? 
             matchData['location']?.toString();
    } else {
      try {
        return matchData?.venue?.toString() ?? 
               matchData?.location?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getLocalMatchId() {
    if (matchData is SearchMatch) {
      return (matchData as SearchMatch).matchId;
    } else if (matchData is CompleteMatchResultModel) {
      final match = matchData as CompleteMatchResultModel;
      return match.matchId?.toString();
    } else if (matchData is Map) {
      return matchData['id']?.toString() ?? 
             matchData['matchId']?.toString();
    } else {
      try {
        return matchData?.id?.toString() ?? 
               matchData?.matchId?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  String? _getOnlineMatchId() {
    if (matchData is Map) {
      return matchData['onlineMatchId']?.toString();
    } else {
      try {
        return matchData?.onlineMatchId?.toString();
      } catch (e) {
        return null;
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
      case 'ongoing':
        return Colors.red;
      case 'completed':
      case 'finished':
        return Colors.green;
      case 'upcoming':
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatMatchDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference == -1) {
        return 'Tomorrow';
      } else {
        return DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}