import 'package:cric_live/common_widgets/match_tournament_card.dart';
import 'package:cric_live/utils/import_exports.dart';

class TournamentView extends StatelessWidget {
  const TournamentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return MatchTournamentCard(
            icon: Icon(Icons.group),
            title: "demo",
            subTitle: "live",
            trailing: Text("100/2"),
          );
        },
        itemCount: 5,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(NAV_CREATE_TOURNAMENT);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
