import 'package:cric_live/utils/import_exports.dart';

class SelectTeamController extends GetxController {
  SelectTeamRepo _repo = SelectTeamRepo();

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
}
