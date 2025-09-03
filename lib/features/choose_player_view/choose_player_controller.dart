import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerController extends GetxController {
  int teamId;
  int limit;
  ChoosePlayerController({required this.teamId, required this.limit});
  ChoosePlayerRepo _repo = ChoosePlayerRepo();

  // Search controller
  final TextEditingController searchController = TextEditingController();

  //rx list
  RxList<ChoosePlayerModel> players = <ChoosePlayerModel>[].obs;
  RxList<ChoosePlayerModel> filteredPlayers = <ChoosePlayerModel>[].obs;
  RxList<ChoosePlayerModel> selectedPlayers = <ChoosePlayerModel>[].obs;

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

  Future<void> getPlayers() async {
    isLoading.value = true;
    try {
      players.value = await _repo.getPlayersByTeamId(teamId) ?? [];
      filteredPlayers.value = players;
    } catch (e) {
      // Handle error
      players.clear();
      filteredPlayers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void filterPlayers() {
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

  onChangedCheckBox(ChoosePlayerModel value) {
    final alreadySelected = selectedPlayers.any(
      (p) => p.playerId == value.playerId,
    );
    if (alreadySelected) {
      selectedPlayers.removeWhere((p) => p.playerId == value.playerId);
    } else {
      if (selectedPlayers.length >= limit) {
        return;
      }
      selectedPlayers.add(value);
    }

    selectedPlayers.refresh();
  }

  isSelected(ChoosePlayerModel value) {
    return selectedPlayers.any((p) => p.playerId == value.playerId);
  }
}
