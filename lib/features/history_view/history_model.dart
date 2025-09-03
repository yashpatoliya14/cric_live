import 'package:cric_live/features/dashboard_view/models/match_display_model.dart';

class HistoryModel {
  final List<MatchDisplayModel> historyMatches;
  final bool isLoading;
  final String? errorMessage;
  
  HistoryModel({
    this.historyMatches = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  
  HistoryModel copyWith({
    List<MatchDisplayModel>? historyMatches,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HistoryModel(
      historyMatches: historyMatches ?? this.historyMatches,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
