import 'dart:developer';

class TournamentModel {
  final int tournamentId;
  final String name;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String format;
  final int hostId;
  final DateTime createdAt;
  final List<Scorer> scorers;

  TournamentModel({
    required this.tournamentId,
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.format,
    required this.hostId,
    required this.createdAt,
    required this.scorers,
  });

  factory TournamentModel.fromMap(Map<String, dynamic> map) {
    log("TournamentModel.fromMap input: $map");

    try {
      var model = TournamentModel(
        tournamentId: map['tournamentId'] ?? 0,
        name: map['name'] ?? '',
        location: map['location'] ?? '',
        startDate: DateTime.parse(
          map['startDate'] ?? DateTime.now().toIso8601String(),
        ),
        endDate: DateTime.parse(
          map['endDate'] ?? DateTime.now().toIso8601String(),
        ),
        format: map['format'] ?? '',
        hostId: map['hostId'] ?? 0,
        createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        scorers:
            (map['scorers'] as List<dynamic>? ?? [])
                .map((scorer) => Scorer.fromMap(scorer as Map<String, dynamic>))
                .toList(),
      );

      log("TournamentModel created successfully: ${model.name}");
      return model;
    } catch (e) {
      log("Error creating TournamentModel: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'name': name,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'format': format,
      'hostId': hostId,
      'createdAt': createdAt.toIso8601String(),
      'scorers': scorers.map((scorer) => scorer.toMap()).toList(),
    };
  }

  // Check if a user is a scorer for this tournament or is the host
  // Can check by username, email, or scorerId (uid)
  bool isUserScorer(String? identifier, {int? uid}) {
    if (identifier == null && uid == null) return false;

    // Check if user is the host (tournament creator)
    if (uid != null && uid == hostId) {
      return true;
    }

    // Check if user is in the scorers list
    return scorers.any(
      (scorer) =>
          // Check by username
          scorer.username == identifier ||
          // Check by scorerId if uid is provided
          (uid != null && scorer.scorerId == uid),
    );
  }
}

class Scorer {
  final int scorerId;
  final String? username;

  Scorer({required this.scorerId, this.username});

  factory Scorer.fromMap(Map<String, dynamic> map) {
    return Scorer(scorerId: map['scorerId'] ?? 0, username: map['username']);
  }

  Map<String, dynamic> toMap() {
    return {'scorerId': scorerId, 'username': username};
  }
}
