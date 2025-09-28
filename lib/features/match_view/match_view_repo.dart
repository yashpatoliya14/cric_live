import 'package:cric_live/utils/import_exports.dart';

class MatchViewRepo {
  final ResultRepo _resultRepo = ResultRepo();
  
  Future<CompleteMatchResultModel?> getMatchState(int matchId) async {
    try {
      ApiServices apiServices = ApiServices();
      Map<String, dynamic> data = await apiServices.get(
        "/CL_Matches/GetMatchById/$matchId",
      );
      log('📊 API Response for match $matchId: $data');
      
      // Get match basic info
      var matchInfo = data["match"];
      String? matchStatus = matchInfo?["status"];
      
      log('🔍 Match $matchId status: $matchStatus');
      
      // Check if matchState exists and is not empty
      var matchStateRaw = matchInfo?["matchState"];
      
      if (matchStateRaw != null && matchStateRaw.toString().trim().isNotEmpty) {
        // Live/ongoing matches: Use API matchState
        log('ℹ️ Using API matchState for match $matchId');
        
        Map<String, dynamic> matchStateJson;
        try {
          if (matchStateRaw is String) {
            matchStateJson = jsonDecode(matchStateRaw);
          } else {
            matchStateJson = matchStateRaw as Map<String, dynamic>;
          }
        } catch (e) {
          throw Exception("Invalid JSON format in matchState: $e");
        }
        
        CompleteMatchResultModel matchState = CompleteMatchResultModel().fromMap(
          matchStateJson,
        );
        return matchState;
      } else {
        // Completed matches: Calculate from database
        log('📋 Calculating match state from database for completed match $matchId');
        
        // Use ResultRepo to calculate complete match state from database
        CompleteMatchResultModel? calculatedState = await _resultRepo.getCompleteMatchResult(matchId);
        
        if (calculatedState != null) {
          log('✅ Successfully calculated match state for match $matchId');
          return calculatedState;
        } else {
          log('⚠️ Failed to calculate match state for match $matchId');
          throw Exception("Unable to calculate match state from database");
        }
      }
    } catch (e) {
      log('❌ Error in getMatchState for match $matchId: $e');
      if (e.toString().contains("Server Error")) {
        throw Exception("Server error!");
      }
      rethrow;
    }
  }
}
