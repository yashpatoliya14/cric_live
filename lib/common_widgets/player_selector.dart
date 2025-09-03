import 'package:cric_live/utils/import_exports.dart';

class PlayerSelectorTile extends StatelessWidget {
  const PlayerSelectorTile({
    required this.label,
    this.playerName,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final String? playerName;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = playerName != null;
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple is contained
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon, size: 20)),
        title: Text(label),
        subtitle: Text(
          isSelected ? playerName! : "Tap to select",
          style: TextStyle(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey.shade600,
            fontStyle: isSelected ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
