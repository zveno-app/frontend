import 'draw3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Api {
    static Future<Block> getBlock(String id) async {
        final resp = await http.get(Uri.parse('http://localhost:8080/block/$id'));
        if (resp.statusCode == 200) {
            return Block.fromJson(jsonDecode(resp.body));
        } else {
            throw Exception("Failed to load block: ${resp.body}");
        }
    }

    static Future<void> createBlock(String id, double complexity) async {
        final resp = await http.post(Uri.parse('http://localhost:8080/block/$id?complexity=${complexity.toStringAsFixed(2)}'));
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
}
