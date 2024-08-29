import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DbHelper {
  final SupabaseClient _client;

  DbHelper._privateConstructor(this._client);

  static Future<DbHelper> create() async {
    // config.json dosyasını oku
    final String configData = await rootBundle.loadString('data/config.json');
    final Map<String, dynamic> config = json.decode(configData);

    final String supabaseUrl = config['supabaseUrl'];
    final String supabaseAnonKey = config['supabaseAnonKey'];

    final SupabaseClient client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    return DbHelper._privateConstructor(client);
  }

  Future<List<Map<String, dynamic>>> getWords() async {
    final List<Map<String, dynamic>> data =
        await _client.from('words').select();

    return data;
  }

  Future<void> insertWord(Map<String, dynamic> word) async {
    await _client.from('words').insert(word);
  }

  Future<void> updateWord(int id, Map<String, dynamic> word) async {
    await _client.from('words').update(word).eq('id', id);
  }

  Future<void> deleteWord(int id) async {
    await _client.from('words').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> upsertWord(
      Map<String, dynamic> word) async {
    final List<Map<String, dynamic>> data =
        await _client.from('words').upsert(word).select();

    return data;
  }

  Future<List<Map<String, dynamic>>> filterWordsByTitle(String title) async {
    final List<Map<String, dynamic>> data = await _client
        .from('words')
        .select('title, type, mean')
        .eq('title', title);

    return data;
  }
}
