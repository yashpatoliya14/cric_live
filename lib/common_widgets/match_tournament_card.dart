import 'package:cric_live/utils/import_exports.dart';

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
  final String? location;
  final String? matchDate;
  final String? tournament;
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
    this.location,
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
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                _buildEnhancedMatchStatusRow(context),
                const SizedBox(height: 16),
                _buildEnhancedTeamRow(
                  context,
                  team1Name,
                  team1Score,
                  team1Overs,
                ),
                const SizedBox(height: 12),
                _buildEnhancedTeamRow(
                  context,
                  team2Name,
                  team2Score,
                  team2Overs,
                ),
                if (resultDescription != null || playerOfTheMatch != null) ...[
                  const SizedBox(height: 16),
                  _buildMatchAdditionalInfo(context),
                ],
                if (location != null || matchType != null) ...[
                  const SizedBox(height: 12),
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
                style: GoogleFonts.nunito(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (tournament != null)
                Text(
                  tournament!,
                  style: GoogleFonts.nunito(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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
              style: GoogleFonts.nunito(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedMatchStatusBadge(BuildContext context) {
    final isLive = matchStatus.toLowerCase() == "live";
    final isCompleted = matchStatus.toLowerCase() == "completed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isLive
                ? Colors.red
                : isCompleted
                ? Colors.green
                : Colors.grey,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isLive
                    ? Colors.red
                    : isCompleted
                    ? Colors.green
                    : Colors.grey)
                .withOpacity(0.3),
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
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              fontSize: 11,
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
                colors: [
                  Colors.deepOrange.shade300,
                  Colors.deepOrange.shade500,
                ],
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
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.deepOrange,
                  ),
                ),
                if (overs != null)
                  Text(
                    '($overs overs)',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMatchAdditionalInfo(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resultDescription != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    resultDescription!,
                    style: GoogleFonts.nunito(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (resultDescription != null && playerOfTheMatch != null)
            const SizedBox(height: 12),
          if (playerOfTheMatch != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Player of the Match: $playerOfTheMatch',
                    style: GoogleFonts.nunito(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  Widget _buildMatchMetadata(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (matchType != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_cricket,
                    color: Colors.deepOrange.shade700,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    matchType!,
                    style: GoogleFonts.nunito(
                      color: Colors.deepOrange.shade700,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (matchType != null && location != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          if (location != null) ...[
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey.shade600,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location!,
                      style: GoogleFonts.nunito(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
