import 'draw3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String API_ENDPOINT = 'http://localhost:8080/'; 

class Api {
    static Future<Block> getBlock(String id) async {
        final resp = await http.get(Uri.parse('$API_ENDPOINT/block/$id'));
        if (resp.statusCode == 200) {
            return Block.fromJson(jsonDecode(resp.body));
        } else {
            throw Exception("Failed to load block: ${resp.body}");
        }
    }

    static Future<void> createBlock(String id, double complexity) async {
        final resp = await http.post(Uri.parse('$API_ENDPOINT/block/$id?complexity=${complexity.toStringAsFixed(3)}'));
        if (resp.statusCode == 409) {
            return;
        } else if (resp.statusCode != 200) {
            throw Exception("Failed to create block: ${resp.body}");
        }
    }

    static Future<Block> createAndGet(String id, double complexity) async {
        await createBlock(id, complexity);
        return await getBlock(id);
    }

    // TODO: accept only double-like input (e.g. 3.1415 or 100 but not abcdef or 3.1.2.3)
    static Future<bool> checkAnswer(String id, String answer) async {
        final resp = await http.get(Uri.parse('$API_ENDPOINT/check/$id?answer=$answer'));
        return resp.statusCode != 400 && (jsonDecode(resp.body) as bool);
    }
}
