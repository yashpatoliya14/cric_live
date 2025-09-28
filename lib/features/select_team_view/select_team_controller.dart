import 'package:cric_live/utils/import_exports.dart';

class SelectTeamController extends GetxController {
  final SelectTeamRepo _repo = SelectTeamRepo();

  //variables
  bool wantToStore = false;
  int? tournamentId;
  RxList<SelectTeamModel> teams = <SelectTeamModel>[].obs;

  //controllers
  TextEditingController controllerSearch = TextEditingController();

  @override
  void onInit() {
    wantToStore = (Get.arguments as Map?)?["wantToStore"] as bool? ?? false;
    tournamentId = (Get.arguments as Map?)?["tournamentId"] as int? ?? null;

    getAllTeams();

    // TODO: implement onInit
    super.onInit();
  }

  void getAllTeams() async {
    teams.value = await _repo.getAllTeams(
      wantToStore: wantToStore,
      tournamentId: tournamentId,
    );
    teams.refresh();
  }

  Future<void> deleteTeam(SelectTeamModel team) async {
    try {
      if (team.teamId == null) {
        Get.snackbar(
          "Error",
          "Cannot delete team: Invalid team ID",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Call repository to delete team
      bool success = await _repo.deleteTeam(team.teamId!);
      
      if (success) {
        // Remove team from local list
        teams.removeWhere((t) => t.teamId == team.teamId);
        teams.refresh();
        
        Get.snackbar(
          "Success",
          "Team '${team.teamName}' deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete team: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
