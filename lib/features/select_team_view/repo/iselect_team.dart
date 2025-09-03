import 'package:cric_live/utils/import_exports.dart';

abstract class IselectTeam {
  Future<List<SelectTeamModel>> getAllTeams({required bool wantToStore});
  Future<List<SelectTeamModel>> fetchTeams();
}
