class WorkgroupBitrix {
  String? id;
  String? name;

  WorkgroupBitrix.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    name = json['name'] as String;
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  String toString() {
    return 'WorkgroupBitrix{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkgroupBitrix && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
