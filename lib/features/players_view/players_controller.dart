import 'package:cric_live/utils/import_exports.dart';

class PlayersController extends GetxController {
  int teamId;
  bool isView;
  PlayersController({required this.teamId, required this.isView});
  final PlayersRepo _repo = PlayersRepo();

  //variables
  RxList<PlayersModel> players = <PlayersModel>[].obs;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getPlayers(teamId);
  }

  Future<void> getPlayers(id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<PlayersModel>? fetchedPlayers = await _repo.getPlayers(id);
      players.value = fetchedPlayers ?? [];

      if (players.isEmpty) {
        errorMessage.value = 'No players found for this team';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load players: ${e.toString()}';
      log('Error loading players: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPlayers() async {
    await getPlayers(teamId);
  }

  // Get player statistics
  int get totalPlayers => players.length;

  bool get hasMinimumPlayers => players.length >= 11;

  String get teamStatus {
    if (players.length >= 15) {
      return 'Full Squad';
    } else if (players.length >= 11) {
      return 'Playing XI Ready';
    } else {
      return 'Needs ${11 - players.length} more players';
    }
  }
}
