class AnexoComentarioBitrix {
  String? ATTACHMENT_ID;
  String? NAME;
  String? SIZE;
  String? FILE_ID;
  String? DOWNLOAD_URL;
  String? VIEW_URL;

  AnexoComentarioBitrix.fromJson(Map<String, dynamic> json) {
    ATTACHMENT_ID = json['ATTACHMENT_ID'] as String?;
    NAME = json['NAME'] as String?;
    SIZE = json['SIZE'] as String?;
    FILE_ID = json['FILE_ID'] as String?;
    DOWNLOAD_URL = json['DOWNLOAD_URL'] as String?;
    VIEW_URL = json['VIEW_URL'] as String?;
  }
  
  @override
  String toString() {
    // TODO: implement toString
    return 'AnexoComentarioBitrix{ATTACHMENT_ID: $ATTACHMENT_ID, NAME: $NAME, SIZE: $SIZE, FILE_ID: $FILE_ID, DOWNLOAD_URL: $DOWNLOAD_URL, VIEW_URL: $VIEW_URL}';
  }
}