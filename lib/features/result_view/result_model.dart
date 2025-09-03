class ResultModel {
  String? playerName;
  int? runs;
  int? balls;
  int? fours;
  int? sixes;
  double? SR; // Strike Rate
  double? overs;
  int? wickets;
  int? maidens;
  int? ER; // Economy Rate

  // 1. Standard constructor for creating an instance in your code.
  ResultModel({
    this.playerName,
    this.runs,
    this.balls,
    this.fours,
    this.sixes,
    this.maidens,
    this.SR,
    this.overs,
    this.wickets,
    this.ER,
  });

  // 2. Factory constructor for creating a new ResultModel instance from a map structure.
  // This is used for decoding JSON data from an API response.
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      playerName: json['playerName'] as String?,
      runs: json['runs'] as int?,
      balls: json['balls'] as int?,
      fours: json['fours'] as int?,
      sixes: json['sixes'] as int?,
      maidens: json['maidens'] as int?,
      // Safely cast num to double to handle both int (e.g., 150) and double (e.g., 150.25) from JSON
      SR: (json['SR'] as num?)?.toDouble(),
      overs: (json['overs'] as num?)?.toDouble(),
      wickets: json['wickets'] as int?,
      ER: json['ER'] as int?,
    );
  }

  // 3. Method to convert a ResultModel instance into a map.
  // This is used for encoding the object to JSON to send in an API request.
  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'SR': SR,
      'maidens': maidens,
      'overs': overs,
      'wickets': wickets,
      'ER': ER,
    };
  }
}
