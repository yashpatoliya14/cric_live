import 'package:cric_live/utils/import_exports.dart';

dynamic getSnackBar({required String title, required String message}) {
  return Get.snackbar(title, message);
}
