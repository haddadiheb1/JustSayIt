import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speech_provider.g.dart';

@riverpod
class SpeechState extends _$SpeechState {
  @override
  String build() {
    return "";
  }

  void update(String text) {
    state = text;
  }
}

@riverpod
class ListeningState extends _$ListeningState {
  @override
  bool build() => false;

  void setListening(bool isListening) {
    state = isListening;
  }
}

@riverpod
class SpeechLevel extends _$SpeechLevel {
  @override
  double build() => 0.0;

  void update(double level) {
    state = level;
  }
}
