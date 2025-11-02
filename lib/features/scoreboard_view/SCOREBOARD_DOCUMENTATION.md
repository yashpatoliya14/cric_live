# Scoreboard Module Documentation

## Overview
The scoreboard module is responsible for managing live cricket match scoring, including ball-by-ball tracking, player statistics, match state management, and completion handling.

---

## Files and Structure

### 1. **scoreboard_controller.dart**
Main controller managing the scoreboard logic and state.

#### Key Functionality:

**Initialization & Setup**
- `initializeMatch()` - Initialize match data, load teams, players, and match configuration
- `_initializePlayerInfoWithRetry()` - Retry mechanism to fetch player information from database
- `_setPlayerInfo()` - Set individual player information (name, ID) with validation
- `_debugMatchData()` - Debug method to validate match data and player IDs
- `_forcePlayerNameRefresh()` - Force UI refresh for player name updates

**Ball & Score Actions**
- `onTapRun(int runs)` - Record runs scored on a delivery
- `onTapWicket(String wicketType)` - Handle wicket dismissals
- `undoBall()` - Undo the last ball entry
- `onTapSwap()` - Swap striker and non-striker batsmen
- `_resetExtraSelections()` - Reset wide, no-ball, and bye selections

**Wicket Handling**
- `_handleFinalWicket()` - Handle final wicket that ends an inning
- `_handleRegularWicket()` - Handle regular wicket requiring new batsman selection
- `_selectNewPlayer()` - Show dialog to select new batsman after dismissal

**Inning & Match Flow**
- `_isCurrentInningFinished()` - Check if current inning is complete
- `onTapMainButton()` - Handle end match/next inning button
- `onTapEndMatch()` - Process match end with confirmation
- `_endMatchAndNavigate()` - End match and navigate to results
- `_isMatchActionBlocked()` - Block actions when match/over is completed
- `_isOverCompleted()` - Check if current over is completed
- `onTapSelectNewBowler()` - Handle new bowler selection after over completion
- `_selectNewBowler()` - Show dialog to select new bowler
- `_promptNewBowlerSelection()` - Prompt for new bowler selection
- `clearOverCompletionState()` - Manually clear over completion state

**Match Completion & Results**
- `_checkInningCompletionAfterBall()` - Comprehensive check for inning completion
- `_checkSecondInningResult()` - Check for win/tie in 2nd inning
- `_checkWicketInningCompletionAndShowDialog()` - Check completion after wicket
- `_showAllOutDialog()` - Show dialog when team is all out
- `_showInningCompleteDialog()` - Show dialog when overs are completed
- `_showMatchCompleteDialog()` - Show dialog when match is completed
- `_showMatchEndDialog()` - Show match end with View Result/Stay options
- `_showTieDialog()` - Show dialog for tied match
- `_handleTeamWinResult()` - Handle team win scenario
- `_handleSecondInningAllOut()` - Handle 2nd inning all out
- `_handleSecondInningOversComplete()` - Handle 2nd inning overs complete
- `_calculateAndSetMatchResult()` - Calculate final match result
- `_isMatchNaturallyCompleted()` - Check if match completed naturally
- `_handleNaturalMatchCompletion()` - Handle natural match completion
- `_handleManualMatchEnd()` - Handle manual match end with confirmation

**Calculations & UI Refresh**
- `calculateRuns()` - Calculate total runs
- `calculateWicket()` - Calculate total wickets
- `calculateCurrentOvers()` - Calculate current overs in X.Y format
- `calculateCRR()` - Calculate current run rate
- `calculateBatsman()` - Calculate batsman statistics (runs, balls, SR, 4s, 6s)
- `calculateBowler()` - Calculate bowler statistics (overs, maidens, wickets, ER)
- `calculateOversState()` - Calculate current over state with ball sequence
- `_refreshAllCalculations()` - Refresh all calculations from database
- `_refreshAllCalculationsOptimized()` - Optimized refresh for better performance
- `_updateCriticalStatsImmediately()` - Update critical stats without database queries
- `_updateBatsmanStatsImmediately()` - Update batsman stats immediately
- `_resetBowlerStateForNewOver()` - Reset bowler state for new over
- `getCurrentOverBallCount()` - Get legal ball count in current over

**Match State Management**
- `_handleFirstInningEnd()` - Handle end of first inning and shift to second
- `_handleMatchEnd()` - Handle end of match
- `_handleAllOutAction()` - Handle action when team is all out
- `resumeMatch()` - Resume paused match
- `endMatchFromDialog()` - End match from dialog confirmation
- `viewMatchResults()` - Navigate to match results
- `_handlePostMatchNavigation()` - Handle navigation after match completion
- `_restorePreviousOverState()` - Restore state after undo across overs

**Team & Player Management**
- `_getCachedTeamSize(int teamId)` - Get cached team size to avoid repeated queries
- `_getRequiredWicketsForMatchEnd(int teamId)` - Calculate required wickets for match end
- `debugTestTeamSize()` - Debug method to test team size query

**UI Helpers**
- `_showSimpleDialog()` - Show simple confirmation dialog
- `_showSnackbar()` - Show snackbar message
- `_showEndMatchConfirmationDialog()` - Show confirmation dialog for ending match
- `_showNetworkRequiredDialog()` - Show dialog when network is required
- `_showOverCompletedMessage()` - Show message when over is completed
- `_showMatchCompletedMessage()` - Show message when match is completed
- `_isInningFinishedQuickCheck()` - Quick check without database queries
- `_getEmptyBowlerState()` - Get empty bowler state map

**Lifecycle**
- `onInit()` - Called when controller is initialized
- `onClose()` - Called when controller is disposed, updates match status
- `updateStatus()` - Update match status in database

---

### 2. **scoreboard_model.dart**
Data model for ball-by-ball entries.

#### Properties:
- `id` - Unique identifier for ball entry
- `matchId` - Match identifier
- `inningNo` - Inning number (1 or 2)
- `totalOvers` - Total overs in match
- `strikerBatsmanId` - Striker batsman player ID
- `nonStrikerBatsmanId` - Non-striker batsman player ID
- `bowlerId` - Bowler player ID
- `runs` - Runs scored on delivery
- `currentOvers` - Current over count
- `isWicket` - Whether ball resulted in wicket (1/0)
- `wicketType` - Type of dismissal
- `isNoBall` - Whether ball was no-ball (1/0)
- `isWide` - Whether ball was wide (1/0)
- `isBye` - Whether runs were bye (1/0)
- `isStored` - Whether entry is stored/synced

#### Methods:
- `toMap()` - Convert model to Map for database storage
- `fromMap(Map)` - Create model from database Map

---

### 3. **scoreboard_repo.dart**
Repository handling database operations and calculations.

#### Ball-by-Ball Actions:
- `addBallEntry(ScoreboardModel)` - Add new ball entry to database
- `undoBall()` - Remove last ball entry from database
- `_getLastBallEntry()` - Fetch most recent ball entry

#### Match & Team Data Retrieval:
- `findMatch(int matchId)` - Find match by ID
- `getTeamName(int teamId)` - Get team name by ID
- `getPlayerName(int playerId)` - Get player name by ID
- `getTeamSize(int teamId)` - Get total player count for team
- `debugListTeamPlayers(int teamId)` - Debug method to list all team players
- `getTeamNameOnline(int teamId)` - Fetch team name from API (online)

#### Match State & Inning Management:
- `updateMatch(MatchModel)` - Update match details in database
- `shiftInning()` - Shift to second inning with new players
- `endMatch(int matchId)` - Mark match as completed with result calculation
- `_updateMatchState(int matchId)` - Update serialized match state JSON

#### Calculations:
- `calculateRuns(int matchId, int inningNo)` - Calculate total runs for inning
- `getFirstInningScore(int matchId)` - Get first inning score
- `calculateWicket(int matchId, int inningNo)` - Calculate total wickets
- `calculateCurrentOvers(int matchId, int inningNo)` - Calculate current overs
- `calculateCRR(int matchId, int inningNo)` - Calculate current run rate
- `calculateBatsman(int batsmanId, int matchId)` - Calculate batsman stats
- `calculateBowler()` - Calculate bowler stats with overs, maidens, ER
- `getLegalBallsInCurrentOver()` - Get legal ball count in current over
- `isCurrentOverComplete()` - Check if current over has 6 legal balls
- `getCurrentSessionBallCount()` - Get ball count since bowler selection
- `isCurrentSessionOverComplete()` - Check if current session over is complete
- `getCurrentSessionOverState()` - Get current session over state with ball sequence
- `getDetailedOverState()` - Get detailed over information for UI display

---

### 4. **scoreboard_queries.dart**
SQL query constants for database operations.

#### Query Constants:
- `CALCULATE_BATSMAN` - Calculate batsman runs, balls, 4s, 6s, strike rate
- `CALCULATE_BOWLER` - Calculate bowler overs, runs, wickets
- `CALCULATE_MAIDEN` - Calculate maiden overs using window functions
- `GET_CURRENT_OVER_BALLS` - Get all balls in current over
- `COUNT_LEGAL_BALLS_IN_OVER` - Count legal balls in current over
- `COUNT_CURRENT_SESSION_BALLS` - Count balls since last bowler change
- `GET_CURRENT_SESSION_BALLS` - Get balls since last bowler change
- `CALCULATE_RUNS` - Calculate total runs for inning
- `CALCULATE_WICKET` - Calculate total wickets for inning
- `CALCULATE_CURRENT_OVERS` - Calculate current overs from legal balls

---

### 5. **scoreboard_view.dart**
UI widget for the scoreboard screen.

#### Main Widget:
- `ScoreboardView` - Main stateless widget

#### UI Building Methods:
- `build()` - Main build method with PopScope for back button handling
- `_buildPortraitLayout()` - Build layout for portrait orientation
- `_buildLandscapeLayout()` - Build layout for landscape orientation
- `_buildMainScoreSection()` - Build main score display section
- `_buildInfoItem()` - Build individual info item (Overs, Inning, CRR)
- `_buildStatsSection()` - Build stats section with batting/bowling
- `_buildCurrentOverSection()` - Build current over display with ball sequence
- `_buildBallIndicatorLarge()` - Build individual ball indicator circle
- `_buildBattingSection()` - Build batting stats section
- `_buildBowlingSection()` - Build bowling stats section
- `_buildPlayerStatsCompact()` - Build compact player stats card
- `_buildBowlerStatsCompact()` - Build compact bowler stats card
- `_buildSmallStatItem()` - Build small stat item (label + value)
- `_buildActionSection()` - Build action buttons section
- `_buildMainRunButtons()` - Build run scoring buttons (0-6)
- `_buildRunButton()` - Build individual run button
- `_buildExtrasSection()` - Build extras section (Wide, No Ball, Bye, Undo)
- `_buildSpecialActionsSection()` - Build special actions (Wicket, Swap, Main Button)
- `_buildToggleButton()` - Build toggle button for extras
- `_buildActionButton()` - Build action button (Undo, Swap)
- `_buildActionButtonWithLoader()` - Build action button with loading state
- `_buildMainActionButton()` - Build main action button (End Match/Next Inning)
- `_showBackButtonDialog()` - Show dialog when back button is pressed

#### Helper Methods:
- `_getBallColor()` - Get color for ball indicator based on type

---

### 6. **completion_dialog_helper.dart**
Helper class for match completion dialogs.

#### Methods:
- `showMatchCompletedDialog()` - Show dialog when match is naturally completed with team stats and completion reason

---

### 7. **scoreboard_binding.dart**
GetX binding for dependency injection.

#### Methods:
- `dependencies()` - Initialize ScoreboardController with matchId from arguments

---

### 8. **scorboard_tab.dart** (Note: typo in filename)
Empty file - appears to be unused or placeholder.

---

## State Management

### Observable State Variables:
- **Match State**: `totalOvers`, `inningNo`, `totalRuns`, `wickets`, `currentOvers`, `crr`, `firstInningScore`
- **Team State**: `team1`, `team2`, `team1Id`, `team2Id`, `currentBattingTeamId`
- **Player State**: `bowler`, `bowlerId`, `nonStrikerBatsman`, `nonStrikerBatsmanId`, `strikerBatsman`, `strikerBatsmanId`
- **Player Stats**: `nonStrikerBatsmanState`, `strikerBatsmanState`, `bowlerState`, `oversState`
- **UI State**: `isWideSelected`, `isByeSelected`, `isNoBallSelected`, `isLoading`, `isWicketLoading`, `isMainButtonLoading`, `errorMessage`
- **Internal State**: `_justSelectedNewBowler`, `_bowlerSelectionRetryCount`, `_teamWinDialogShown`, `_matchCompleted`, `_matchEndDialogShown`, `_userChoseStayAfterMatchEnd`, `_overCompleted`

---

## Key Features

### 1. **Live Scoring**
- Ball-by-ball tracking with runs, extras, and dismissals
- Real-time statistics calculation for batsmen and bowlers
- Automatic strike rotation on odd runs
- Support for wides, no-balls, and byes

### 2. **Match Flow Management**
- Automatic detection of inning completion (all out or overs complete)
- Over completion tracking with mandatory bowler change
- Match completion detection with win/tie scenarios
- Seamless inning transition with player selection

### 3. **Player Management**
- Dynamic player selection for new batsmen and bowlers
- Filtering of already playing/dismissed players
- Player statistics tracking throughout match
- Retry mechanism for reliable player data loading

### 4. **Match Completion**
- Natural completion (overs complete, all out, target achieved)
- Manual completion with confirmation dialogs
- Win/tie/loss calculation with proper margin display
- Network requirement for 2nd inning manual end
- Post-match options (View Result or Stay on Scoreboard)

### 5. **Undo Functionality**
- Undo last ball with state restoration
- Bowler restoration across over boundaries
- Match completion state reset on undo
- Always available even after match completion

### 6. **Performance Optimization**
- Immediate UI updates before database sync
- Optimized calculation refresh with priority grouping
- Cached team size to avoid repeated queries
- Debouncing to prevent duplicate actions

### 7. **Error Handling**
- Retry mechanisms for player data loading
- Graceful fallbacks for failed operations
- Comprehensive logging for debugging
- User-friendly error messages

---

## Database Tables Used

### Tables:
- `TBL_BALL_BY_BALL` - Stores ball-by-ball entries
- `TBL_MATCHES` - Stores match information
- `TBL_TEAMS` - Stores team information
- `TBL_TEAM_PLAYERS` - Stores player information

---

## UI Components

### Main Sections:
1. **Header** - Match title and teams
2. **Score Display** - Current score, overs, inning, CRR
3. **Current Over** - Ball-by-ball visualization with bowler selection prompt
4. **Batting Stats** - Striker and non-striker statistics
5. **Bowling Stats** - Current bowler statistics
6. **Action Buttons**:
   - Run buttons (0-6)
   - Extra buttons (Wide, No Ball, Bye)
   - Control buttons (Undo, Wicket, Swap)
   - Main button (End Match/Next Inning)

### Responsive Design:
- Portrait and landscape layouts
- Adaptive spacing and sizing based on screen width
- Horizontal scrolling for button rows on small screens
- Optimized for various device sizes (360px to larger tablets)

---

## External Dependencies

### Key Packages:
- `get` - State management and navigation
- `sqflite` - Local database
- Various UI packages (google_fonts, etc.)

### Internal Dependencies:
- `MyDatabase` - Database singleton
- `SyncFeature` - Backend synchronization
- `ApiServices` - API communication
- `ConnectivityService` - Network connectivity check
- `ResultRepo` - Match result calculations
- `ChoosePlayerRepo` - Player selection
- `MatchModel`, `PlayerModel` - Data models

---

## Match Completion Logic

### Inning End Conditions:
1. **All Out**: `wickets >= (teamSize - 1)` - When team has lost all but one batsman
2. **Overs Complete**: `currentOvers >= totalOvers` - When allocated overs are bowled
3. **Target Achieved** (2nd Inning): `currentScore > firstInningScore` - When chasing team surpasses target

### Result Calculation:
- **Team 2 Wins**: `secondInningScore > firstInningScore` by runs margin
- **Team 1 Wins**: `firstInningScore > secondInningScore` by wickets margin
- **Tie**: `firstInningScore == secondInningScore` at inning completion

---

## Critical User Flows

### 1. Regular Ball Flow:
1. Select extras if needed (Wide/No Ball/Bye)
2. Tap run button (0-6)
3. Ball recorded with automatic calculations
4. Strike rotated if odd runs (except bye)
5. Check for match/inning completion
6. Check for over completion

### 2. Wicket Flow:
1. Tap Wicket button
2. Confirm dismissal dialog
3. Check if final wicket (all out)
   - **Final Wicket**: Record directly, show completion dialog
   - **Regular Wicket**: Show player selection, then record
4. Update match state
5. Check for inning/match completion

### 3. Over Completion Flow:
1. After 6th legal ball, over marked complete
2. New bowler button appears
3. All scoring actions disabled until bowler selected
4. User taps "Select New Bowler"
5. Choose new bowler from list
6. Strike automatically swapped
7. Scoring resumes

### 4. Match Completion Flow:
1. Completion detected (all out/overs complete/target achieved)
2. Match result calculated
3. Dialog shown with two options:
   - **View Result**: Navigate to result screen
   - **Stay Here**: Remain on scoreboard (only undo available)
4. Match data saved and synced

---

## Testing & Debug

### Debug Methods:
- `_debugMatchData()` - Validate match data and player IDs
- `debugTestTeamSize()` - Test team size query
- `debugListTeamPlayers()` - List all players for a team
- Extensive logging throughout with emojis for easy identification

### Log Prefixes:
- `🎯` - Important state changes
- `🔄` - Refresh/update operations
- `✅` - Successful operations
- `❌` - Errors
- `⚠️` - Warnings
- `🏏` - Cricket-specific actions
- `🔍` - Debug/investigation

---

## Future Improvements

### Potential Enhancements:
1. Offline mode with queue for sync
2. Video/photo capture for wickets
3. Detailed wicket type selection
4. Ball-by-ball commentary
5. Real-time multiplayer scoring
6. Advanced statistics (wagon wheel, manhattan, etc.)
7. Export match data (PDF, CSV)
8. Voice-activated scoring
9. Umpire decision tracking (reviews, appeals)
10. Weather condition tracking

---

## Notes

- Controller uses `DebouncingMixin` to prevent duplicate actions
- All database operations are async
- Match state is serialized as JSON for sync
- Team size determines match end condition (not hardcoded to 10)
- Undo functionality is always available, even after match completion
- Main button requires network for 2nd inning manual end
- Over completion uses "current session" logic to track balls since last bowler change
