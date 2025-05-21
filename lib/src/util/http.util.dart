import 'package:http/http.dart' as http;
import 'package:process_run/stdio.dart';

class HttpUtil {
  static download(String url, String filePathDest) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/octet-stream'},
    );
    if (response.statusCode == 200) {
      File file = File(filePathDest);
      file.writeAsBytes(response.bodyBytes);
    }
  }
}
