import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final speechServiceProvider =
    Provider<SpeechService>((ref) => SpeechServiceImpl());

abstract class SpeechService {
  Future<bool> init();
  Future<void> startListening({required Function(String) onResult});
  Future<void> stopListening();
  bool get isListening;
}

class SpeechServiceImpl implements SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isEnabled = false;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<bool> init() async {
    _isEnabled = await _speechToText.initialize(
      onError: (val) => debugPrint('onError: $val'),
      onStatus: (val) => debugPrint('onStatus: $val'),
    );
    return _isEnabled;
  }

  @override
  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isEnabled) {
      await init();
    }

    if (_isEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
    }
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
