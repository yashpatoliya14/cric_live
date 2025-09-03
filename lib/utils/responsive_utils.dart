import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double _baseWidth = 375.0; // Base design width (iPhone X)
  static const double _baseHeight = 812.0; // Base design height (iPhone X)
  
  // Screen size categories
  static const double smallScreenWidth = 360.0;
  static const double mediumScreenWidth = 400.0;
  static const double largeScreenWidth = 480.0;
  
  /// Get responsive width
  static double width(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (size / _baseWidth) * screenWidth;
  }
  
  /// Get responsive height  
  static double height(BuildContext context, double size) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (size / _baseHeight) * screenHeight;
  }
  
  /// Get responsive font size
  static double fontSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / _baseWidth;
    
    // Clamp the scale to prevent extremely large or small fonts
    final clampedScale = scale.clamp(0.8, 1.3);
    return size * clampedScale;
  }
  
  /// Get responsive spacing
  static double spacing(BuildContext context, double size) {
    return width(context, size);
  }
  
  /// Get responsive border radius
  static double radius(BuildContext context, double size) {
    return width(context, size);
  }
  
  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < smallScreenWidth;
  }
  
  /// Check if screen is medium
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallScreenWidth && width < largeScreenWidth;
  }
  
  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeScreenWidth;
  }
  
  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < smallScreenWidth) return ScreenSize.small;
    if (width < largeScreenWidth) return ScreenSize.medium;
    return ScreenSize.large;
  }
  
  /// Get adaptive padding based on screen size
  static EdgeInsets adaptivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return EdgeInsets.all(spacing(context, 8));
    } else if (isMediumScreen(context)) {
      return EdgeInsets.all(spacing(context, 12));
    }
    return EdgeInsets.all(spacing(context, 16));
  }
  
  /// Get adaptive margin based on screen size
  static EdgeInsets adaptiveMargin(BuildContext context) {
    if (isSmallScreen(context)) {
      return EdgeInsets.all(spacing(context, 4));
    } else if (isMediumScreen(context)) {
      return EdgeInsets.all(spacing(context, 6));
    }
    return EdgeInsets.all(spacing(context, 8));
  }
}

enum ScreenSize { small, medium, large }

/// Extension for easy access to responsive utilities
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);
  
  double rWidth(double size) => ResponsiveUtils.width(this, size);
  double rHeight(double size) => ResponsiveUtils.height(this, size);
  double rFont(double size) => ResponsiveUtils.fontSize(this, size);
  double rSpacing(double size) => ResponsiveUtils.spacing(this, size);
  double rRadius(double size) => ResponsiveUtils.radius(this, size);
  
  EdgeInsets get adaptivePadding => ResponsiveUtils.adaptivePadding(this);
  EdgeInsets get adaptiveMargin => ResponsiveUtils.adaptiveMargin(this);
}
