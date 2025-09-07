import 'package:cric_live/features/choose_player_view/choose_player_model.dart';

abstract class Ichoose_player {
  Future<List<PlayerModel>?> getPlayersByTeamId(int teamId);
}
