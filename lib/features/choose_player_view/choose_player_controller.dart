import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerController extends GetxController {
  int teamId;
  int limit;
  ChoosePlayerController({required this.teamId, required this.limit});
  final ChoosePlayerRepo _repo = ChoosePlayerRepo();

  // Search controller
  final TextEditingController searchController = TextEditingController();

  //rx list
  RxList<PlayerModel> players = <PlayerModel>[].obs;
  RxList<PlayerModel> filteredPlayers = <PlayerModel>[].obs;
  RxList<PlayerModel> selectedPlayers = <PlayerModel>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search query
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getPlayers();
    // Listen to search query changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterPlayers();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  getPlayers() async {
    isLoading.value = true;
    try {
      players.value = await _repo.getPlayersByTeamId(teamId) ?? [];
      filteredPlayers.value = players;
    } finally {
      isLoading.value = false;
    }
  }

  filterPlayers() {
    if (searchQuery.value.isEmpty) {
      filteredPlayers.value = players;
    } else {
      filteredPlayers.value =
          players
              .where(
                (player) =>
                    player.playerName?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();
    }
  }

  void clearSelection() {
    selectedPlayers.clear();
  }

  onChangedCheckBox(PlayerModel value) {
    if (isSelected(value)) {
      selectedPlayers.removeWhere((p) => p.teamPlayerId == value.teamPlayerId);
    } else {
      if (selectedPlayers.length >= limit) {
        return;
      }
      selectedPlayers.add(value);
    }

    selectedPlayers.refresh();
  }

  isSelected(PlayerModel value) {
    return selectedPlayers.any((p) => p.teamPlayerId == value.teamPlayerId);
  }
}
