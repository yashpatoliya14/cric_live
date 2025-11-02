import 'package:cric_live/utils/import_exports.dart';

/// Unified app dialog
Future<T?> showAppDialog<T>({
  required String title,
  Widget? titleWidget,
  String? contentText,
  Widget? content,
  List<Widget>? actions,
  String cancelText = 'Cancel',
  String confirmText = 'OK',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
}) {
  return Get.dialog<T>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: titleWidget ?? Text(title),
      content: content ??
          (contentText != null ? Text(contentText) : const SizedBox.shrink()),
      actions: actions ?? [
        if (cancelText.isNotEmpty)
          TextButton(
            onPressed: () {
              Get.back<T>();
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
        if (confirmText.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              Get.back<T>();
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
      ],
    ),
    barrierDismissible: barrierDismissible,
  );
}

// Backward-compatible helper
// Future<dynamic> getDialogBox({
//   required Function onMain,
//   required String title,
//   required String closeText,
//   required String mainText,
// }) {
//   return showAppDialog(
//     title: title,
//     cancelText: closeText,
//     confirmText: mainText,
//     onConfirm: () => onMain(),
//   );
// }
