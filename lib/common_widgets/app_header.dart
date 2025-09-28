import 'package:cric_live/utils/import_exports.dart';

class CommonAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const CommonAppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onLeadingPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.flexibleSpace,
    this.bottom,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.deepOrange,
      foregroundColor: foregroundColor ?? Colors.white,
      title: subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: GoogleFonts.nunito(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: (foregroundColor ?? Colors.white).withValues(alpha: 0.8),
                    ),
                  ),
              ],
            )
          : Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
      centerTitle: centerTitle,
      elevation: elevation,
      leading: _buildLeading(),
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12.r),
        ),
      ),
    );
  }

  Widget? _buildLeading() {
    // If a custom leading icon is provided, use it
    if (leadingIcon != null) {
      return IconButton(
        onPressed: onLeadingPressed ?? () => Get.back(),
        icon: Icon(leadingIcon),
        tooltip: leadingIcon == Icons.arrow_back ? 'Back' : null,
      );
    }
    
    // If showBackButton is true and we can go back, show back button
    if (showBackButton && Get.context != null && Navigator.of(Get.context!).canPop()) {
      return IconButton(
        onPressed: onLeadingPressed ?? () => Get.back(),
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

// Alternative app header with gradient background
class GradientAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final List<Color>? gradientColors;
  final bool centerTitle;
  final double elevation;
  final bool showBackButton;

  const GradientAppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onLeadingPressed,
    this.actions,
    this.gradientColors,
    this.centerTitle = true,
    this.elevation = 0,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [Colors.deepOrange, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12.r),
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: subtitle != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              )
            : Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
        centerTitle: centerTitle,
        elevation: 0,
        leading: _buildGradientLeading(),
        actions: actions,
      ),
    );
  }

  Widget? _buildGradientLeading() {
    // If a custom leading icon is provided, use it
    if (leadingIcon != null) {
      return IconButton(
        onPressed: onLeadingPressed ?? () => Get.back(),
        icon: Icon(leadingIcon),
        tooltip: leadingIcon == Icons.arrow_back ? 'Back' : null,
      );
    }
    
    // If showBackButton is true and we can go back, show back button
    if (showBackButton && Get.context != null && Navigator.of(Get.context!).canPop()) {
      return IconButton(
        onPressed: onLeadingPressed ?? () => Get.back(),
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
