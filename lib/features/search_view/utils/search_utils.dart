import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utilities for search functionality
class SearchUtils {
  
  /// Clean and normalize search query
  static String normalizeQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Check if query is valid for search
  static bool isValidQuery(String query) {
    final normalized = normalizeQuery(query);
    return normalized.isNotEmpty && normalized.length >= 2;
  }

  /// Get highlight color for search results
  static Color getHighlightColor(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return Colors.purple.shade100;
      case 'match':
        return Colors.green.shade100;
      case 'team':
        return Colors.blue.shade100;
      case 'player':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Get icon color for search result types
  static Color getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return Colors.purple;
      case 'match':
        return Colors.green;
      case 'team':
        return Colors.blue;
      case 'player':
        return Colors.orange;
      default:
        return Colors.deepOrange;
    }
  }

  /// Get appropriate icon for search result type
  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tournament':
        return Icons.emoji_events;
      case 'match':
        return Icons.sports_cricket;
      case 'team':
        return Icons.group;
      case 'player':
        return Icons.person;
      default:
        return Icons.search;
    }
  }

  /// Generate search suggestions based on input
  static List<String> generateSuggestions(String query) {
    final suggestions = <String>[];
    final lowerQuery = query.toLowerCase();

    // Popular searches
    final popular = [
      'IPL 2024',
      'T20 World Cup',
      'Mumbai Indians',
      'Chennai Super Kings',
      'Royal Challengers',
      'Kolkata Knight Riders',
      'Delhi Capitals',
      'Rajasthan Royals',
      'Punjab Kings',
      'Sunrisers Hyderabad',
      'Live Matches',
      'Upcoming Tournaments',
      'Cricket News',
      'Player Stats',
    ];

    // Filter suggestions based on query
    for (String item in popular) {
      if (item.toLowerCase().contains(lowerQuery)) {
        suggestions.add(item);
      }
    }

    // Limit to top 6 suggestions
    return suggestions.take(6).toList();
  }

  /// Highlight matching text in search results
  static Widget highlightText(
    String text,
    String query, {
    TextStyle? defaultStyle,
    TextStyle? highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery, start);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: defaultStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle ?? 
            (defaultStyle?.copyWith(
              backgroundColor: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ) ?? TextStyle(
              backgroundColor: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            )),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: defaultStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Format search result subtitle with additional info
  static String formatSubtitle(Map<String, dynamic> data, String type) {
    final parts = <String>[];
    
    switch (type.toLowerCase()) {
      case 'tournament':
        if (data['teams'] != null) parts.add('${data['teams']} Teams');
        if (data['location'] != null) parts.add(data['location']);
        if (data['duration'] != null) parts.add(data['duration']);
        break;
        
      case 'match':
        if (data['status'] != null) parts.add(data['status']);
        if (data['format'] != null) parts.add(data['format']);
        if (data['tournament'] != null) parts.add(data['tournament']);
        break;
        
      case 'team':
        if (data['league'] != null) parts.add(data['league']);
        if (data['players'] != null) parts.add('${data['players']} Players');
        if (data['location'] != null) parts.add(data['location']);
        break;
        
      case 'player':
        if (data['role'] != null) parts.add(data['role']);
        if (data['team'] != null) parts.add(data['team']);
        if (data['style'] != null) parts.add(data['style']);
        break;
    }
    
    return parts.join(' • ');
  }

  /// Navigate to appropriate detail page based on result type
  static void navigateToResult(String type, Map<String, dynamic> data) {
    switch (type.toLowerCase()) {
      case 'tournament':
        Get.toNamed('/tournament-detail', arguments: data);
        break;
      case 'match':
        Get.toNamed('/match-detail', arguments: data);
        break;
      case 'team':
        Get.toNamed('/team-detail', arguments: data);
        break;
      case 'player':
        Get.toNamed('/player-detail', arguments: data);
        break;
      default:
        Get.snackbar(
          'Info',
          'Detail page not available for $type',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  /// Check if search result matches current filter
  static bool matchesFilter(String resultType, String filter) {
    if (filter == 'All') return true;
    
    final normalizedFilter = filter.toLowerCase();
    final normalizedType = resultType.toLowerCase();
    
    // Handle plural forms
    final filterSingular = normalizedFilter.endsWith('s') 
        ? normalizedFilter.substring(0, normalizedFilter.length - 1)
        : normalizedFilter;
    
    return normalizedType == filterSingular;
  }

  /// Debounce helper for search input
  static void debounceSearch({
    required String query,
    required Function(String) onSearch,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    // This would typically use a Timer, but GetX's debounce is used in the controller
    onSearch(query);
  }

  /// Get search placeholder based on selected filter
  static String getSearchPlaceholder(String filter) {
    switch (filter.toLowerCase()) {
      case 'tournaments':
        return 'Search tournaments...';
      case 'matches':
        return 'Search matches...';
      case 'teams':
        return 'Search teams...';
      case 'players':
        return 'Search players...';
      default:
        return 'Search tournaments, matches, teams, players...';
    }
  }
}
