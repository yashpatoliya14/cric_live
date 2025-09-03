import 'package:cric_live/utils/import_exports.dart';

class GetLoader extends StatelessWidget {
  const GetLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      width: 15,
      child: CircularProgressIndicator(
        strokeWidth: 2,

        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
