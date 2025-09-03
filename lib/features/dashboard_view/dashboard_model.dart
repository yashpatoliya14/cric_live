import 'package:cric_live/features/dashboard_view/models/match_display_model.dart';

class DashboardModel {
  final List<MatchDisplayModel> liveMatches;
  final List<MatchDisplayModel> historyMatches;
  final bool isLoadingLive;
  final bool isLoadingHistory;
  final String? liveMatchesError;
  final String? historyMatchesError;

  DashboardModel({
    this.liveMatches = const [],
    this.historyMatches = const [],
    this.isLoadingLive = false,
    this.isLoadingHistory = false,
    this.liveMatchesError,
    this.historyMatchesError,
  });

  DashboardModel copyWith({
    List<MatchDisplayModel>? liveMatches,
    List<MatchDisplayModel>? historyMatches,
    bool? isLoadingLive,
    bool? isLoadingHistory,
    String? liveMatchesError,
    String? historyMatchesError,
  }) {
    return DashboardModel(
      liveMatches: liveMatches ?? this.liveMatches,
      historyMatches: historyMatches ?? this.historyMatches,
      isLoadingLive: isLoadingLive ?? this.isLoadingLive,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      liveMatchesError: liveMatchesError ?? this.liveMatchesError,
      historyMatchesError: historyMatchesError ?? this.historyMatchesError,
    );
  }

  bool get hasLiveMatches => liveMatches.isNotEmpty;
  bool get hasHistoryMatches => historyMatches.isNotEmpty;
  bool get hasLiveError => liveMatchesError != null;
  bool get hasHistoryError => historyMatchesError != null;
}
