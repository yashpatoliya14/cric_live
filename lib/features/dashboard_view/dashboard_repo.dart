// import 'package:cric_live/utils/import_exports.dart';
//
// class DashboardRepo {
//   final AuthService _authService = AuthService();
//   final ApiServices _apiServices = ApiServices();
//
//   /// Fetch all user's matches based on uid
//   Future<List<CreateMatchModel>?> getUsersMatches() async {
//     try {
//       TokenModel? model = _authService.fetchInfoFromToken();
//       if (model == null) {
//         throw Exception("User not authenticated");
//       }
//       int uid = model.uid!;
//
//       Map<String, dynamic> data = await _apiServices.get(
//         "/CL_Matches/GetMatchesByUser/$uid",
//       );
//
//       List<CreateMatchModel> matches = [];
//
//       // Check if matches data exists and is a list
//       if (data.containsKey("matches") && data["matches"] is List) {
//         List<dynamic> rawMatches = data["matches"] as List<dynamic>;
//
//         for (dynamic matchData in rawMatches) {
//           if (matchData is Map<String, dynamic>) {
//             try {
//               CreateMatchModel model = CreateMatchModel.fromMap(matchData);
//               matches.add(model);
//             } catch (e) {
//               log('Error creating match model: ${e.toString()}');
//               // Continue with other matches instead of failing completely
//             }
//           }
//         }
//       } else {
//         log('No matches found in response or invalid format');
//       }
//
//       // Log matches info safely
//       if (matches.isNotEmpty) {
//         log("First match data: ${matches[0].toMap()}");
//         log("Total matches found: ${matches.length}");
//       } else {
//         log("No matches found for user");
//       }
//
//       return matches;
//     } catch (e) {
//       log('getUsersMatches error: ${e.toString()}');
//       // Handle specific error cases
//       if (e.toString().contains("Not Found")) {
//         log("⚠️ Match endpoints not implemented on backend server");
//         log("💡 Returning empty list for now");
//         return <CreateMatchModel>[];
//       } else if (e.toString().contains("Server Error")) {
//         throw Exception("Server Side Error In fetch matches by user");
//       }
//       rethrow;
//     }
//   }
//
//   /// Fetch live matches
//   Future<List<CreateMatchModel>?> getLiveMatches() async {
//     try {
//       ApiServices apiServices = ApiServices();
//       Map<String, dynamic> data = await apiServices.get(
//         "/CL_Matches/GetLiveMatch",
//       );
//
//       List<CreateMatchModel> matches = [];
//
//       // Check if matches data exists and is a list
//       if (data.containsKey("matches") && data["matches"] is List) {
//         List<dynamic> rawMatches = data["matches"] as List<dynamic>;
//
//         for (dynamic matchData in rawMatches) {
//           if (matchData is Map<String, dynamic>) {
//             try {
//               CreateMatchModel model = CreateMatchModel.fromMap(matchData);
//               matches.add(model);
//             } catch (e) {
//               log('Error creating match model: ${e.toString()}');
//             }
//           }
//         }
//       } else {
//         log('No matches found in response or invalid format');
//       }
//
//       return matches;
//     } catch (e) {
//       log('getLiveMatches error: ${e.toString()}');
//       if (e.toString().contains("Server Error")) {
//         throw Exception("Server Side Error In fetch live matches");
//       }
//       rethrow;
//     }
//   }
//
// }
