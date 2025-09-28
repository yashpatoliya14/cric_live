import 'package:cric_live/utils/import_exports.dart';

class SearchResultTile extends StatelessWidget {
  final SearchItem searchItem;
  final VoidCallback? onTap;
  final bool showHistory;
  final VoidCallback? onHistoryTap;
  final CompleteMatchResultModel? matchState; // Enhanced match state data

  const SearchResultTile({
    super.key,
    required this.searchItem,
    this.onTap,
    this.showHistory = false,
    this.onHistoryTap,
    this.matchState, // Optional detailed match state
  });

  @override
  Widget build(BuildContext context) {
    if (searchItem is SearchMatch) {
      return _buildMatchTile(context, searchItem as SearchMatch);
    } else if (searchItem is SearchTournament) {
      return _buildTournamentTile(context, searchItem as SearchTournament);
    } else {
      return _buildGenericTile(context);
    }
  }

  Widget _buildMatchTile(BuildContext context, SearchMatch match) {
    // Use enhanced match state if available, otherwise fall back to basic search match data
    dynamic displayData = matchState ?? match;
    
    return UniversalMatchTile(
      matchData: displayData,
      displayMode: MatchTileDisplayMode.search,
      onTap: onTap,
      onHistoryTap: showHistory ? onHistoryTap : null,
      showHistory: showHistory,
      showMatchIds: true, // Show match IDs in search results
      showTimeline: false, // No timeline in search mode
    );
  }

  Widget _buildTournamentTile(BuildContext context, SearchTournament tournament) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          // Tournament card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.purple.shade50],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      _buildTournamentHeader(context, tournament),
                      const SizedBox(height: 16),
                      _buildTournamentDetails(context, tournament),
                      if (tournament.description != null) ...[
                        const SizedBox(height: 12),
                        _buildTournamentDescription(context, tournament),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // History section is handled by the tile component itself
        ],
      ),
    );
  }

  Widget _buildTournamentHeader(BuildContext context, SearchTournament tournament) {
    return Row(
      children: [
        // Tournament icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade300, Colors.purple.shade500],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        
        // Tournament name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tournament.title,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                tournament.subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Tournament status badge
        if (tournament.status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTournamentStatusColor(tournament.status!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tournament.status!.toUpperCase(),
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTournamentDetails(BuildContext context, SearchTournament tournament) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (tournament.totalTeams != null) ...[
            _buildTournamentStat(
              icon: Icons.group,
              label: 'Teams',
              value: tournament.totalTeams.toString(),
              color: Colors.blue,
            ),
          ],
          if (tournament.totalMatches != null) ...[
            if (tournament.totalTeams != null) const SizedBox(width: 24),
            _buildTournamentStat(
              icon: Icons.sports_cricket,
              label: 'Matches',
              value: tournament.totalMatches.toString(),
              color: Colors.green,
            ),
          ],
          if (tournament.location != null) ...[
            if (tournament.totalTeams != null || tournament.totalMatches != null) 
              const SizedBox(width: 24),
            _buildTournamentStat(
              icon: Icons.location_on,
              label: 'Location',
              value: tournament.location!,
              color: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTournamentStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentDescription(BuildContext context, SearchTournament tournament) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Text(
        tournament.description!,
        style: GoogleFonts.nunito(
          fontSize: 13,
          color: Colors.purple.shade700,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }


  Widget _buildGenericTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    searchItem.icon,
                    color: Colors.deepOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        searchItem.title,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        searchItem.subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    searchItem.type,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Color _getTournamentStatusColor(String status) {
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
}