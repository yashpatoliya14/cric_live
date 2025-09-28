import 'package:cric_live/utils/import_exports.dart';

const String CALCULATE_BATSMAN = '''
        SELECT 
          SUM(runs) AS runs,
          SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END) AS balls,
          SUM(CASE WHEN runs = 4 THEN 1 ELSE 0 END) AS fours,
          SUM(CASE WHEN runs = 6 THEN 1 ELSE 0 END) AS sixes,
          CASE 
            WHEN SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END) > 0 
            THEN ROUND(SUM(runs) * 100.0 / SUM(CASE WHEN (isWide IS NULL OR isWide = 0) AND (isNoBall IS NULL OR isNoBall = 0) THEN 1 ELSE 0 END), 2)
            ELSE 0
          END AS strikeRate
        FROM $TBL_BALL_BY_BALL
        WHERE strikerBatsmanId = ? and matchId = ? 
      ''';

const String CALCULATE_BOWLER = '''
         SELECT 
          COUNT(CASE WHEN (isNoBall = 0 OR isNoBall IS NULL) AND (isWide = 0 OR isWide IS NULL) THEN 1 END) as legal_balls,
          COALESCE(SUM(runs), 0) + 
          COALESCE(SUM(CASE WHEN isWide = 1 THEN ? ELSE 0 END), 0) + 
          COALESCE(SUM(CASE WHEN isNoBall = 1 THEN ? ELSE 0 END), 0) as runs,
          COALESCE(COUNT(CASE WHEN isWicket = 1 THEN 1 END), 0) as wickets
      FROM $TBL_BALL_BY_BALL 
      WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
      GROUP BY bowlerId;
      ''';

const String CALCULATE_MAIDEN = '''
WITH legal_balls AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (ORDER BY id) as ball_seq,
        COALESCE(runs, 0) + 
        COALESCE(CASE WHEN isWide = 1 THEN ? ELSE 0 END, 0) + 
        COALESCE(CASE WHEN isNoBall = 1 THEN ? ELSE 0 END, 0) AS ball_runs
    FROM $TBL_BALL_BY_BALL
    WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
    AND (isWide = 0 OR isWide IS NULL) 
    AND (isNoBall = 0 OR isNoBall IS NULL)
),
over_groups AS (
    SELECT 
        ((ball_seq - 1) / 6) AS over_no,
        SUM(ball_runs) AS over_runs,
        COUNT(*) as balls_in_over
    FROM legal_balls
    GROUP BY ((ball_seq - 1) / 6)
    HAVING balls_in_over = 6
)
SELECT COUNT(*) AS maidens
FROM over_groups
WHERE over_runs = 0;
''';

// New query to get current over state for better tracking
const String GET_CURRENT_OVER_BALLS = '''
SELECT 
    id,
    runs,
    isWide,
    isNoBall,
    isWicket,
    wicketType
FROM $TBL_BALL_BY_BALL
WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
ORDER BY id
''';

// Query to count legal balls in current over
const String COUNT_LEGAL_BALLS_IN_OVER = '''
SELECT COUNT(*) as legal_balls
FROM $TBL_BALL_BY_BALL
WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
AND (isWide = 0 OR isWide IS NULL) 
AND (isNoBall = 0 OR isNoBall IS NULL)
''';

// NEW: Query to count balls in CURRENT OVER SESSION only (since last bowler change)
const String COUNT_CURRENT_SESSION_BALLS = '''
SELECT COUNT(*) as legal_balls
FROM $TBL_BALL_BY_BALL
WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
AND (isWide = 0 OR isWide IS NULL) 
AND (isNoBall = 0 OR isNoBall IS NULL)
AND id > (
  SELECT COALESCE(MAX(id), 0)
  FROM $TBL_BALL_BY_BALL
  WHERE matchId = ? AND inningNo = ? AND bowlerId != ?
)
''';

// NEW: Get current session over state (balls since last bowler change)
const String GET_CURRENT_SESSION_BALLS = '''
SELECT 
    id,
    runs,
    isWide,
    isNoBall,
    isWicket,
    wicketType
FROM $TBL_BALL_BY_BALL
WHERE matchId = ? AND inningNo = ? AND bowlerId = ?
AND id > (
  SELECT COALESCE(MAX(id), 0)
  FROM $TBL_BALL_BY_BALL
  WHERE matchId = ? AND inningNo = ? AND bowlerId != ?
)
ORDER BY id
''';

const String CALCULATE_RUNS =
    'SELECT SUM(runs) as total FROM $TBL_BALL_BY_BALL WHERE matchId = ? AND inningNo = ?';
const String CALCULATE_WICKET =
    'SELECT SUM(isWicket) as total FROM $TBL_BALL_BY_BALL WHERE matchId = ? AND inningNo = ? AND isWicket = 1';
const String CALCULATE_CURRENT_OVERS =
    'SELECT COUNT(*) FROM $TBL_BALL_BY_BALL WHERE matchId = ? AND inningNo = ? AND (isWide = 0 OR isWide IS NULL) AND (isNoBall = 0 OR isNoBall IS NULL)';
