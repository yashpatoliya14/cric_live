import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerController extends GetxController {
  int teamId;
  int limit;
  List<int>? hiddenPlayerIds; // Player IDs to hide from selection
  int? matchId;
  int? inningNo;
  List<int>? selectedPlayerIds; // Previously selected player IDs to restore
  
  ChoosePlayerController({
    required this.teamId, 
    required this.limit,
    this.hiddenPlayerIds,
    this.matchId,
    this.inningNo,
    this.selectedPlayerIds,
  });
  
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
      log('🔍 Loading players for team: $teamId');
      
      // Get all players for the team
      List<PlayerModel> allPlayers = await _repo.getPlayersByTeamId(teamId) ?? [];
      log('📋 Total players from API: ${allPlayers.length}');
      
      // Use ONLY the explicitly provided hidden IDs (no automatic DB fetching)
      // This prevents the double-filtering issue where players were hidden incorrectly
      if (hiddenPlayerIds != null && hiddenPlayerIds!.isNotEmpty) {
        log('😫 Using ONLY explicit hidden IDs: $hiddenPlayerIds');
      } else {
        log('✅ No hidden IDs provided - showing all players');
      }
      
      // OLD CODE (causing issues): Automatic DB fetching disabled
      // if (matchId != null && inningNo != null) {
      //   List<int> dynamicHiddenIds = await _repo.getHiddenPlayerIds(
      //     matchId: matchId!,
      //     inningNo: inningNo!,
      //   );
      //   Set<int> allHiddenIds = {...?hiddenPlayerIds, ...dynamicHiddenIds};
      //   hiddenPlayerIds = allHiddenIds.toList();
      // }
      
      // Filter out hidden players
      if (hiddenPlayerIds != null && hiddenPlayerIds!.isNotEmpty) {
        List<PlayerModel> availablePlayers = allPlayers.where((player) => 
          !hiddenPlayerIds!.contains(player.teamPlayerId)
        ).toList();
        
        players.value = availablePlayers;
        log('✅ Available players after filtering: ${availablePlayers.length}');
        
        // Log player names for debugging
        for (var player in availablePlayers) {
          log('   - ${player.playerName} (ID: ${player.teamPlayerId})');
        }
        
        // Log hidden player info
        List<PlayerModel> hiddenPlayers = allPlayers.where((player) => 
          hiddenPlayerIds!.contains(player.teamPlayerId)
        ).toList();
        log('😫 Hidden players: ${hiddenPlayers.length}');
        for (var player in hiddenPlayers) {
          log('   - HIDDEN: ${player.playerName} (ID: ${player.teamPlayerId})');
        }
      } else {
        players.value = allPlayers;
        log('✅ No players hidden, showing all ${allPlayers.length} players');
      }
      
      filteredPlayers.value = players;
      
      // Restore previously selected players if any
      if (selectedPlayerIds != null && selectedPlayerIds!.isNotEmpty) {
        log('🔄 Restoring ${selectedPlayerIds!.length} previously selected players');
        
        List<PlayerModel> playersToRestore = [];
        for (int playerId in selectedPlayerIds!) {
          // Find the player in the available players list
          try {
            PlayerModel player = players.firstWhere(
              (p) => p.teamPlayerId == playerId,
            );
            playersToRestore.add(player);
            log('   ✅ Restored: ${player.playerName} (ID: ${player.teamPlayerId})');
          } catch (e) {
            log('   ❌ Could not restore player ID: $playerId (not found in available players)');
          }
        }
        
        selectedPlayers.value = playersToRestore;
        log('🎯 Total players restored: ${selectedPlayers.length}');
      }
    } catch (e) {
      log('❌ Error loading players: $e');
      players.value = [];
      filteredPlayers.value = [];
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
  
  /// Check if a player is hidden (out or currently playing)
  bool isPlayerHidden(PlayerModel player) {
    return hiddenPlayerIds?.contains(player.teamPlayerId) ?? false;
  }
  
  /// Get count of hidden players
  int get hiddenPlayersCount => hiddenPlayerIds?.length ?? 0;
  
  /// Get information about why players are hidden
  Future<String> getHiddenPlayersInfo() async {
    if (matchId == null || inningNo == null || hiddenPlayerIds == null) {
      return 'No players are hidden';
    }
    
    try {
      final outPlayerIds = await _repo.getOutPlayerIds(
        matchId: matchId!,
        inningNo: inningNo!,
      );
      
      final currentPlayerIds = await _repo.getCurrentlyPlayingPlayerIds(
        matchId: matchId!,
      );
      
      int outCount = outPlayerIds.length;
      int currentCount = currentPlayerIds.length;
      
      List<String> reasons = [];
      if (outCount > 0) reasons.add('$outCount out');
      if (currentCount > 0) reasons.add('$currentCount currently playing');
      
      return reasons.isNotEmpty ? 
        'Hidden: ${reasons.join(', ')}' : 
        'No players are hidden';
    } catch (e) {
      return 'Error getting player info';
    }
  }
}
