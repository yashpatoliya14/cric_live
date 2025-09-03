// import 'package:cric_live/common_widgets/custom_dialog.dart';
// import 'package:cric_live/utils/import_exports.dart';
//
// class ScoreboardController extends GetxController {
//   final int matchId;
//   ScoreboardController({required this.matchId});
//
//   ScoreboardRepo? _repo;
//
//   // State variables
//   int isNoBall = 0;
//   int isWide = 0;
//   int wideRun = 0;
//   int noBallRun = 0;
//   int inningId = 0;
//   CreateMatchModel? matchModel;
//
//   // Rx variables
//   final RxInt totalOvers = 0.obs;
//   final RxInt inningNo = 1.obs;
//   final RxString bowler = "".obs;
//   final RxInt bowlerId = 0.obs;
//   final RxString nonStrikerBatsman = "".obs;
//   final RxInt nonStrikerBatsmanId = 0.obs;
//   final RxString strikerBatsman = "".obs;
//   final RxInt strikerBatsmanId = 0.obs;
//   final RxInt totalRuns = 0.obs;
//   final RxInt wickets = 0.obs;
//   final RxInt currentRunRate = 0.obs;
//   final RxString team1 = "Team A".obs;
//   final RxString team2 = "Team B".obs;
//   final RxInt team1Id = 0.obs;
//   final RxInt team2Id = 0.obs;
//   final RxInt currentBatsmanTeamId = 0.obs;
//   final RxMap<String, double> nonStrikerBatsmanState = <String, double>{}.obs;
//   final RxMap<String, double> strikerBatsmanState = <String, double>{}.obs;
//   final RxMap<String, double> bowlerState = <String, double>{}.obs;
//   final RxDouble currentOvers = 0.1.obs;
//   final RxMap<String, dynamic> oversState = <String, dynamic>{}.obs;
//   final RxDouble CRR = 0.0.obs;
//   final RxBool isWideSelected = false.obs;
//   final RxBool isByeSelected = false.obs;
//   final RxBool isNoBallSelected = false.obs;
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = "".obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _repo = ScoreboardRepo();
//
//     _resetControllerState();
//     _initializeMatch();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     // Ensure we have the latest match data when view is ready
//     _refreshAllData();
//   }
//
//   /// Reset all controller state to default values
//   void _resetControllerState() {
//     // Reset state variables
//     isNoBall = 0;
//     isWide = 0;
//     wideRun = 0;
//     noBallRun = 0;
//     inningId = 0;
//     matchModel = null;
//
//     // Reset Rx variables
//     totalOvers.value = 0;
//     inningNo.value = 1;
//     bowler.value = "";
//     bowlerId.value = 0;
//     nonStrikerBatsman.value = "";
//     nonStrikerBatsmanId.value = 0;
//     strikerBatsman.value = "";
//     strikerBatsmanId.value = 0;
//     totalRuns.value = 0;
//     wickets.value = 0;
//     currentRunRate.value = 0;
//     team1.value = "Team A";
//     team2.value = "Team B";
//     team1Id.value = 0;
//     team2Id.value = 0;
//     currentBatsmanTeamId.value = 0;
//     nonStrikerBatsmanState.clear();
//     strikerBatsmanState.clear();
//     bowlerState.clear();
//     currentOvers.value = 0.1;
//     oversState.clear();
//     CRR.value = 0.0;
//     isWideSelected.value = false;
//     isByeSelected.value = false;
//     isNoBallSelected.value = false;
//     isLoading.value = false;
//     errorMessage.value = "";
//
//     log('ScoreboardController state reset for matchId: $matchId');
//   }
//
//   /// Initialize match with error handling
//   Future<void> _initializeMatch() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = "";
//
//       await findMatch();
//       await _refreshAllData();
//
//       log(
//         'ScoreboardController initialized successfully for matchId: $matchId',
//       );
//     } catch (e) {
//       errorMessage.value = "Failed to initialize match: ${e.toString()}";
//       log('Error initializing ScoreboardController: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Refresh all match data
//   Future<void> _refreshAllData() async {
//     await calculateRuns();
//     await calculateWicket();
//     await getCurrentOvers();
//     await calculateBowler();
//     await calculateBatsman();
//     getOversState();
//   }
//
//   // region FIND MATCH FUNCTIONS
//   Future<void> findMatch() async {
//     final foundMatch = await _repo!.findMatch(matchId);
//
//     matchModel = foundMatch;
//     log(matchModel!.toMap().toString());
//     // Extract and set match-level values
//     totalOvers.value = matchModel!.overs ?? 0;
//     inningNo.value = matchModel!.inningNo ?? 0;
//     wideRun = matchModel!.wideRun ?? 0;
//     noBallRun = matchModel!.noBallRun ?? 0;
//     currentBatsmanTeamId.value = matchModel!.currentBattingTeamId ?? 0;
//     team1Id.value = matchModel!.team1 ?? 0;
//     team2Id.value = matchModel!.team2 ?? 0;
//     isWide = matchModel!.wideRun == 0 ? 0 : 1;
//     isNoBall = matchModel!.noBallRun == 0 ? 0 : 1;
//
//     // Validate essential data
//     if (team1Id.value == 0 || team2Id.value == 0) {
//       throw Exception('Invalid team data in match');
//     }
//
//     // Fetch and set team names
//     await _setTeamName(team1Id.value, team1);
//     await _setTeamName(team2Id.value, team2);
//
//     // Fetch and set player names + IDs
//     await _setPlayerInfo(
//       playerId: matchModel!.strikerBatsmanId ?? 0,
//       nameRx: strikerBatsman,
//       idRx: strikerBatsmanId,
//     );
//
//     await _setPlayerInfo(
//       playerId: matchModel!.nonStrikerBatsmanId ?? 0,
//       nameRx: nonStrikerBatsman,
//       idRx: nonStrikerBatsmanId,
//     );
//
//     await _setPlayerInfo(
//       playerId: matchModel!.bowlerId ?? 0,
//       nameRx: bowler,
//       idRx: bowlerId,
//     );
//
//     matchModel!.status = 'live';
//     _repo!.updateMatch(matchModel!);
//   }
//
//   /// Helper: Set team name by teamId
//   Future<void> _setTeamName(int teamId, RxString teamRx) async {
//     teamRx.value = await _repo!.getTeamName(teamId);
//     teamRx.refresh();
//   }
//
//   /// Helper: Set player name + ID
//   Future<void> _setPlayerInfo({
//     required int playerId,
//     required RxString nameRx,
//     required RxInt idRx,
//   }) async {
//     idRx.value = playerId;
//     nameRx.value = await _repo!.getPlayerName(playerId);
//   }
//
//   //endregion
//
//   // region CALCULATION FUNCTIONS
//
//   /// calculate CRR
//   Future<void> calculateCRR() async {
//     CRR.value = await _repo!.calculateCRR(matchId, inningNo.value);
//   }
//
//   /// get current overs
//   Future<void> getCurrentOvers() async {
//     currentOvers.value = await _repo!.calculateCurrentOvers(
//       matchId,
//       inningNo.value,
//     );
//   }
//
//   /// get current overs state
//   void getOversState() async {
//     oversState.value = await _repo!.getCurrentOverState(
//       matchId: matchId,
//       inningNo: inningNo.value,
//       bowlerId: bowlerId.value,
//       noBallRun: noBallRun,
//       wideRun: wideRun,
//     );
//     oversState.refresh();
//   }
//
//   Future<void> calculateRuns() async {
//     totalRuns.value = await _repo!.calculateRuns(matchId, inningNo.value);
//     totalRuns.refresh();
//     getCurrentOvers();
//     calculateCRR();
//     // Check for over completion after updating scores
//     // await endOver();
//   }
//
//   Future<void> calculateWicket() async {
//     wickets.value = await _repo!.calculateWicket(matchId, inningNo.value);
//     wickets.refresh();
//   }
//
//   Future<void> calculateBatsman() async {
//     strikerBatsmanState.value = await _repo!.calculateBatsman(
//       strikerBatsmanId.toInt(),
//     );
//     nonStrikerBatsmanState.value = await _repo!.calculateBatsman(
//       nonStrikerBatsmanId.toInt(),
//     );
//   }
//
//   Future<void> calculateBowler() async {
//     bowlerState.value = await _repo!.calculateBowler(
//       bowlerId: bowlerId.toInt(),
//       matchId: matchId,
//       inningNo: inningNo.value,
//       noBallRun: noBallRun,
//       wideRun: wideRun,
//     );
//   }
//
//   //endregion
//
//   //region BUTTON HANDLERS
//
//   Future<void> onTapRun({runs}) async {
//     try {
//       if (await isInningFinished()) {
//         return;
//       }
//       if (await isOverCompleted()) {
//         changeBowler(
//           currentBatsmanTeamId.value == team1Id.value
//               ? team2Id.value
//               : team1Id.value,
//         );
//         return;
//       }
//       int? isWideLocal = null;
//       int? isNoBallLocal = null;
//       int? isByeLocal = null;
//       if (isNoBallSelected.value) {
//         runs += noBallRun;
//         isNoBallLocal = 1;
//       }
//       if (isWideSelected.value) {
//         runs += wideRun;
//         isWideLocal = 1;
//       }
//
//       if (isByeSelected.value) {
//         isByeLocal = 1;
//       }
//       ScoreboardModel data = ScoreboardModel(
//         strikerBatsmanId: strikerBatsmanId.value,
//         nonStrikerBatsmanId: nonStrikerBatsmanId.value,
//         bowlerId: bowlerId.value,
//         matchId: matchId,
//         inningNo: inningNo.value,
//         isStored: 0,
//         currentOvers: currentOvers.value,
//         runs: runs,
//         totalOvers: totalOvers.value,
//         isNoBall: isNoBallLocal,
//         isWide: isWideLocal,
//         isBye: isByeLocal,
//       );
//       _repo!.addBallEntry(data);
//       isWideSelected.value = false;
//       isNoBallSelected.value = false;
//       isByeSelected.value = false;
//
//       // Calculate in proper order to avoid conflicts
//       await calculateRuns();
//       await getCurrentOvers();
//       await calculateBatsman();
//       await calculateBowler();
//       getOversState();
//       if ([1, 3, 5].contains(runs)) {
//         onTapSwap();
//       }
//     } catch (e) {
//       log(
//         ":::: Error at add data entry from local-database in tap run :::: \n $e",
//       );
//     }
//   }
//
//   Future<void> onTapWicket({required String wicketType}) async {
//     try {
//       if (await isInningFinished()) {
//         return;
//       }
//       if (await isOverCompleted()) {
//         changeBowler(
//           currentBatsmanTeamId.value == team1Id.value
//               ? team2Id.value
//               : team1Id.value,
//         );
//         return;
//       }
//       ScoreboardModel data = ScoreboardModel(
//         strikerBatsmanId: strikerBatsmanId.value,
//         nonStrikerBatsmanId: nonStrikerBatsmanId.value,
//         bowlerId: bowlerId.value,
//         matchId: matchId,
//         inningNo: inningNo.value,
//         isStored: 0,
//         currentOvers: currentOvers.value,
//         totalOvers: totalOvers.value,
//         isWicket: 1,
//         wicketType: wicketType,
//       );
//       final dynamic result = await Get.toNamed(
//         NAV_CHOOSE_PLAYER,
//         arguments: {'teamId': matchModel!.currentBattingTeamId, 'limit': 1},
//       );
//
//       if (result != null && result is List && result.isNotEmpty) {
//         final players = result.cast<ChoosePlayerModel>();
//         strikerBatsman.value = players[0].playerName?.toString() ?? "Unknown";
//         strikerBatsmanId.value = players[0].teamPlayerId ?? 0;
//       }
//
//       _repo!.addBallEntry(data);
//
//       calculateWicket();
//       getOversState();
//     } catch (e) {
//       log(
//         ":::: Error at add data entry from local-database in tap wicket :::: \n $e",
//       );
//     }
//   }
//
//   Future<void> onTapRetire({required String wicketType}) async {
//     try {
//       if (await isInningFinished()) {
//         return;
//       }
//       if (await isOverCompleted()) {
//         changeBowler(
//           currentBatsmanTeamId.value == team1Id.value
//               ? team2Id.value
//               : team1Id.value,
//         );
//         return;
//       }
//       ScoreboardModel data = ScoreboardModel(
//         strikerBatsmanId: strikerBatsmanId.value,
//         nonStrikerBatsmanId: nonStrikerBatsmanId.value,
//         bowlerId: bowlerId.value,
//         matchId: matchId,
//         inningNo: inningNo.value,
//         isStored: 0,
//         currentOvers: currentOvers.value,
//         totalOvers: totalOvers.value,
//         isWicket: 0,
//         wicketType: wicketType,
//       );
//       final dynamic result = await Get.toNamed(
//         NAV_CHOOSE_PLAYER,
//         arguments: {'teamId': matchModel!.currentBattingTeamId, 'limit': 1},
//       );
//
//       if (result != null && result is List && result.isNotEmpty) {
//         final players = result.cast<ChoosePlayerModel>();
//         strikerBatsman.value = players[0].playerName?.toString() ?? "Unknown";
//         strikerBatsmanId.value = players[0].teamPlayerId ?? 0;
//       }
//
//       _repo!.addBallEntry(data);
//
//       calculateWicket();
//       getOversState();
//     } catch (e) {
//       log(
//         ":::: Error at add data entry from local-database in tap retire :::: \n $e",
//       );
//     }
//   }
//
//   Future<void> onTapWide() async {
//     try {
//       if (await isInningFinished()) {
//         return;
//       }
//       ScoreboardModel data = ScoreboardModel(
//         strikerBatsmanId: strikerBatsmanId.value,
//         nonStrikerBatsmanId: nonStrikerBatsmanId.value,
//         bowlerId: bowlerId.value,
//         matchId: matchId,
//         inningNo: inningNo.value,
//         isStored: 0,
//         currentOvers: currentOvers.value,
//         totalOvers: totalOvers.value,
//         isWide: isWide,
//         runs: wideRun,
//       );
//       _repo!.addBallEntry(data);
//       await calculateRuns();
//       await getCurrentOvers();
//       await calculateBowler();
//       getOversState();
//     } catch (e) {
//       log(
//         ":::: Error at add data entry from local-database in tap Wide :::: \n $e",
//       );
//     }
//   }
//
//   Future<void> onTapNoBall() async {
//     try {
//       if (await isInningFinished()) {
//         return;
//       }
//       ScoreboardModel data = ScoreboardModel(
//         strikerBatsmanId: strikerBatsmanId.value,
//         nonStrikerBatsmanId: nonStrikerBatsmanId.value,
//         matchId: matchId,
//         inningNo: inningNo.value,
//         bowlerId: bowlerId.value,
//         isStored: 0,
//         currentOvers: currentOvers.value,
//         totalOvers: totalOvers.value,
//         isNoBall: isNoBall,
//         runs: noBallRun,
//       );
//       _repo!.addBallEntry(data);
//       await calculateRuns();
//       await getCurrentOvers();
//       await calculateBowler();
//       getOversState();
//     } catch (e) {
//       log(
//         ":::: Error at add data entry from local-database in tap no ball :::: \n $e",
//       );
//     }
//   }
//
//   Future<void> undoBall() async {
//     ScoreboardModel? lastEntry = await _repo!.undoBall();
//     calculateRuns();
//     calculateBowler();
//     calculateWicket();
//     calculateBatsman();
//     getCurrentOvers();
//     getOversState();
//
//     if (lastEntry == null) {
//       return;
//     }
//
//     strikerBatsmanId.value = lastEntry.strikerBatsmanId ?? 11111;
//     nonStrikerBatsmanId.value = lastEntry.nonStrikerBatsmanId ?? 11111;
//     bowlerId.value = lastEntry.bowlerId ?? 11111;
//     strikerBatsman.value = await _repo!.getPlayerName(strikerBatsmanId.toInt());
//     nonStrikerBatsman.value = await _repo!.getPlayerName(
//       nonStrikerBatsmanId.toInt(),
//     );
//     bowler.value = await _repo!.getPlayerName(bowlerId.toInt());
//   }
//
//   void onTapSwap() async {
//     if (await isInningFinished()) {
//       return;
//     }
//     // Swap names
//     String tempName = strikerBatsman.value;
//     strikerBatsman.value = nonStrikerBatsman.value;
//     nonStrikerBatsman.value = tempName;
//
//     // Swap IDs
//     int tempId = strikerBatsmanId.value;
//     strikerBatsmanId.value = nonStrikerBatsmanId.value;
//     nonStrikerBatsmanId.value = tempId;
//
//     // Recalculate each batsman’s stats separately
//     strikerBatsmanState.value = await _repo!.calculateBatsman(
//       strikerBatsmanId.toInt(),
//     );
//     nonStrikerBatsmanState.value = await _repo!.calculateBatsman(
//       nonStrikerBatsmanId.toInt(),
//     );
//   }
//
//   //endregion
//
//   //region PLAYER SELECTION & STATE HANDLER AFTER INNING FINISH
//
//   /// is inning finished
//
//   Future<bool> isInningFinished() async {
//     bool result = await _repo!.isInningFinished(
//       matchId,
//       inningNo.value,
//       totalOvers.value,
//     );
//
//     if (result && inningNo.value == 1) {
//       getDialogBox(
//         onMain: onTapMainButton,
//         title: "Start 2nd Inning",
//         closeText: "Later",
//         mainText: "Start",
//       );
//       return result;
//     } else if (result && inningNo.value == 2) {
//       getDialogBox(
//         onMain: onTapMainButton,
//         title: "End Match",
//         closeText: "Later",
//         mainText: "End",
//       );
//       return result;
//     }
//     return result;
//   }
//
//   Future<bool> isOverCompleted() async {
//     final overState = await _repo!.getCurrentOverState(
//       matchId: matchId,
//       inningNo: inningNo.value,
//       bowlerId: bowlerId.value,
//       noBallRun: noBallRun,
//       wideRun: wideRun,
//     );
//
//     // Use ballCount instead of ballSequence.length to avoid counting wides/no-balls
//     return (overState['ballCount'] as int?) == 6 ||
//         (overState['isOverComplete'] as bool?) == true;
//   }
//
//   /// Change player
//   Future<void> changeBowler(int teamId) async {
//     final dynamic result = await Get.toNamed(
//       NAV_CHOOSE_PLAYER,
//       arguments: {'teamId': teamId, 'limit': 1},
//     );
//
//     if (result != null && result is List && result.isNotEmpty) {
//       final players = result.cast<ChoosePlayerModel>();
//       // Update bowler info
//       bowlerId.value = players[0].teamPlayerId ?? bowlerId.value;
//       bowler.value = players[0].playerName ?? bowler.value;
//
//       // Ensure all calculations are synchronized after bowler change
//       await _synchronizeAfterBowlerChange();
//     }
//     onTapSwap();
//   }
//
//   /// Synchronize all calculations after bowler change
//   Future<void> _synchronizeAfterBowlerChange() async {
//     // Calculate in proper order to avoid conflicts
//     await getCurrentOvers(); // Update main dashboard overs first
//     await calculateBowler(); // Then calculate new bowler stats
//     await calculateBatsman(); // Update batsman stats
//     getOversState(); // Finally update the over state display
//
//     // Force refresh of reactive variables
//     currentOvers.refresh();
//     bowlerState.refresh();
//     oversState.refresh();
//   }
//
//   Future<void> endMatch() async {
//     matchModel!.status = 'completed';
//     _repo!.updateMatch(matchModel!);
//     await _repo!.endMatch(matchId);
//   }
//
//   Future<void> onTapMainButton() async {
//     if (!await isInningFinished()) {
//       Get.snackbar(
//         "Please finish the match",
//         "ERROR !",
//         duration: Duration(milliseconds: 1000),
//       );
//       return;
//     }
//     if (inningNo.value == 1) {
//       Get.toNamed(NAV_SHIFT_INNING, arguments: {'matchId': matchId});
//     } else {
//       endMatch();
//       Get.delete<ScoreboardController>();
//       Get.offNamed(NAV_RESULT, arguments: {'matchId': matchId});
//     }
//   }
//
//   //endregion
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
