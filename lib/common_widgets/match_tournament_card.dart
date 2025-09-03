import 'package:cric_live/utils/import_exports.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchTournamentCard extends StatelessWidget {
  final String team1Name;
  final String? team1Score;
  final String? team1Overs;
  final String team2Name;
  final String? team2Score;
  final String? team2Overs;
  final String matchStatus; // e.g., "LIVE", "COMPLETED", "UPCOMING"
  final String matchStatusDescription;
  final VoidCallback? onTap;
  final String? matchDate;
  final String? tournament;
  final String? venue;
  final String? matchType;
  final String? resultDescription;
  final String? playerOfTheMatch;

  const MatchTournamentCard({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.matchStatus,
    required this.matchStatusDescription,
    this.team1Score,
    this.team1Overs,
    this.team2Score,
    this.team2Overs,
    this.onTap,
    this.matchDate,
    this.tournament,
    this.venue,
    this.matchType,
    this.resultDescription,
    this.playerOfTheMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                _buildEnhancedMatchStatusRow(context),
                const SizedBox(height: 16),
                _buildEnhancedTeamRow(context, team1Name, team1Score, team1Overs),
                const SizedBox(height: 12),
                _buildEnhancedTeamRow(context, team2Name, team2Score, team2Overs),
                if (resultDescription != null || playerOfTheMatch != null) ..[                  const SizedBox(height: 16),
                  _buildMatchAdditionalInfo(context),
                ],
                if (venue != null || matchType != null) ..[                  const SizedBox(height: 12),
                  _buildMatchMetadata(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMatchStatusRow(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _buildEnhancedMatchStatusBadge(context),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                matchStatusDescription,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (tournament != null)
                Text(
                  tournament!,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (matchDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              matchDate!,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedMatchStatusBadge(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLive = matchStatus.toLowerCase() == "live";
    final isCompleted = matchStatus.toLowerCase() == "completed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLive 
            ? Colors.red 
            : isCompleted 
                ? Colors.green 
                : Colors.grey,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isLive ? Colors.red : isCompleted ? Colors.green : Colors.grey).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          if (isLive) const SizedBox(width: 6),
          Text(
            matchStatus.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a row for a single team, showing name, score, and overs.
  Widget _buildEnhancedTeamRow(
    BuildContext context,
    String name,
    String? score,
    String? overs,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Team Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade300, Colors.deepOrange.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'T',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Team Name
          Expanded(
            flex: 5,
            child: Text(
              name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          // Score and Overs
          if (score != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                if (overs != null)
                  Text(
                    '($overs overs)',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  Widget buildMatchAdditionalInfo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resultDescription != null) ..[            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.green.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resultDescription!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (resultDescription != null && playerOfTheMatch != null)
            const SizedBox(height: 8),
          if (playerOfTheMatch != null) ..[            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Player of the Match: $playerOfTheMatch',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget buildMatchMetadata(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      children: [
        if (matchType != null) ..[          Icon(
            Icons.sports_cricket,
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            matchType!,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (matchType != null && venue != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        if (venue != null) ..[          Icon(
            Icons.location_on,
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              venue!,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
