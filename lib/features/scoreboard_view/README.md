 Scoreboard Module

## Quick Links

📚 **[Complete Documentation](SCOREBOARD_DOCUMENTATION.md)** - Full functionality reference  
📝 **[Changes Summary](CHANGES_SUMMARY.md)** - Recent improvements and cleanup

---

## Overview

The scoreboard module handles live cricket match scoring with real-time statistics, ball-by-ball tracking, and comprehensive match flow management.

## Files Structure

```
scoreboard_view/
├── scoreboard_controller.dart      # Main controller (state & logic)
├── scoreboard_repo.dart            # Database operations
├── scoreboard_model.dart           # Data model for ball entries
├── scoreboard_queries.dart         # SQL query constants
├── scoreboard_view.dart            # UI widget
├── completion_dialog_helper.dart   # Match completion dialogs
├── scoreboard_binding.dart         # Dependency injection
├── SCOREBOARD_DOCUMENTATION.md     # Complete documentation
├── CHANGES_SUMMARY.md              # Recent changes
└── README.md                       # This file
```

## Key Features

✅ **Live Scoring** - Ball-by-ball tracking with runs, extras, wickets  
✅ **Player Statistics** - Real-time batsman and bowler stats  
✅ **Match Flow** - Automatic inning/match completion detection  
✅ **Undo Function** - Undo last ball with state restoration  
✅ **Performance** - Optimized calculations and caching  
✅ **Error Handling** - Retry mechanisms and graceful failures  

## Quick Start

### 1. Navigate to Scoreboard
```dart
Get.toNamed(NAV_SCOREBOARD, arguments: {'matchId': matchId});
```

### 2. Main Functions

**Record Runs:**
```dart
controller.onTapRun(runs: 4); // Record 4 runs
```

**Record Wicket:**
```dart
controller.onTapWicket(wicketType: "caught"); // Record wicket
```

**Undo Last Ball:**
```dart
controller.undoBall(); // Undo last entry
```

**End Match:**
```dart
controller.onTapEndMatch(); // End match with confirmation
```

## Documentation

### For New Developers
Read **[SCOREBOARD_DOCUMENTATION.md](SCOREBOARD_DOCUMENTATION.md)** for:
- All function names and descriptions
- User flows and scenarios
- State management details
- Database schema
- Testing guidance

### For Recent Changes
See **[CHANGES_SUMMARY.md](CHANGES_SUMMARY.md)** for:
- Code cleanup details
- Removed logs and methods
- Performance improvements
- Testing recommendations

## State Management

Uses **GetX** for reactive state management:
- Observable variables for UI updates
- Debouncing to prevent duplicate actions
- Immediate UI updates with background calculations

## Database

Uses **SQLite** with these tables:
- `TBL_BALL_BY_BALL` - Ball-by-ball entries
- `TBL_MATCHES` - Match information
- `TBL_TEAMS` - Team information
- `TBL_TEAM_PLAYERS` - Player information

## Testing

Run these tests after modifications:
```bash
# Example test commands
flutter test test/scoreboard_test.dart
flutter integration_test integration_test/scoreboard_flow_test.dart
```

## Common Issues & Solutions

### Issue: Players not loading
**Solution:** Check player IDs in match model, verify database entries

### Issue: Over not completing
**Solution:** Verify 6 legal balls recorded (excluding wides/no-balls)

### Issue: Match not ending
**Solution:** Check wickets vs team size, verify overs calculation

## Performance Tips

1. Use immediate UI updates for critical stats
2. Batch database operations when possible
3. Cache frequently accessed data (team sizes, etc.)
4. Use debouncing for user actions

## Contributing

When modifying this module:
1. Update **SCOREBOARD_DOCUMENTATION.md** for new functions
2. Keep critical error logs, remove debug logs
3. Test all match flow scenarios
4. Update this README if structure changes

## Support

For questions or issues:
1. Check documentation first
2. Review code comments
3. Check git history for recent changes
4. Ask team for clarification

---

**Last Updated:** 2025-11-02  
**Version:** 1.0  
**Maintainer:** Development Team
