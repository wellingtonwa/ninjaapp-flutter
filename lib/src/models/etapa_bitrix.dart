class EtapaBitrix {
  String? ID;
  String? TITLE;
  String? SORT;
  String? COLOR;

  EtapaBitrix.fromJson(Map<String, dynamic> json) {
    ID = json['ID'];
    TITLE = json['TITLE'];
    SORT = json['SORT'];
    COLOR = json['COLOR'];
  }
}