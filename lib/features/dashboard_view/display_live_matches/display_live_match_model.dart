import 'package:cric_live/features/dashboard_view/models/match_display_model.dart';

class DisplayLiveMatchModel {
  final List<MatchDisplayModel> liveMatches;
  final bool isLoading;
  final String? errorMessage;
  
  DisplayLiveMatchModel({
    this.liveMatches = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  
  DisplayLiveMatchModel copyWith({
    List<MatchDisplayModel>? liveMatches,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DisplayLiveMatchModel(
      liveMatches: liveMatches ?? this.liveMatches,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
