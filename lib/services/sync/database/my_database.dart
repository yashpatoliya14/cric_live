import 'package:cric_live/utils/import_exports.dart';

class MyDatabase {
  //tells the to compiler that this is a private instance
  MyDatabase._internal();

  //create only once
  static MyDatabase _instance = MyDatabase._internal();

  // return
  factory MyDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    return await initDatabase();
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'cric_live.db');
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
              create table $TBL_BALL_BY_BALL 
              (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                inningNo Integer not null,
                matchId Integer not null,
                currentOvers Real not null default 0.0,
                totalOvers INTEGER NOT NULL,
                strikerBatsmanId INTEGER NOT NULL,
                nonStrikerBatsmanId INTEGER NOT NULL,
                bowlerId INTEGER NOT NULL,
                runs INTEGER ,
                isWicket INTEGER ,
                wicketType TEXT ,
                isNoBall INTEGER ,
                isWide INTEGER ,
                isBye INTEGER , 
                isStored INTEGER             
              )
            ''');
        await db.execute(''' 
              create table $TBL_TEAMS 
              (
                teamId INTEGER PRIMARY KEY,
                teamName TEXT NOT NULL,
                tournamentId INTEGER    
              )
          ''');
        await db.execute(''' 
              create table $TBL_TEAM_PLAYERS 
              (
                teamPlayerId INTEGER PRIMARY KEY,
                teamId INTEGER NOT NULL,
                playerName TEXT NOT NULL,
                
                foreign key (teamId) references $TBL_TEAMS(teamId)           
              )
          ''');

        await db.execute('''
                  create table $TBL_MATCHES
                  (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    matchIdOnline INTEGER,
                    uid Integer,
                    inningNo INTEGER NOT NULL,
                    team1 INTEGER NOT NULL,
                    team2 INTEGER NOT NULL,
                    matchDate datetime NOT NULL,
                    overs INTEGER NOT NULL,
                    status TEXT NOT NULL CHECK(status IN ('live', 'completed', 'scheduled')),
                    tossWon INTEGER ,
                    decision TEXT DEFAULT 'remain',
                    tournamentId TEXT ,
                    wideRun INTEGER default 0,
                    noBallRun INTEGER default 0,
                    strikerBatsmanId Integer ,
                    nonStrikerBatsmanId Integer ,
                    bowlerId Integer ,
                    currentBattingTeamId Integer ,
                    currentOvers real , 
                    matchState text,
                    
                    
                    FOREIGN KEY (team1) REFERENCES $TBL_TEAMS(teamId),
                    FOREIGN KEY (strikerBatsmanId) REFERENCES $TBL_TEAM_PLAYERS(teamPlayerId),
                    FOREIGN KEY (nonStrikerBatsmanId) REFERENCES $TBL_TEAM_PLAYERS(teamPlayerId),
                    FOREIGN KEY (bowlerId) REFERENCES $TBL_TEAM_PLAYERS(teamPlayerId),
                    FOREIGN KEY (tossWon) REFERENCES $TBL_TEAMS(teamId)
                  )
                ''');
      },
      version: 51,

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 51) {
          await db.execute('''
            Drop table $TBL_BALL_BY_BALL 
            
          ''');
          await db.execute('''
            Drop table $TBL_MATCHES 
            
          ''');
          await db.execute('''
            Drop table $TBL_TEAM_PLAYERS 
            
          ''');

          await db.execute('''
            Drop table $TBL_TEAMS 
            
          ''');

          await db.execute(''' 
              create table $TBL_BALL_BY_BALL 
              (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                inningNo Integer not null,
                matchId Integer not null,
                currentOvers Real not null default 0.0,
                totalOvers INTEGER NOT NULL,
                strikerBatsmanId INTEGER NOT NULL,
                nonStrikerBatsmanId INTEGER NOT NULL,
                bowlerId INTEGER NOT NULL,
                runs INTEGER ,
                isWicket INTEGER ,
                wicketType TEXT ,
                isNoBall INTEGER ,
                isWide INTEGER ,
                isBye INTEGER , 
                isStored INTEGER             
              )
            ''');
          await db.execute(''' 
              create table $TBL_TEAMS 
              (
                teamId INTEGER PRIMARY KEY,
                teamName TEXT NOT NULL,
                tournamentId INTEGER    
              )
          ''');
          await db.execute(''' 
              create table $TBL_TEAM_PLAYERS 
              (
                teamPlayerId INTEGER PRIMARY KEY,
                teamId INTEGER NOT NULL,
                playerName TEXT NOT NULL,
                
                foreign key (teamId) references $TBL_TEAMS(teamId)           
              )
          ''');

          await db.execute('''
                  create table $TBL_MATCHES
                  (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    matchIdOnline INTEGER,
                    uid Integer,
                    inningNo INTEGER NOT NULL,
                    team1 INTEGER NOT NULL,
                    team2 INTEGER NOT NULL,
                    matchDate datetime NOT NULL,
                    overs INTEGER NOT NULL,
                    status TEXT NOT NULL,
                    tossWon INTEGER ,
                    decision TEXT DEFAULT 'remain',
                    tournamentId TEXT ,
                    wideRun INTEGER default 0,
                    noBallRun INTEGER default 0,
                    strikerBatsmanId Integer ,
                    nonStrikerBatsmanId Integer ,
                    bowlerId Integer ,
                    currentBattingTeamId Integer ,
                    currentOvers real , 
                    matchState text,
                    
                    
                    FOREIGN KEY (team1) REFERENCES $TBL_TEAMS(teamId),
                    FOREIGN KEY (strikerBatsmanId) REFERENCES $TBL_TEAM_PLAYERS(teamPlayerId),
                    FOREIGN KEY (nonStrikerBatsmanId) REFERENCES $TBL_TEAM_PLAYERS(teamPlayerId),
                    FOREIGN KEY (bowlerId) REFERENCES $TBL_TEAM_PLAYERS(teamPlayerId),
                    FOREIGN KEY (tossWon) REFERENCES $TBL_TEAMS(teamId)
                  )
                ''');
        }
      },
    );
  }
}
