import 'package:cric_live/utils/import_exports.dart';
import 'dart:developer' as developer;

/// Service to preload essential app data during splash screen
class PreloadService {
  static final PreloadService _instance = PreloadService._internal();
  factory PreloadService() => _instance;
  PreloadService._internal();

  final MatchesDisplay _matchesRepo = MatchesDisplay();
  
  // Preloaded data storage
  List<MatchModel>? _preloadedMatches;
  List<CompleteMatchResultModel>? _preloadedMatchStates;
  
  // Progress tracking
  final RxDouble loadingProgress = 0.0.obs;
  final RxString loadingMessage = 'Starting...'.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  /// Get preloaded matches (if available)
  List<MatchModel>? get preloadedMatches => _preloadedMatches;
  List<CompleteMatchResultModel>? get preloadedMatchStates => _preloadedMatchStates;
  bool get hasPreloadedMatches => _preloadedMatches != null && _preloadedMatches!.isNotEmpty;

  /// Main preload function called during splash screen
  Future<bool> preloadEssentialData() async {
    try {
      hasError.value = false;
      errorMessage.value = '';
      
      await _updateProgress(0.1, 'Initializing app...');
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _updateProgress(0.2, 'Checking connectivity...');
      final isConnected = await _checkConnectivity();
      if (!isConnected) {
        await _updateProgress(0.3, 'Working offline...');
        await Future.delayed(const Duration(milliseconds: 500));
        await _updateProgress(1.0, 'Ready to go!');
        return true; // Continue without live data
      }
      
      await _updateProgress(0.4, 'Loading live matches...');
      final matchesLoaded = await _preloadLiveMatches();
      
      if (matchesLoaded) {
        await _updateProgress(0.7, 'Processing match data...');
        await _processPreloadedMatchStates();
        await _updateProgress(0.9, 'Finalizing setup...');
      } else {
        await _updateProgress(0.7, 'Preparing offline mode...');
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      await _updateProgress(1.0, 'Welcome to CricLive!');
      
      developer.log('✅ Preload completed successfully. Matches: ${_preloadedMatches?.length ?? 0}');
      return true;
      
    } catch (e) {
      developer.log('❌ Preload failed: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load data. Continuing with offline mode...';
      
      await _updateProgress(0.8, 'Switching to offline mode...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateProgress(1.0, 'Ready in offline mode!');
      
      return true; // Continue even with errors
    }
  }

  /// Preload live matches
  Future<bool> _preloadLiveMatches() async {
    try {
      developer.log('🏏 Starting live matches preload...');
      
      final matches = await _matchesRepo.getLiveMatches();
      if (matches != null && matches.isNotEmpty) {
        _preloadedMatches = matches;
        developer.log('✅ Preloaded ${matches.length} live matches');
        return true;
      } else {
        developer.log('ℹ️ No live matches found to preload');
        _preloadedMatches = [];
        return true; // Empty is still success
      }
    } catch (e) {
      developer.log('❌ Error preloading matches: $e');
      _preloadedMatches = null;
      return false;
    }
  }

  /// Process preloaded match states
  Future<void> _processPreloadedMatchStates() async {
    try {
      if (_preloadedMatches == null) return;
      
      List<CompleteMatchResultModel> states = [];
      
      for (MatchModel match in _preloadedMatches!) {
        if (match.matchState != null) {
          states.add(match.matchState!);
        } else {
          // Create empty state for matches without state data
          states.add(CompleteMatchResultModel());
        }
      }
      
      _preloadedMatchStates = states;
      developer.log('✅ Processed ${states.length} match states');
    } catch (e) {
      developer.log('❌ Error processing match states: $e');
      _preloadedMatchStates = null;
    }
  }

  /// Check internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final isConnected = result != ConnectivityResult.none;
      developer.log('🌐 Connectivity check: ${isConnected ? "Connected" : "Offline"}');
      return isConnected;
    } catch (e) {
      developer.log('❌ Connectivity check failed: $e');
      return false;
    }
  }

  /// Update progress with message
  Future<void> _updateProgress(double progress, String message) async {
    loadingProgress.value = progress;
    loadingMessage.value = message;
    developer.log('📊 Progress: ${(progress * 100).toInt()}% - $message');
    await Future.delayed(const Duration(milliseconds: 150));
  }

  /// Transfer preloaded data to live match controller
  void transferDataToController(DisplayLiveMatchController controller) {
    try {
      if (_preloadedMatches != null) {
        controller.matches.assignAll(_preloadedMatches!);
        developer.log('🔄 Transferred ${_preloadedMatches!.length} matches to controller');
      }
      
      if (_preloadedMatchStates != null) {
        controller.matchesState.assignAll(_preloadedMatchStates!);
        controller.hasMatches.value = _preloadedMatchStates!.isNotEmpty;
        developer.log('🔄 Transferred ${_preloadedMatchStates!.length} match states to controller');
      }
      
      // Mark initial loading as complete since we have preloaded data
      controller.isInitialLoading.value = false;
      
    } catch (e) {
      developer.log('❌ Error transferring preloaded data: $e');
    }
  }

  /// Clear preloaded data to free memory
  void clearPreloadedData() {
    _preloadedMatches = null;
    _preloadedMatchStates = null;
    developer.log('🧹 Cleared preloaded data from memory');
  }

  /// Reset preload service state
  void reset() {
    clearPreloadedData();
    loadingProgress.value = 0.0;
    loadingMessage.value = 'Starting...';
    hasError.value = false;
    errorMessage.value = '';
  }
}
