import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final file = File('.env');
  final env = await file.readAsString();
  final urlMatch = RegExp(r'SUPABASE_URL=(.*)').firstMatch(env);
  final keyMatch = RegExp(r'SUPABASE_APIKEY=(.*)').firstMatch(env);
  
  final url = urlMatch!.group(1)!.trim();
  final key = keyMatch!.group(1)!.trim();
  
  final res = await http.post(
    Uri.parse('$url/rest/v1/rpc/get_latest_ai_prediction'),
    headers: {
      'apikey': key,
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
      'Accept-Profile': 'public',
      'Content-Profile': 'public',
    },
    body: jsonEncode({"p_symbol": "COMI"}),
  );
  
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
