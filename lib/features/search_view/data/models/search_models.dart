import 'package:cric_live/utils/import_exports.dart';

// Base search item model
abstract class SearchItem {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  
  SearchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
  });

  // Factory method to create SearchItem from API response
  factory SearchItem.fromJson(Map<String, dynamic> json) {
    // Determine if it's a tournament or match based on available fields
    if (json.containsKey('tournamentId') && json['tournamentId'] != null) {
      return SearchTournament.fromJson(json);
    } else if (json.containsKey('matchId') || json.containsKey('id')) {
      return SearchMatch.fromJson(json);
    } else {
      throw Exception('Unknown search item type');
    }
  }
}

// Tournament search result model
class SearchTournament extends SearchItem {
  final String tournamentId;
  final String? description;
  final String? location;
  final String? startDate;
  final String? endDate;
  final int? totalMatches;
  final int? totalTeams;
  final String? status;
  final String? format;
  final int? hostId;
  final String? createdAt;
  final List<dynamic>? scorers;

  SearchTournament({
    required super.id,
    required super.title,
    required super.subtitle,
    required this.tournamentId,
    this.description,
    this.location,
    this.startDate,
    this.endDate,
    this.totalMatches,
    this.totalTeams,
    this.status,
    this.format,
    this.hostId,
    this.createdAt,
    this.scorers,
  }) : super(
          type: 'Tournament',
          icon: Icons.emoji_events,
        );

  factory SearchTournament.fromJson(Map<String, dynamic> json) {
    // Debug logging for tournament parsing
    log('🗓️ SearchTournament.fromJson - Raw JSON: $json');
    
    final tournamentId = json['tournamentId']?.toString() ?? json['id']?.toString() ?? '';
    final title = json['tournamentName'] ?? json['name'] ?? 'Unknown Tournament';
    final hostId = json['hostId'];
    
    log('🏆 Parsing Tournament:');
    log('   - Raw tournamentId field: ${json['tournamentId']}');
    log('   - Raw id field: ${json['id']}');
    log('   - Final tournamentId: "$tournamentId"');
    log('   - Title: "$title"');
    log('   - HostId: $hostId');
    
    return SearchTournament(
      id: tournamentId,
      tournamentId: tournamentId,
      title: title,
      subtitle: _buildTournamentSubtitle(json),
      description: json['description'],
      location: json['location'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalMatches: json['totalMatches'] ?? json['matchCount'],
      totalTeams: json['totalTeams'] ?? json['teamCount'],
      status: json['status'],
      format: json['format'],
      hostId: hostId,
      createdAt: json['createdAt'],
      scorers: json['scorers'] is List ? json['scorers'] : null,
    );
  }

  static String _buildTournamentSubtitle(Map<String, dynamic> json) {
    List<String> parts = [];
    
    if (json['format'] != null) {
      parts.add(json['format']);
    }
    
    if (json['location'] != null) {
      parts.add(json['location']);
    }
    
    if (json['totalTeams'] != null || json['teamCount'] != null) {
      final teams = json['totalTeams'] ?? json['teamCount'];
      parts.add('$teams Teams');
    }
    
    if (json['status'] != null) {
      parts.add(json['status']);
    }
    
    if (json['startDate'] != null) {
      try {
        final date = DateTime.parse(json['startDate']);
        parts.add(DateFormat('MMM yyyy').format(date));
      } catch (e) {
        // If parsing fails, try to extract just the date part
        final dateStr = json['startDate'].toString();
        if (dateStr.contains('T')) {
          parts.add(dateStr.split('T')[0]);
        } else {
          parts.add(dateStr);
        }
      }
    }
    
    return parts.isNotEmpty ? parts.join(' • ') : 'Tournament';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'totalMatches': totalMatches,
      'totalTeams': totalTeams,
      'status': status,
      'format': format,
      'hostId': hostId,
      'createdAt': createdAt,
      'scorers': scorers,
      'type': type,
    };
  }
}

// Match search result model
class SearchMatch extends SearchItem {
  final String matchId;
  final String? team1Name;
  final String? team2Name;
  final String? team1Score;
  final String? team2Score;
  final String? team1Overs;
  final String? team2Overs;
  final String? matchDate;
  final String? matchTime;
  final String? venue;
  final String? status;
  final String? format;
  final String? tournament;
  final String? result;
  final String? playerOfTheMatch;
  final bool? isLive;

  SearchMatch({
    required super.id,
    required super.title,
    required super.subtitle,
    required this.matchId,
    this.team1Name,
    this.team2Name,
    this.team1Score,
    this.team2Score,
    this.team1Overs,
    this.team2Overs,
    this.matchDate,
    this.matchTime,
    this.venue,
    this.status,
    this.format,
    this.tournament,
    this.result,
    this.playerOfTheMatch,
    this.isLive,
  }) : super(
          type: 'Match',
          icon: Icons.sports_cricket,
        );

  factory SearchMatch.fromJson(Map<String, dynamic> json) {
    return SearchMatch(
      id: json['matchId']?.toString() ?? json['id']?.toString() ?? '',
      matchId: json['matchId']?.toString() ?? json['id']?.toString() ?? '',
      title: _buildMatchTitle(json),
      subtitle: _buildMatchSubtitle(json),
      team1Name: json['team1Name'] ?? json['teamA']?.toString(),
      team2Name: json['team2Name'] ?? json['teamB']?.toString(),
      team1Score: json['team1Score']?.toString(),
      team2Score: json['team2Score']?.toString(),
      team1Overs: json['team1Overs']?.toString(),
      team2Overs: json['team2Overs']?.toString(),
      matchDate: json['matchDate'],
      matchTime: json['matchTime'],
      venue: json['venue'] ?? json['location'],
      status: json['status']?.toString(),
      format: json['format']?.toString(),
      tournament: json['tournament'] ?? json['tournamentName'],
      result: json['result']?.toString(),
      playerOfTheMatch: json['playerOfTheMatch'],
      isLive: json['isLive'] ?? (json['status']?.toString().toLowerCase() == 'live'),
    );
  }

  static String _buildMatchTitle(Map<String, dynamic> json) {
    final team1 = json['team1Name'] ?? json['teamA'] ?? 'Team A';
    final team2 = json['team2Name'] ?? json['teamB'] ?? 'Team B';
    return '$team1 vs $team2';
  }

  static String _buildMatchSubtitle(Map<String, dynamic> json) {
    List<String> parts = [];
    
    if (json['status'] != null) {
      parts.add(json['status'].toString());
    }
    
    if (json['format'] != null) {
      parts.add(json['format'].toString());
    }
    
    if (json['tournament'] != null || json['tournamentName'] != null) {
      parts.add(json['tournament'] ?? json['tournamentName']);
    }
    
    if (json['matchDate'] != null) {
      try {
        final date = DateTime.parse(json['matchDate']);
        parts.add(DateFormat('MMM dd').format(date));
      } catch (e) {
        parts.add(json['matchDate']);
      }
    }
    
    return parts.isNotEmpty ? parts.join(' • ') : 'Match';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'title': title,
      'subtitle': subtitle,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'team1Overs': team1Overs,
      'team2Overs': team2Overs,
      'matchDate': matchDate,
      'matchTime': matchTime,
      'venue': venue,
      'status': status,
      'format': format,
      'tournament': tournament,
      'result': result,
      'playerOfTheMatch': playerOfTheMatch,
      'isLive': isLive,
      'type': type,
    };
  }
}

// Search response model to handle API response
class SearchResponse {
  final bool success;
  final String? message;
  final List<SearchItem> results;
  final int totalCount;

  SearchResponse({
    required this.success,
    this.message,
    required this.results,
    required this.totalCount,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    List<SearchItem> items = [];
    
    // Handle the actual API response format: {message: "Success to fetch", result: [array]}
    List<dynamic> searchResults = [];
    
    if (json['result'] != null) {
      // API returns 'result' field containing the array
      if (json['result'] is List) {
        searchResults = json['result'] as List;
      }
    } else if (json['data'] != null) {
      // Fallback for different response structures
      final data = json['data'];
      
      if (data is List) {
        searchResults = data;
      } else if (data is Map && data.containsKey('results')) {
        searchResults = data['results'] as List? ?? [];
      } else if (data is Map && data.containsKey('matches')) {
        searchResults = data['matches'] as List? ?? [];
      } else if (data is Map && data.containsKey('tournaments')) {
        searchResults.addAll(data['tournaments'] as List? ?? []);
        searchResults.addAll(data['matches'] as List? ?? []);
      }
    }
    
    // Parse each item in the results
    for (var item in searchResults) {
      try {
        log('🔄 Parsing search item: $item');
        final parsedItem = SearchItem.fromJson(item);
        
        if (parsedItem is SearchTournament) {
          log('🏆 Created SearchTournament:');
          log('   - ID: "${parsedItem.tournamentId}"');
          log('   - Title: "${parsedItem.title}"');
          log('   - HostId: ${parsedItem.hostId}');
        }
        
        items.add(parsedItem);
      } catch (e) {
        log('Error parsing search item: $e - Item data: $item');
      }
    }

    return SearchResponse(
      success: json['message']?.toString().toLowerCase().contains('success') ?? json['success'] ?? true,
      message: json['message']?.toString(),
      results: items,
      totalCount: json['totalCount'] ?? json['count'] ?? items.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'results': results.map((item) => {
        if (item is SearchTournament) item.toJson()
        else if (item is SearchMatch) item.toJson()
        else {}
      }).toList(),
      'totalCount': totalCount,
    };
  }
}

// Search filter enum
enum SearchFilter {
  all,
  tournaments,
  matches,
  live,
  upcoming,
  completed
}

extension SearchFilterExtension on SearchFilter {
  String get displayName {
    switch (this) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.tournaments:
        return 'Tournaments';
      case SearchFilter.matches:
        return 'Matches';
      case SearchFilter.live:
        return 'Live';
      case SearchFilter.upcoming:
        return 'Upcoming';
      case SearchFilter.completed:
        return 'Completed';
    }
  }

  String get apiValue {
    switch (this) {
      case SearchFilter.all:
        return 'all';
      case SearchFilter.tournaments:
        return 'tournament';
      case SearchFilter.matches:
        return 'match';
      case SearchFilter.live:
        return 'live';
      case SearchFilter.upcoming:
        return 'upcoming';
      case SearchFilter.completed:
        return 'completed';
    }
  }
}