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
    debugPrint('Initializing speech service...');
    _isEnabled = await _speechToText.initialize(
      onError: (val) => debugPrint('Speech error: $val'),
      onStatus: (val) => debugPrint('Speech status: $val'),
    );
    debugPrint('Speech service initialized: $_isEnabled');
    return _isEnabled;
  }

  @override
  Future<void> startListening({required Function(String) onResult}) async {
    debugPrint('startListening called, _isEnabled: $_isEnabled');
    if (!_isEnabled) {
      debugPrint('Speech not enabled, initializing...');
      await init();
    }

    if (_isEnabled) {
      debugPrint('Starting to listen...');
      await _speechToText.listen(
        onResult: (result) {
          debugPrint(
              'onResult callback: ${result.recognizedWords}, isFinal: ${result.finalResult}');
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
      debugPrint('Listen started, isListening: ${_speechToText.isListening}');
    } else {
      debugPrint('Speech service not enabled after init!');
    }
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
