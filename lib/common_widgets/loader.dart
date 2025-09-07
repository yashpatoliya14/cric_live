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

/// Full screen loader component extracted from choose player view
/// Use this for large screen loading states across the project
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? loaderColor;
  final double? strokeWidth;
  final double? size;
  final EdgeInsets? padding;

  const FullScreenLoader({
    super.key,
    this.message,
    this.loaderColor,
    this.strokeWidth,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLoaderColor = loaderColor ?? theme.primaryColor;
    final effectiveMessage = message ?? 'Loading...';

    return Center(
      child: Container(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveLoaderColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: effectiveLoaderColor,
                strokeWidth: strokeWidth ?? 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              effectiveMessage,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple center loading widget for basic loading states
class CenterLoader extends StatelessWidget {
  final String? message;
  final Color? color;

  const CenterLoader({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ],
      ),
    );
  }
}
