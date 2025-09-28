// lib/features/create_team_view/create_team_controller.dart

import 'package:cric_live/utils/import_exports.dart';

class CreateTeamController extends GetxController {
  final CreateTeamRepo _repo = CreateTeamRepo();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPlayerName = TextEditingController();

  // Observable list for players selected for the team
  RxList<PlayerModel> selectedPlayers = <PlayerModel>[].obs;
  RxBool isLoading = false.obs;

  // Adds a player to the selected list
  void addPlayer() {
    if (controllerPlayerName.text.trim().isEmpty) {
      Get.snackbar(
        "Invalid Player Name",
        "Please enter a player name.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final playerName = controllerPlayerName.text.trim();

    // Check if player already exists
    if (selectedPlayers.any(
      (player) => player.playerName?.toLowerCase() == playerName.toLowerCase(),
    )) {
      Get.snackbar(
        "Duplicate Player",
        "This player is already added to the team.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    selectedPlayers.add(PlayerModel(playerName: playerName));
    controllerPlayerName.clear();
  }

  // Removes a player from the selected list
  void removePlayer(PlayerModel player) {
    selectedPlayers.removeWhere(
      (element) => element.playerName == player.playerName,
    );
  }

  // Validates input and calls the repository to create the team
  Future<int?> createTeam() async {
    log("CreateTeam: Starting team creation process");
    // Check for a minimum of 2 players
    if (selectedPlayers.length < 2) {
      Get.snackbar(
        "Invalid Team Size",
        "You must select at least 2 players to create a team.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
    if (controllerName.text.trim().isEmpty) {
      Get.snackbar(
        "Invalid Team Name",
        "Please enter a name for your team.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Check internet connection first
    bool hasInternet = await InternetRequiredService.checkForTeamCreation();
    if (!hasInternet) {
      return null; // User cancelled or still no internet
    }

    isLoading.value = true;
    try {
      int? teamId = await _repo.createTeam(
        selectedPlayers,
        controllerName.text.trim(),
      );
      isLoading.value = false;

      if (teamId == null) {
        Get.snackbar(
          "Error",
          "Failed to create team. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      final result = {"teamId": teamId, "teamName": controllerName.text.trim()};

      // Return to previous screen with team data
      Get.back(result: result);
      return teamId;
    } catch (e) {
      isLoading.value = false;
      log("Create team error: $e");
      Get.snackbar(
        "Error",
        "Failed to create team: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  @override
  void onClose() {
    controllerName.dispose();
    controllerPlayerName.dispose();
    super.onClose();
  }
}
