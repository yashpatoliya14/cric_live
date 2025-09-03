class TeamModel {
  final int? id;
  final String? name;
  final String? shortName;
  final String? logo;

  TeamModel({
    this.id,
    this.name,
    this.shortName,
    this.logo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'logo': logo,
    };
  }

  TeamModel fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
      shortName: map['shortName'] as String?,
      logo: map['logo'] as String?,
    );
  }

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, shortName: $shortName, logo: $logo)';
  }
}
