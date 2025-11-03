import 'package:cric_live/utils/import_exports.dart';

/// Model to encapsulate player information and state
class PlayerState {
  final RxString name;
  final RxInt id;
  final RxMap<String, double> stats;

  PlayerState({
    String? initialName,
    int? initialId,
    Map<String, double>? initialStats,
  })  : name = (initialName ?? '').obs,
        id = (initialId ?? 0).obs,
        stats = (initialStats ?? <String, double>{}).obs;

  void update({String? newName, int? newId, Map<String, double>? newStats}) {
    if (newName != null) name.value = newName;
    if (newId != null) id.value = newId;
    if (newStats != null) stats.value = newStats;
  }

  void refresh() {
    name.refresh();
    id.refresh();
    stats.refresh();
  }

  void clear() {
    name.value = '';
    id.value = 0;
    stats.clear();
  }
}

/// Helper class to manage multiple player states
class PlayersStateManager {
  final PlayerState striker;
  final PlayerState nonStriker;
  final PlayerState bowler;

  PlayersStateManager()
      : striker = PlayerState(),
        nonStriker = PlayerState(),
        bowler = PlayerState();

  /// Swap striker and non-striker
  void swapBatsmen() {
    final tempName = striker.name.value;
    striker.name.value = nonStriker.name.value;
    nonStriker.name.value = tempName;

    final tempId = striker.id.value;
    striker.id.value = nonStriker.id.value;
    nonStriker.id.value = tempId;

    final tempStats = Map<String, double>.from(striker.stats);
    striker.stats.value = Map<String, double>.from(nonStriker.stats);
    nonStriker.stats.value = tempStats;
  }

  /// Refresh all player UI elements
  void refreshAll() {
    striker.refresh();
    nonStriker.refresh();
    bowler.refresh();
  }

  /// Clear all player data
  void clearAll() {
    striker.clear();
    nonStriker.clear();
    bowler.clear();
  }
}
