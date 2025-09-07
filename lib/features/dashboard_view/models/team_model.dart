class TeamModel {
  final int? id;
  final String? name;
  final String? shortName;

  TeamModel({this.id, this.name, this.shortName});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'shortName': shortName};
  }

  TeamModel fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
      shortName: map['shortName'] as String?,
    );
  }
}
