class PersonBitrix {
  String? id;
  String? name;
  String? link;
  String? icon;

  PersonBitrix.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    name = json['name'] as String?;
    link = json['link'] as String?;
    icon = json['icon'] as String?;
  }
}
