class AnexoTarefaBitrix {
  String? ID;
  String? OBJECT_ID;
  String? MODULE_ID;
  String? ENTITY_TYPE;
  String? ENTITY_ID;
  String? CREATE_TIME;
  String? CREATED_BY;
  String? DOWNLOAD_URL;
  String? NAME;
  String? SIZE;

  AnexoTarefaBitrix.fromJson(Map<String, dynamic> json) {
    ID = json['ID'] as String?;
    OBJECT_ID = json['OBJECT_ID'] as String?;
    MODULE_ID = json['MODULE_ID'] as String?;
    ENTITY_TYPE = json['ENTITY_TYPE'] as String?;
    ENTITY_ID = json['ENTITY_ID'] as String?;
    CREATE_TIME = json['CREATE_TIME'] as String?;
    CREATED_BY = json['CREATED_BY'] as String?;
    DOWNLOAD_URL = json['DOWNLOAD_URL'] as String?;
    NAME = json['NAME'] as String?;
    SIZE = json['SIZE'] as String?;
  }

  @override
  String toString() {
    return 'AnexoTarefaBitrix{ID: $ID, OBJECT_ID: $OBJECT_ID, MODULE_ID: $MODULE_ID, ENTITY_ID: $ENTITY_ID, NAME: $NAME}';
  }
}
