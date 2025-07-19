import 'package:cric_live/utils/import_exports.dart';

class MatchTournamentCard extends StatelessWidget {
  final Icon icon;
  final String title; // teams
  final String subTitle; // status
  final Widget trailing; // status
  const MatchTournamentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: icon,
        title: Text(title),
        trailing: trailing,
        subtitle: Text(subTitle),
      ),
    );
  }
}
