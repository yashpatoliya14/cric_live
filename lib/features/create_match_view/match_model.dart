import 'dart:convert';

import 'package:cric_live/features/result_view/models/complete_match_result_model.dart';

class MatchModel {
  int? id;
  int? matchIdOnline;
  int? team1;
  int? team2;
  int? uid;
  DateTime? matchDate;
  int? inningNo;
  int? overs;
  String? status; // 'live', 'completed', 'scheduled'
  int? tossWon;
  String? decision; // default: 'remain'
  int? tournamentId;
  int? wideRun; // default: 0
  int? noBallRun; // default: 0
  int? strikerBatsmanId;
  int? nonStrikerBatsmanId;
  int? bowlerId;
  int? currentBattingTeamId;
  CompleteMatchResultModel? matchState;
  String? team1Name;
  String? team2Name;
  String? result; // Match result description
  int? winnerTeamId; // ID of the winning team
  int? firstInningScore; // First inning total score
  MatchModel({
    this.id,
    this.matchIdOnline,
    this.team1Name,
    this.team2Name,
    this.team1,
    this.team2,
    this.matchDate,
    this.inningNo,
    this.overs,
    this.status,
    this.tossWon,
    this.decision = 'remain',
    this.tournamentId,
    this.wideRun = 0,
    this.noBallRun = 0,
    this.strikerBatsmanId,
    this.nonStrikerBatsmanId,
    this.bowlerId,
    this.currentBattingTeamId,
    this.matchState,
    this.uid,
    this.result,
    this.winnerTeamId,
    this.firstInningScore,
  });

  /// Convert object to map for DB insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchIdOnline': matchIdOnline,
      'team1': team1,
      'team2': team2,
      'uid': uid,
      'matchDate': matchDate?.toIso8601String(),
      'inningNo': inningNo,
      'overs': overs,
      'status': status,
      'tossWon': tossWon,
      'decision': decision ?? 'remain',
      'tournamentId': tournamentId,
      'wideRun': wideRun ?? 0,
      'noBallRun': noBallRun ?? 0,
      'strikerBatsmanId': strikerBatsmanId,
      'nonStrikerBatsmanId': nonStrikerBatsmanId,
      'bowlerId': bowlerId,
      'currentBattingTeamId': currentBattingTeamId,
      'matchState':
          matchState != null ? jsonEncode(matchState!.toJson()) : null,
      'result': result,
      'winnerTeamId': winnerTeamId,
      'firstInningScore': firstInningScore,
      // 'team1Name': team1Name,
      // 'team2Name': team2Name,
    };
  }

  /// Create object from map (e.g. from DB)
  factory MatchModel.fromMap(Map<String, dynamic> map) {
    // Helper function to safely parse integer values
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return MatchModel(
      id: safeParseInt(map['id']),
      team1: safeParseInt(map['team1']),
      team2: safeParseInt(map['team2']),
      matchIdOnline: safeParseInt(map['matchIdOnline']),
      matchDate:
          map['matchDate'] == null
              ? null
              : DateTime.parse(map['matchDate'] as String),
      inningNo: safeParseInt(map['inningNo']),
      overs: safeParseInt(map['overs']),
      status: map['status'] as String?,
      tossWon: safeParseInt(map['tossWon']),
      decision: map['decision'] as String?,
      tournamentId: safeParseInt(map['tournamentId']),
      wideRun: safeParseInt(map['wideRun']) ?? 0,
      noBallRun: safeParseInt(map['noBallRun']) ?? 0,
      strikerBatsmanId: safeParseInt(map['strikerBatsmanId']),
      nonStrikerBatsmanId: safeParseInt(map['nonStrikerBatsmanId']),
      bowlerId: safeParseInt(map['bowlerId']),
      currentBattingTeamId: safeParseInt(map['currentBattingTeamId']),
      matchState:
          (map["matchState"] != null && map["matchState"].toString().isNotEmpty)
              ? CompleteMatchResultModel().fromJson(
                jsonDecode(map["matchState"]),
              )
              : null,

      uid: safeParseInt(map['uid']),
      team1Name: map['team1Name'] as String?,
      team2Name: map['team2Name'] as String?,
      result: map['result'] as String?,
      winnerTeamId: safeParseInt(map['winnerTeamId']),
      firstInningScore: safeParseInt(map['firstInningScore']),
    );
  }
}
