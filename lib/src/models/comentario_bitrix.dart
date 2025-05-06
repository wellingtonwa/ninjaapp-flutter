import 'package:ninjaapp/src/models/anexo_comentario_bitrix.dart';

class ComentarioBitrix {
  String? POST_MESSAGE_HTML;
  String? ID;
  String? AUTHOR_ID;
  String? AUTHOR_NAME;
  String? AUTHOR_EMAIL;
  String? POST_DATE;
  String? POST_MESSAGE;
  List<AnexoComentarioBitrix>? ATTACHED_OBJECTS;

  ComentarioBitrix.fromJson(Map<String, dynamic> json) {
    POST_MESSAGE_HTML = json['POST_MESSAGE_HTML'];
    ID = json['ID'];
    AUTHOR_ID = json['AUTHOR_ID'];
    AUTHOR_NAME = json['AUTHOR_NAME'];
    AUTHOR_EMAIL = json['AUTHOR_EMAIL'];
    POST_DATE = json['POST_DATE'];
    POST_MESSAGE = json['POST_MESSAGE'];
    if (json['ATTACHED_OBJECTS'] != null) {
      ATTACHED_OBJECTS = <AnexoComentarioBitrix>[];
      json['ATTACHED_OBJECTS'].forEach((v) {
        ATTACHED_OBJECTS!.add(AnexoComentarioBitrix.fromJson(v));
      });
    }
  }
  
  @override
  String toString() {
    return 'ComentarioBitrix{POST_MESSAGE_HTML: $POST_MESSAGE_HTML, ID: $ID, AUTHOR_ID: $AUTHOR_ID, AUTHOR_NAME: $AUTHOR_NAME, AUTHOR_EMAIL: $AUTHOR_EMAIL, POST_DATE: $POST_DATE, POST_MESSAGE: $POST_MESSAGE, ATTACHED_OBJECTS: $ATTACHED_OBJECTS}';
  }
}