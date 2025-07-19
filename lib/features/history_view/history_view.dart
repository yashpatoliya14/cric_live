import 'package:cric_live/common_widgets/match_tournament_card.dart';
import 'package:cric_live/utils/import_exports.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return MatchTournamentCard(
            icon: Icon(Icons.person),
            title: "Match 1",
            subTitle: "Completed",
            trailing: Text("team 1 won"),
          );
        },
        itemCount: 10,
      ),
    );
  }
}
