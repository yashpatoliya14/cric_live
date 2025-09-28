import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Collection of reusable widgets for tournament view
class TournamentWidgets {
  /// Builds a status chip with dynamic color based on match status
  static Widget statusChip(String text, Color color, {VoidCallback? onTap}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          color: _getSafeTextColor(color),
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }

  /// Builds header info chips for tournament details
  static Widget headerChip({
    required IconData icon,
    required String label,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: textColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets appropriate color for match status
  static Color statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'resume':
      case 'live':
        return Colors.red;
      case 'scheduled':
      default:
        return Colors.orange;
    }
  }

  /// Gets formatted status text
  static String statusText(String? status) {
    final s = (status ?? '').toUpperCase();
    if (s.isEmpty) return 'UNKNOWN';
    return s;
  }

  /// Formats match date with fallback - shows full date and time
  static String formatMatchDate(DateTime? date) {
    if (date == null) return 'Schedule TBA';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDay = DateTime(date.year, date.month, date.day);

    // Always show both date and time for clarity
    if (matchDay == today) {
      return 'Today, ${DateFormat('MMM d').format(date)} at ${DateFormat('h:mm a').format(date)}';
    } else if (matchDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${DateFormat('MMM d').format(date)} at ${DateFormat('h:mm a').format(date)}';
    } else if (matchDay.isBefore(today.add(const Duration(days: 7)))) {
      return '${DateFormat('EEE, MMM d').format(date)} at ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('EEE, MMM d, yyyy at h:mm a').format(date);
    }
  }

  /// Formats detailed match date and time for cards
  static String formatDetailedMatchDate(DateTime? date) {
    if (date == null) return 'Match date and time not set';
    return DateFormat('EEE, MMM d, yy at h:mm a').format(date);
  }

  /// Formats compact date and time for display
  static String formatCompactDateTime(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('MMM d, yy • h:mm a').format(date);
  }

  /// Formats time only
  static String formatTimeOnly(DateTime? date) {
    if (date == null) return 'Time TBA';
    return DateFormat('h:mm a').format(date);
  }

  /// Formats date only
  static String formatDateOnly(DateTime? date) {
    if (date == null) return 'Date TBA';
    return DateFormat('EEE, MMM d, yy').format(date);
  }

  /// Formats tournament duration with year if different
  static String formatTournamentDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '—';

    final now = DateTime.now();
    final isSameYear = start.year == end.year && start.year == now.year;
    final isSameMonth = start.month == end.month && start.year == end.year;

    if (isSameMonth) {
      // Same month: "Jan 15 - 20, 2024" or "Jan 15 - 20" if current year
      if (isSameYear) {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('d').format(end)}';
      } else {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yy').format(end)}';
      }
    } else if (start.year == end.year) {
      // Same year: "Jan 15 - Feb 20, 24" or "Jan 15 - Feb 20" if current year
      if (isSameYear) {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
      } else {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yy').format(end)}';
      }
    } else {
      // Different years: "Dec 15, 23 - Jan 20, 24"
      return '${DateFormat('MMM d, yy').format(start)} - ${DateFormat('MMM d, yy').format(end)}';
    }
  }

  /// Formats tournament date range for display in info sections
  static String formatTournamentDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Dates TBA';

    final duration = formatTournamentDuration(start, end);
    final daysDiff = end.difference(start).inDays;

    if (daysDiff == 0) {
      return '${DateFormat('EEE, MMM d, yy').format(start)} (Single Day)';
    } else {
      return '$duration ($daysDiff days)';
    }
  }

  /// Formats creation date for tournament info
  static String formatCreationDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) {
      return 'Created today';
    } else if (diff == 1) {
      return 'Created yesterday';
    } else if (diff < 7) {
      return 'Created $diff days ago';
    } else {
      return 'Created on ${DateFormat('MMM d, yy').format(date)}';
    }
  }

  /// Formats time remaining until tournament start
  static String formatTimeUntilStart(DateTime? startDate) {
    if (startDate == null) return 'Start date TBA';

    final now = DateTime.now();
    final diff = startDate.difference(now);

    if (diff.isNegative) {
      // Tournament has already started
      final daysPast = (-diff.inDays);
      if (daysPast == 0) {
        return 'Started today';
      } else if (daysPast == 1) {
        return 'Started yesterday';
      } else {
        return 'Started $daysPast days ago';
      }
    } else {
      // Tournament hasn't started yet
      final daysUntil = diff.inDays;
      final hoursUntil = diff.inHours;
      final minutesUntil = diff.inMinutes;

      if (daysUntil > 0) {
        return daysUntil == 1 ? 'Starts tomorrow' : 'Starts in $daysUntil days';
      } else if (hoursUntil > 0) {
        return hoursUntil == 1
            ? 'Starts in 1 hour'
            : 'Starts in $hoursUntil hours';
      } else if (minutesUntil > 0) {
        return minutesUntil == 1
            ? 'Starts in 1 minute'
            : 'Starts in $minutesUntil minutes';
      } else {
        return 'Starting now!';
      }
    }
  }

  /// Creates enhanced empty state
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: iconColor ?? Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 24), action],
        ],
      ),
    );
  }

  /// Creates enhanced loading state
  static Widget loadingState({
    String title = 'Loading...',
    String? subtitle,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.deepOrange,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Creates animated list item with staggered animation
  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration baseDuration = const Duration(milliseconds: 300),
    int staggerDelay = 50,
  }) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: baseDuration.inMilliseconds + (index * staggerDelay),
      ),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }

  /// Creates info row for tournament details
  static Widget infoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: valueColor ?? Colors.grey[800],
                fontWeight:
                    valueColor != null ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get safe text color for status chip
  static Color _getSafeTextColor(Color color) {
    // Handle different color types safely
    if (color == Colors.orange) {
      return Colors.orange.shade800;
    } else if (color == Colors.green) {
      return Colors.green.shade700;
    } else if (color == Colors.red) {
      return Colors.red.shade700;
    } else if (color == Colors.blue) {
      return Colors.blue.shade700;
    } else if (color == Colors.purple) {
      return Colors.purple.shade700;
    } else if (color == Colors.deepOrange) {
      return Colors.deepOrange.shade700;
    } else {
      // Fallback: create a darker version of the color
      return Color.fromRGBO(
        (color.red * 0.7).round(),
        (color.green * 0.7).round(),
        (color.blue * 0.7).round(),
        1.0,
      );
    }
  }
}
