import 'draw3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String API_ENDPOINT = const String.fromEnvironment("ZVENO_API_ENDPOINT", defaultValue: "http://localhost:8080/"); 
const String NOT_FOUND_ERROR = 'Not found';

class Api {
    static Future<Block> getBlock(String id) async {
        final resp = await http.get(Uri.parse('$API_ENDPOINT/block/$id'));
        dynamic bodyDecoded = jsonDecode(resp.body);
        if (resp.statusCode == 200) {
            return Block.fromJson(bodyDecoded);
        } else if (bodyDecoded['error'] == NOT_FOUND_ERROR) {
            throw Exception("\nВведённый ID схемы некорректен. Попробуйте ввести другой или сгенерировать случайную схему.");
        } else {
            throw Exception("Failed to load block: ${resp.body}");
        }
    }

    static Future<String> createBlock(double complexity) async {
        final int complexityInt = complexity.round();
        final resp = await http.post(Uri.parse('$API_ENDPOINT/block?complexity=${(complexityInt.toDouble() / 100).toStringAsFixed(2)}'));
        if (resp.statusCode != 200) {
            throw Exception("Failed to create block: ${resp.body}");
        }
        return jsonDecode(resp.body)['id'];
    }

    // TODO: accept only double-like input (e.g. 3.1415 or 100 but not abcdef or 3.1.2.3)
    static Future<bool> checkAnswer(String id, String answer) async {
        final resp = await http.get(Uri.parse('$API_ENDPOINT/block/$id/check?answer=$answer'));
        if (resp.statusCode == 404) {
            throw Exception("404 not found [${resp.body}]");
        }
        if (resp.statusCode == 400) {
            // bad answer
            return false;
        }
        if (resp.statusCode != 200) {
            throw Exception("not OK status code: $resp.statusCode [${resp.body}]");
        }
        return jsonDecode(resp.body)["result"] as bool;
    }
}
