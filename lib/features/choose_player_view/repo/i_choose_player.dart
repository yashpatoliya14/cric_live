import 'package:cric_live/features/choose_player_view/choose_player_model.dart';

abstract class IChoosePlayer {
  Future<List<PlayerModel>?> getPlayersByTeamId(int teamId);
}
