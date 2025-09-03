class TeamSelectionModel {
  final int? id;
  final int? teamId;
  final String teamName;
  final String? teamLogo;
  final String? teamDescription;
  final int? tournamentId;
  final String? tournamentName;
  final int? totalPlayers;
  final int? totalMatches;
  final int? wins;
  final int? losses;
  final DateTime? createdAt;
  final bool? isActive;
  final String? teamColor;
  final String? captain;
  final String? coach;
  final List<String>? badges; // For achievements like "Champion", "Runner-up"

  TeamSelectionModel({
    this.id,
    this.teamId,
    required this.teamName,
    this.teamLogo,
    this.teamDescription,
    this.tournamentId,
    this.tournamentName,
    this.totalPlayers,
    this.totalMatches,
    this.wins,
    this.losses,
    this.createdAt,
    this.isActive = true,
    this.teamColor,
    this.captain,
    this.coach,
    this.badges,
  });

  // Computed properties
  double get winPercentage {
    if (totalMatches == null || totalMatches == 0) return 0.0;
    return ((wins ?? 0) / totalMatches!) * 100;
  }

  String get formattedWinPercentage {
    return '${winPercentage.toStringAsFixed(1)}%';
  }

  String get teamStats {
    if (totalMatches == null) return 'No matches played';
    return 'W: ${wins ?? 0} | L: ${losses ?? 0} | Total: $totalMatches';
  }

  String get displayName {
    return teamName.trim().isNotEmpty ? teamName : 'Unnamed Team';
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamId': teamId,
      'teamName': teamName,
      'teamLogo': teamLogo,
      'teamDescription': teamDescription,
      'tournamentId': tournamentId,
      'tournamentName': tournamentName,
      'totalPlayers': totalPlayers,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
      'teamColor': teamColor,
      'captain': captain,
      'coach': coach,
      'badges': badges?.join(','),
    };
  }

  // Create from Map (database)
  factory TeamSelectionModel.fromMap(Map<String, dynamic> map) {
    return TeamSelectionModel(
      id: map['id'] as int?,
      teamId: map['teamId'] as int?,
      teamName: map['teamName'] as String? ?? '',
      teamLogo: map['teamLogo'] as String?,
      teamDescription: map['teamDescription'] as String?,
      tournamentId: map['tournamentId'] as int?,
      tournamentName: map['tournamentName'] as String?,
      totalPlayers: map['totalPlayers'] as int?,
      totalMatches: map['totalMatches'] as int?,
      wins: map['wins'] as int?,
      losses: map['losses'] as int?,
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      isActive: map['isActive'] as bool? ?? true,
      teamColor: map['teamColor'] as String?,
      captain: map['captain'] as String?,
      coach: map['coach'] as String?,
      badges: map['badges'] != null 
          ? (map['badges'] as String).split(',').where((b) => b.isNotEmpty).toList()
          : null,
    );
  }

  // Create from JSON
  factory TeamSelectionModel.fromJson(Map<String, dynamic> json) {
    return TeamSelectionModel(
      id: json['id'] as int?,
      teamId: json['teamId'] as int?,
      teamName: json['teamName'] as String? ?? '',
      teamLogo: json['teamLogo'] as String?,
      teamDescription: json['teamDescription'] as String?,
      tournamentId: json['tournamentId'] as int?,
      tournamentName: json['tournamentName'] as String?,
      totalPlayers: json['totalPlayers'] as int?,
      totalMatches: json['totalMatches'] as int?,
      wins: json['wins'] as int?,
      losses: json['losses'] as int?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      teamColor: json['teamColor'] as String?,
      captain: json['captain'] as String?,
      coach: json['coach'] as String?,
      badges: json['badges'] != null 
          ? List<String>.from(json['badges'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'teamName': teamName,
      'teamLogo': teamLogo,
      'teamDescription': teamDescription,
      'tournamentId': tournamentId,
      'tournamentName': tournamentName,
      'totalPlayers': totalPlayers,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
      'teamColor': teamColor,
      'captain': captain,
      'coach': coach,
      'badges': badges,
    };
  }

  // Create a copy with modifications
  TeamSelectionModel copyWith({
    int? id,
    int? teamId,
    String? teamName,
    String? teamLogo,
    String? teamDescription,
    int? tournamentId,
    String? tournamentName,
    int? totalPlayers,
    int? totalMatches,
    int? wins,
    int? losses,
    DateTime? createdAt,
    bool? isActive,
    String? teamColor,
    String? captain,
    String? coach,
    List<String>? badges,
  }) {
    return TeamSelectionModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      teamLogo: teamLogo ?? this.teamLogo,
      teamDescription: teamDescription ?? this.teamDescription,
      tournamentId: tournamentId ?? this.tournamentId,
      tournamentName: tournamentName ?? this.tournamentName,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      teamColor: teamColor ?? this.teamColor,
      captain: captain ?? this.captain,
      coach: coach ?? this.coach,
      badges: badges ?? this.badges,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamSelectionModel &&
        other.teamId == teamId &&
        other.teamName == teamName;
  }

  @override
  int get hashCode => teamId.hashCode ^ teamName.hashCode;

  @override
  String toString() {
    return 'TeamSelectionModel(id: $id, teamId: $teamId, teamName: $teamName, winPercentage: $formattedWinPercentage)';
  }
}
