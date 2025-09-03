class PlayerBowlingResultModel {
  int? playerId;
  String? playerName;
  double? overs; // e.g., 4.2 means 4 overs and 2 balls
  int? wickets;
  int? runs;
  int? maidens;
  double? economyRate;
  int? wides;
  int? noBalls;
  int? dots; // dot balls
  
  PlayerBowlingResultModel({
    this.playerId,
    this.playerName,
    this.overs,
    this.wickets,
    this.runs,
    this.maidens,
    this.economyRate,
    this.wides,
    this.noBalls,
    this.dots,
  });

  // Calculate economy rate automatically if not provided
  double get calculatedEconomyRate {
    if (overs == null || overs! == 0.0) return 0.0;
    return (runs ?? 0) / overs!;
  }

  // Get total balls bowled
  int get totalBalls {
    if (overs == null) return 0;
    int fullOvers = overs!.floor();
    double remainder = overs! - fullOvers;
    int extraBalls = (remainder * 10).round(); // 0.3 becomes 3 balls
    return (fullOvers * 6) + extraBalls;
  }

  // Format overs for display (e.g., 4.2)
  String get oversDisplay {
    if (overs == null) return "0.0";
    return overs!.toStringAsFixed(1);
  }

  // Calculate bowling average
  double get bowlingAverage {
    if (wickets == null || wickets! == 0) return double.infinity;
    return (runs ?? 0) / wickets!;
  }

  // Calculate strike rate (balls per wicket)
  double get bowlingStrikeRate {
    if (wickets == null || wickets! == 0) return double.infinity;
    return totalBalls / wickets!;
  }

  // Convert from database/API response
  factory PlayerBowlingResultModel.fromJson(Map<String, dynamic> json) {
    return PlayerBowlingResultModel(
      playerId: json['playerId'] as int?,
      playerName: json['playerName'] as String?,
      overs: (json['overs'] as num?)?.toDouble(),
      wickets: json['wickets'] as int?,
      runs: json['runs'] as int?,
      maidens: json['maidens'] as int?,
      economyRate: (json['economyRate'] as num?)?.toDouble(),
      wides: json['wides'] as int?,
      noBalls: json['noBalls'] as int?,
      dots: json['dots'] as int?,
    );
  }

  // Convert to database/API format
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'overs': overs,
      'wickets': wickets,
      'runs': runs,
      'maidens': maidens,
      'economyRate': economyRate ?? calculatedEconomyRate,
      'wides': wides,
      'noBalls': noBalls,
      'dots': dots,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from database map
  PlayerBowlingResultModel fromMap(Map<String, dynamic> map) {
    return PlayerBowlingResultModel.fromJson(map);
  }
}
