// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addNoteHash() => r'711d66765691cc57f63d31880dcac34db5c0729c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [addNote].
@ProviderFor(addNote)
const addNoteProvider = AddNoteFamily();

/// See also [addNote].
class AddNoteFamily extends Family<AsyncValue<void>> {
  /// See also [addNote].
  const AddNoteFamily();

  /// See also [addNote].
  AddNoteProvider call(
    NoteModel note,
  ) {
    return AddNoteProvider(
      note,
    );
  }

  @override
  AddNoteProvider getProviderOverride(
    covariant AddNoteProvider provider,
  ) {
    return call(
      provider.note,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'addNoteProvider';
}

/// See also [addNote].
class AddNoteProvider extends AutoDisposeFutureProvider<void> {
  /// See also [addNote].
  AddNoteProvider(
    NoteModel note,
  ) : this._internal(
          (ref) => addNote(
            ref as AddNoteRef,
            note,
          ),
          from: addNoteProvider,
          name: r'addNoteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addNoteHash,
          dependencies: AddNoteFamily._dependencies,
          allTransitiveDependencies: AddNoteFamily._allTransitiveDependencies,
          note: note,
        );

  AddNoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.note,
  }) : super.internal();

  final NoteModel note;

  @override
  Override overrideWith(
    FutureOr<void> Function(AddNoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AddNoteProvider._internal(
        (ref) => create(ref as AddNoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        note: note,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _AddNoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddNoteProvider && other.note == note;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, note.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AddNoteRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `note` of this provider.
  NoteModel get note;
}

class _AddNoteProviderElement extends AutoDisposeFutureProviderElement<void>
    with AddNoteRef {
  _AddNoteProviderElement(super.provider);

  @override
  NoteModel get note => (origin as AddNoteProvider).note;
}

String _$deleteNoteHash() => r'5a1d71bf16a6e6e640111886cbea143a7c239c50';

/// See also [deleteNote].
@ProviderFor(deleteNote)
const deleteNoteProvider = DeleteNoteFamily();

/// See also [deleteNote].
class DeleteNoteFamily extends Family<AsyncValue<void>> {
  /// See also [deleteNote].
  const DeleteNoteFamily();

  /// See also [deleteNote].
  DeleteNoteProvider call(
    String id,
  ) {
    return DeleteNoteProvider(
      id,
    );
  }

  @override
  DeleteNoteProvider getProviderOverride(
    covariant DeleteNoteProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deleteNoteProvider';
}

/// See also [deleteNote].
class DeleteNoteProvider extends AutoDisposeFutureProvider<void> {
  /// See also [deleteNote].
  DeleteNoteProvider(
    String id,
  ) : this._internal(
          (ref) => deleteNote(
            ref as DeleteNoteRef,
            id,
          ),
          from: deleteNoteProvider,
          name: r'deleteNoteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deleteNoteHash,
          dependencies: DeleteNoteFamily._dependencies,
          allTransitiveDependencies:
              DeleteNoteFamily._allTransitiveDependencies,
          id: id,
        );

  DeleteNoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<void> Function(DeleteNoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteNoteProvider._internal(
        (ref) => create(ref as DeleteNoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DeleteNoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteNoteProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeleteNoteRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DeleteNoteProviderElement extends AutoDisposeFutureProviderElement<void>
    with DeleteNoteRef {
  _DeleteNoteProviderElement(super.provider);

  @override
  String get id => (origin as DeleteNoteProvider).id;
}

String _$updateNoteHash() => r'3f3422ab0139a34e17d972e7cfb3c17ad91db1f3';

/// See also [updateNote].
@ProviderFor(updateNote)
const updateNoteProvider = UpdateNoteFamily();

/// See also [updateNote].
class UpdateNoteFamily extends Family<AsyncValue<void>> {
  /// See also [updateNote].
  const UpdateNoteFamily();

  /// See also [updateNote].
  UpdateNoteProvider call(
    NoteModel note,
  ) {
    return UpdateNoteProvider(
      note,
    );
  }

  @override
  UpdateNoteProvider getProviderOverride(
    covariant UpdateNoteProvider provider,
  ) {
    return call(
      provider.note,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateNoteProvider';
}

/// See also [updateNote].
class UpdateNoteProvider extends AutoDisposeFutureProvider<void> {
  /// See also [updateNote].
  UpdateNoteProvider(
    NoteModel note,
  ) : this._internal(
          (ref) => updateNote(
            ref as UpdateNoteRef,
            note,
          ),
          from: updateNoteProvider,
          name: r'updateNoteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateNoteHash,
          dependencies: UpdateNoteFamily._dependencies,
          allTransitiveDependencies:
              UpdateNoteFamily._allTransitiveDependencies,
          note: note,
        );

  UpdateNoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.note,
  }) : super.internal();

  final NoteModel note;

  @override
  Override overrideWith(
    FutureOr<void> Function(UpdateNoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateNoteProvider._internal(
        (ref) => create(ref as UpdateNoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        note: note,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _UpdateNoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateNoteProvider && other.note == note;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, note.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateNoteRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `note` of this provider.
  NoteModel get note;
}

class _UpdateNoteProviderElement extends AutoDisposeFutureProviderElement<void>
    with UpdateNoteRef {
  _UpdateNoteProviderElement(super.provider);

  @override
  NoteModel get note => (origin as UpdateNoteProvider).note;
}

String _$initializeNotesHash() => r'fbc2ec83e2cd76cda66798c6057cfd385f6af1af';

/// See also [initializeNotes].
@ProviderFor(initializeNotes)
final initializeNotesProvider = AutoDisposeFutureProvider<void>.internal(
  initializeNotes,
  name: r'initializeNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initializeNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitializeNotesRef = AutoDisposeFutureProviderRef<void>;
String _$noteListHash() => r'f135f52aae2f14a16fc9d8d682a7a6efe159add6';

/// See also [NoteList].
@ProviderFor(NoteList)
final noteListProvider =
    AutoDisposeStreamNotifierProvider<NoteList, List<NoteModel>>.internal(
  NoteList.new,
  name: r'noteListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$noteListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NoteList = AutoDisposeStreamNotifier<List<NoteModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
