import 'package:cric_live/utils/import_exports.dart';

dynamic getDialogBox({
  required Function onMain,
  required String title,
  required String closeText,
  required String mainText,
}) {
  return Get.dialog(
    AlertDialog(
      title: Text(title),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text(closeText),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            onMain();
          },
          child: Text(mainText),
        ),
      ],
    ),
  );
}
