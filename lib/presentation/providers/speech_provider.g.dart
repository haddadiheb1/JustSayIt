// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$speechStateHash() => r'25eb5985d3fa446eff9212125123ffbe5090dd02';

/// See also [SpeechState].
@ProviderFor(SpeechState)
final speechStateProvider =
    AutoDisposeNotifierProvider<SpeechState, String>.internal(
  SpeechState.new,
  name: r'speechStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$speechStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeechState = AutoDisposeNotifier<String>;
String _$listeningStateHash() => r'f5cd899a58477b5fdcc979544d5e4f2802d4bbcd';

/// See also [ListeningState].
@ProviderFor(ListeningState)
final listeningStateProvider =
    AutoDisposeNotifierProvider<ListeningState, bool>.internal(
  ListeningState.new,
  name: r'listeningStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$listeningStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ListeningState = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
