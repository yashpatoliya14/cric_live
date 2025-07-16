import 'package:cric_live/utils/import_exports.dart';

class CreateTeamController extends GetxController {
  List<String> teams = ["Team A", "Team B"];
  late RxString tossWinnerTeam;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    tossWinnerTeam = teams[0].obs;
  }

  onTossWinnerTeamChanged(value) {
    if (value != null) {
      tossWinnerTeam.value = value;
      tossWinnerTeam.refresh();
    }
  }
}
