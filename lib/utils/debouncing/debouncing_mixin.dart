import 'dart:async';
import 'package:flutter/material.dart';

/// A mixin that provides debouncing functionality to prevent rapid button taps
/// Usage: Include this mixin in your widget class and use debounce() method
mixin DebouncingMixin {
  final Map<String, Timer?> _debounceTimers = {};
  
  /// Debounces a function call with a specified delay
  /// [key] - unique identifier for this specific debounce operation
  /// [callback] - function to execute after debounce delay
  /// [delay] - delay duration (default: 500ms)
  void debounceTap(String key, VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    // Cancel any existing timer for this key
    _debounceTimers[key]?.cancel();
    
    // Create new timer
    _debounceTimers[key] = Timer(delay, () {
      callback();
      _debounceTimers[key] = null; // Clear the timer reference
    });
  }
  
  /// Cancels a specific debounce timer
  void cancelDebounce(String key) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = null;
  }
  
  /// Cancels all active debounce timers
  void cancelAllDebounces() {
    for (var timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();
  }
  
  /// Checks if a debounce timer is currently active for a specific key
  bool isDebouncing(String key) {
    return _debounceTimers[key]?.isActive == true;
  }
  
  /// Gets the remaining time for a specific debounce timer
  Duration? getRemainingDebounceTime(String key) {
    final timer = _debounceTimers[key];
    if (timer?.isActive == true) {
      // Note: Timer doesn't provide remaining time directly
      // This is a limitation of Dart's Timer class
      return null;
    }
    return null;
  }
  
  /// Clean up method - should be called when the widget is disposed
  void disposeDebouncing() {
    cancelAllDebounces();
  }
}

/// A utility class for standalone debouncing without using mixin
class DebouncingUtil {
  static final Map<String, Timer?> _globalTimers = {};
  
  /// Static debounce method for use without mixin
  static void debounceTap(String key, VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _globalTimers[key]?.cancel();
    _globalTimers[key] = Timer(delay, () {
      callback();
      _globalTimers[key] = null;
    });
  }
  
  /// Cancel specific global debounce
  static void cancel(String key) {
    _globalTimers[key]?.cancel();
    _globalTimers[key] = null;
  }
  
  /// Cancel all global debounces
  static void cancelAll() {
    for (var timer in _globalTimers.values) {
      timer?.cancel();
    }
    _globalTimers.clear();
  }
  
  /// Check if debouncing
  static bool isDebouncing(String key) {
    return _globalTimers[key]?.isActive == true;
  }
}