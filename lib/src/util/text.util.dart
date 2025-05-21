import 'package:html_unescape/html_unescape_small.dart';

class TextUtil {
  static String sanitazeBBCode(String texto) {
    var bbcodeTagRegex = RegExp(r'(?<=\[).*?(?=])');
    var tagNameRegex = RegExp(r'^\w+(?==)');
    var equalRegex = RegExp(r'=');
    var notParsedTags = RegExp(
        r'\[\/?(p|b|DISK FILE ID=\d+|font(=[\w ,]*)?|user|user=\d+|size(=\d{2,})?(pt)?)*\]');

    String retorno = texto;
    retorno = retorno.replaceAllMapped(bbcodeTagRegex, (match) {
      String? tagCompleta = match.group(0);
      String? resultado = '';
      if (tagCompleta != null && equalRegex.hasMatch(tagCompleta)) {
        resultado = tagCompleta.replaceAllMapped(tagNameRegex, (match1) {
          return match1.group(0)!.toLowerCase();
        });
      } else {
        resultado = tagCompleta!.toLowerCase();
      }
      return resultado;
    });

    retorno = retorno.replaceAll(notParsedTags, '');
    retorno = HtmlUnescape().convert(retorno);
    return retorno;
  }
}
