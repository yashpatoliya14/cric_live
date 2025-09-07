import 'dart:developer' as developer;

import 'package:cric_live/features/match_view/match_view_repo.dart';
import 'package:cric_live/services/polling/polling_service.dart';
import 'package:cric_live/utils/import_exports.dart';

class MatchController extends GetxController {
  MatchViewRepo _repo = MatchViewRepo();
  CompleteMatchResultModel? matchResultModel;
  PollingService pollingService = PollingService();
  int? matchId;
  bool? isLive;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initializeData();

    if (isLive != null && isLive == true) {
      pollingService.startPolling(fn: () => refreshMatchData(), seconds: 10);
    }
  }

  void _initializeData() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    _repo = MatchViewRepo();

    if (arguments != null && arguments.containsKey('matchId')) {
      currentMatchId.value = arguments['matchId'] as int;
      isLive = arguments['isLive'] as bool?;
      loadMatchResult(currentMatchId.value);
    } else {
      errorMessage.value = 'No match selected';
      isLoading.value = false;
    }
  }

  Future<void> getMatchState(matchId) async {
    try {
      _repo.getMatchState(matchId);
      update();
    } catch (e) {
      log("Get match state error");
      log(e.toString());
    }
  }

  // Observables
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CompleteMatchResultModel?> matchResult =
      Rx<CompleteMatchResultModel?>(null);
  final RxInt currentMatchId = 0.obs;

  // Getters for easy access
  TeamInningsResultModel? get team1Innings => matchResult.value?.team1Innings;
  TeamInningsResultModel? get team2Innings => matchResult.value?.team2Innings;
  List<OverSummaryModel> get team1Overs => matchResult.value?.team1Overs ?? [];
  List<OverSummaryModel> get team2Overs => matchResult.value?.team2Overs ?? [];
  String get matchTitle => matchResult.value?.matchTitle ?? 'Match Result';
  String get resultSummary => matchResult.value?.matchSummary ?? '';

  // Enhanced getters for better UI
  String get dynamicMatchTitle {
    if (matchResult.value == null) return 'Match View';

    final team1Name = getTeamName(1);
    final team2Name = getTeamName(2);
    final matchType = matchResult.value!.matchType ?? '';

    // If we have custom match title, use it
    if (matchResult.value!.matchTitle != null &&
        matchResult.value!.matchTitle!.isNotEmpty &&
        matchResult.value!.matchTitle != 'Match Result') {
      return matchResult.value!.matchTitle!;
    }

    // Create enhanced dynamic title with match type
    if (matchType.isNotEmpty) {
      return '$team1Name vs $team2Name • ${matchType.toUpperCase()}';
    }

    return '$team1Name vs $team2Name';
  }

  String get matchSubtitle {
    if (matchResult.value == null) return '';

    final status = matchResult.value!.status?.toLowerCase();
    final location = matchResult.value!.location;
    final date = matchResult.value!.date;

    List<String> subtitleParts = [];

    // Add location if available
    if (location != null && location.isNotEmpty) {
      subtitleParts.add(location);
    }

    // Add date if available
    if (date != null) {
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      subtitleParts.add(formattedDate);
    }

    // Add status
    if (status == 'live') {
      subtitleParts.add('Live Match');
    } else if (status == 'completed') {
      subtitleParts.add('Match Completed');
    } else if (status == 'scheduled') {
      subtitleParts.add('Scheduled');
    }

    return subtitleParts.join(' • ');
  }

  String get matchFormat {
    return matchResult.value?.formatDisplay ?? 'Cricket Match';
  }

  String get location {
    return matchResult.value?.location ?? '';
  }

  String get tossInfo {
    return matchResult.value?.tossSummary ?? '';
  }

  String get playerOfTheMatch {
    if (matchResult.value?.playerOfTheMatch != null) {
      return 'Player of the Match: ${matchResult.value!.playerOfTheMatch!}';
    }
    return '';
  }

  // Additional getters for enhanced UI
  String get detailedMatchInfo {
    if (matchResult.value == null) return '';

    List<String> infoParts = [];

    // Add match type and location
    if (matchResult.value!.matchType != null) {
      infoParts.add(matchResult.value!.formatDisplay);
    }

    if (matchResult.value!.location != null &&
        matchResult.value!.location!.isNotEmpty) {
      infoParts.add('at ${matchResult.value!.location!}');
    }

    return infoParts.join(' ');
  }

  String get matchResultDescription {
    return matchResult.value?.resultDescription ??
        matchResult.value?.matchSummary ??
        '';
  }

  String get detailedTossInfo {
    if (matchResult.value?.tossWinnerTeamName == null) return '';

    final tossWinner = matchResult.value!.tossWinnerTeamName!;
    final decision =
        matchResult.value!.tossDecision == 'bat'
            ? 'elected to bat first'
            : 'elected to bowl first';

    return '$tossWinner won the toss and $decision';
  }

  Map<String, String> get enhancedMatchStats {
    if (matchResult.value == null) return {};

    return {
      'Total Runs': (matchResult.value!.totalRuns ?? 0).toString(),
      'Total Wickets': (matchResult.value!.totalWickets ?? 0).toString(),
      'Total Boundaries':
          matchResult.value!.calculatedTotalBoundaries.toString(),
      'Total Sixes': (matchResult.value!.totalSixes ?? 0).toString(),
      'Highest Individual Score':
          matchResult.value!.highestIndividualScore.toString(),
      'Highest Team Score': matchResult.value!.highestTeamScore.toString(),
      'Match Type': matchResult.value!.formatDisplay,
      if (matchResult.value!.location != null)
        'location': matchResult.value!.location!,
    };
  }

  // Team specific enhanced information
  String getTeamDetailedScore(int inningNo) {
    final innings = inningNo == 1 ? team1Innings : team2Innings;
    if (innings == null) return 'No data';

    final runs = innings.totalRuns ?? 0;
    final wickets = innings.wickets ?? 0;
    final overs = innings.oversDisplay ?? '0.0';
    final target = innings.target;

    String scoreText = '$runs/$wickets ($overs overs)';

    if (target != null && target > 0) {
      final required = target - runs;
      if (required > 0) {
        scoreText += ' • Need $required runs';
      } else {
        scoreText += ' • Target achieved';
      }
    }

    return scoreText;
  }

  String getTeamRunRate(int inningNo) {
    final innings = inningNo == 1 ? team1Innings : team2Innings;
    if (innings?.runRate == null && innings?.calculatedRunRate == 0.0) {
      return '';
    }
    final rate = innings?.runRate ?? innings?.calculatedRunRate ?? 0.0;
    return 'Run Rate: ${rate.toStringAsFixed(2)}';
  }

  String getTeamRequiredRunRate(int inningNo) {
    final innings = inningNo == 1 ? team1Innings : team2Innings;
    if (innings?.requiredRunRate == null) return '';
    return 'Required RR: ${innings!.requiredRunRate!.toStringAsFixed(2)}';
  }

  String get winnerInfo {
    if (matchResult.value?.winnerTeamName != null) {
      return 'Winner: ${matchResult.value!.winnerTeamName!}';
    }
    return '';
  }

  String get matchDate {
    if (matchResult.value?.date != null) {
      final date = matchResult.value!.date!;
      // Format the date nicely
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  // Get match statistics
  Map<String, dynamic> get matchStatistics {
    if (matchResult.value == null) return {};

    return {
      'totalRuns': matchResult.value!.totalRuns ?? 0,
      'totalWickets': matchResult.value!.totalWickets ?? 0,
      'totalBoundaries': matchResult.value!.calculatedTotalBoundaries,
      'totalSixes': matchResult.value!.totalSixes ?? 0,
      'highestScore': matchResult.value!.highestIndividualScore,
      'highestTeamScore': matchResult.value!.highestTeamScore,
    };
  }

  // Check if match is a tie
  bool get isMatchTie {
    return matchResult.value?.isTie ?? false;
  }

  /// Load complete match result data
  Future<void> loadMatchResult(int matchId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      CompleteMatchResultModel? result = await _repo.getMatchState(matchId);

      if (result != null) {
        matchResult.value = result;
        matchResult.refresh();
      } else {
        errorMessage.value = 'Failed to load match result';
      }
    } catch (e) {
      errorMessage.value = 'Error loading match result: ${e.toString()}';
      log('Error in loadMatchResult: $e');
    } finally {
      isLoading.value = false;
      // Use developer.log instead of print for debugging
      developer.log('=== Loading complete, isLoading: ${isLoading.value} ===');
    }
  }

  /// Refresh match data
  Future<void> refreshMatchData() async {
    if (currentMatchId.value > 0) {
      await loadMatchResult(currentMatchId.value);
    }
  }

  /// Get batting results for a specific team
  List<PlayerBattingResultModel> getBattingResults(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.battingResults ?? [];
    } else {
      return team2Innings?.battingResults ?? [];
    }
  }

  /// Get bowling results for a specific team
  List<PlayerBowlingResultModel> getBowlingResults(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.bowlingResults ?? [];
    } else {
      return team2Innings?.bowlingResults ?? [];
    }
  }

  /// Get overs for a specific team
  List<OverSummaryModel> getTeamOvers(int inningNo) {
    if (inningNo == 1) {
      return team1Overs;
    } else {
      return team2Overs;
    }
  }

  /// Get team name by innings
  String getTeamName(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.teamName ?? 'Team 1';
    } else {
      return team2Innings?.teamName ?? 'Team 2';
    }
  }

  /// Get team score display
  String getTeamScore(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.scoreDisplay ?? '0/0';
    } else {
      return team2Innings?.scoreDisplay ?? '0/0';
    }
  }

  /// Get team overs display
  String getTeamOversDisplay(int inningNo) {
    if (inningNo == 1) {
      return team1Innings?.oversDisplay ?? '0.0';
    } else {
      return team2Innings?.oversDisplay ?? '0.0';
    }
  }

  /// Check if match has data
  bool get hasMatchData => matchResult.value != null;

  /// Check if team has data
  bool hasTeamData(int inningNo) {
    if (inningNo == 1) {
      return team1Innings != null;
    } else {
      return team2Innings != null;
    }
  }

  /// Get match status for display
  String get matchStatus {
    if (isLoading.value) return 'Loading...';
    if (errorMessage.value.isNotEmpty) return errorMessage.value;
    if (!hasMatchData) return 'No match data';
    return matchResult.value?.status ?? 'Unknown';
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();

    if (isLive != null && isLive == true) {
      pollingService.stopPolling();
    }
  }
}
