import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts _flutterTts = FlutterTts();

  TtsHelper() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts
        .setLanguage("en-US"); // İngilizce (Amerikan) dilini ayarlar
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
