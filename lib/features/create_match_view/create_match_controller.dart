import 'package:cric_live/utils/import_exports.dart';

class CreateMatchController extends GetxController {
  RxString tossWinnerTeam = TEAM_A.obs;
  RxString batOrBowl = BAT.obs;
  RxBool isNoBall = false.obs;
  RxBool isWide = false.obs;
  RxInt overs = 0.obs;
  RxInt noBallRun = 1.obs;
  RxInt wideRun = 1.obs;

  TextEditingController controllerOvers = TextEditingController();
  TextEditingController controllerNoBallRun = TextEditingController();
  TextEditingController controllerWideRun = TextEditingController();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  onTossWinnerTeamChanged(value) {
    if (value != null) {
      tossWinnerTeam.value = value;
    }
  }

  onbatOrBowlChanged(value) {
    if (value != null) {
      batOrBowl.value = value;
    }
  }

  onNoBallChanged(value) {
    if (value != null) {
      isNoBall.value = value;
    }
  }

  onWideChanged(value) {
    if (value != null) {
      isWide.value = value;
    }
  }
}
