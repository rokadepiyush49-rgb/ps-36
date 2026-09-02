import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Wraps on-device speech recognition.
///
/// Voice is the primary way a citizen files a report, so the service degrades
/// gracefully: when recognition is unavailable the report screen falls back to
/// the typed field rather than blocking the flow.
class SpeechService {
  SpeechService(this._speech);

  final stt.SpeechToText _speech;

  bool _available = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_available) return true;
    _available = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _available;
  }

  /// Locale list matters here: the product targets multilingual reporting, and
  /// the device locale is the right default for a citizen speaking their own
  /// language.
  Future<void> listen({
    required void Function(String text) onResult,
    void Function()? onDone,
    String? localeId,
  }) async {
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) onDone?.call();
      },
    );
  }

  Future<void> stop() async {
    if (_speech.isListening) await _speech.stop();
  }

  Future<List<String>> locales() async {
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }
}

final speechServiceProvider = Provider<SpeechService>(
  (ref) => SpeechService(stt.SpeechToText()),
);
