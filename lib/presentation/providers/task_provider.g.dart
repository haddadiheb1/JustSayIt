// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addTaskHash() => r'ef2d046ac2ca6605866e265aca82c156acfd3969';

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

/// See also [addTask].
@ProviderFor(addTask)
const addTaskProvider = AddTaskFamily();

/// See also [addTask].
class AddTaskFamily extends Family<AsyncValue<void>> {
  /// See also [addTask].
  const AddTaskFamily();

  /// See also [addTask].
  AddTaskProvider call({
    required String title,
    required DateTime date,
  }) {
    return AddTaskProvider(
      title: title,
      date: date,
    );
  }

  @override
  AddTaskProvider getProviderOverride(
    covariant AddTaskProvider provider,
  ) {
    return call(
      title: provider.title,
      date: provider.date,
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
  String? get name => r'addTaskProvider';
}

/// See also [addTask].
class AddTaskProvider extends AutoDisposeFutureProvider<void> {
  /// See also [addTask].
  AddTaskProvider({
    required String title,
    required DateTime date,
  }) : this._internal(
          (ref) => addTask(
            ref as AddTaskRef,
            title: title,
            date: date,
          ),
          from: addTaskProvider,
          name: r'addTaskProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addTaskHash,
          dependencies: AddTaskFamily._dependencies,
          allTransitiveDependencies: AddTaskFamily._allTransitiveDependencies,
          title: title,
          date: date,
        );

  AddTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.title,
    required this.date,
  }) : super.internal();

  final String title;
  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<void> Function(AddTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AddTaskProvider._internal(
        (ref) => create(ref as AddTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        title: title,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _AddTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddTaskProvider &&
        other.title == title &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, title.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AddTaskRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `title` of this provider.
  String get title;

  /// The parameter `date` of this provider.
  DateTime get date;
}

class _AddTaskProviderElement extends AutoDisposeFutureProviderElement<void>
    with AddTaskRef {
  _AddTaskProviderElement(super.provider);

  @override
  String get title => (origin as AddTaskProvider).title;
  @override
  DateTime get date => (origin as AddTaskProvider).date;
}

String _$deleteTaskHash() => r'fa1c88c64a326bccc25425950d02043da3e4e81b';

/// See also [deleteTask].
@ProviderFor(deleteTask)
const deleteTaskProvider = DeleteTaskFamily();

/// See also [deleteTask].
class DeleteTaskFamily extends Family<AsyncValue<void>> {
  /// See also [deleteTask].
  const DeleteTaskFamily();

  /// See also [deleteTask].
  DeleteTaskProvider call(
    String id,
  ) {
    return DeleteTaskProvider(
      id,
    );
  }

  @override
  DeleteTaskProvider getProviderOverride(
    covariant DeleteTaskProvider provider,
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
  String? get name => r'deleteTaskProvider';
}

/// See also [deleteTask].
class DeleteTaskProvider extends AutoDisposeFutureProvider<void> {
  /// See also [deleteTask].
  DeleteTaskProvider(
    String id,
  ) : this._internal(
          (ref) => deleteTask(
            ref as DeleteTaskRef,
            id,
          ),
          from: deleteTaskProvider,
          name: r'deleteTaskProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deleteTaskHash,
          dependencies: DeleteTaskFamily._dependencies,
          allTransitiveDependencies:
              DeleteTaskFamily._allTransitiveDependencies,
          id: id,
        );

  DeleteTaskProvider._internal(
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
    FutureOr<void> Function(DeleteTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteTaskProvider._internal(
        (ref) => create(ref as DeleteTaskRef),
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
    return _DeleteTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteTaskProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeleteTaskRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DeleteTaskProviderElement extends AutoDisposeFutureProviderElement<void>
    with DeleteTaskRef {
  _DeleteTaskProviderElement(super.provider);

  @override
  String get id => (origin as DeleteTaskProvider).id;
}

String _$toggleTaskHash() => r'70e8e007c31362c8f46807ce2989d955459865fc';

/// See also [toggleTask].
@ProviderFor(toggleTask)
const toggleTaskProvider = ToggleTaskFamily();

/// See also [toggleTask].
class ToggleTaskFamily extends Family<AsyncValue<void>> {
  /// See also [toggleTask].
  const ToggleTaskFamily();

  /// See also [toggleTask].
  ToggleTaskProvider call(
    Task task,
  ) {
    return ToggleTaskProvider(
      task,
    );
  }

  @override
  ToggleTaskProvider getProviderOverride(
    covariant ToggleTaskProvider provider,
  ) {
    return call(
      provider.task,
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
  String? get name => r'toggleTaskProvider';
}

/// See also [toggleTask].
class ToggleTaskProvider extends AutoDisposeFutureProvider<void> {
  /// See also [toggleTask].
  ToggleTaskProvider(
    Task task,
  ) : this._internal(
          (ref) => toggleTask(
            ref as ToggleTaskRef,
            task,
          ),
          from: toggleTaskProvider,
          name: r'toggleTaskProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$toggleTaskHash,
          dependencies: ToggleTaskFamily._dependencies,
          allTransitiveDependencies:
              ToggleTaskFamily._allTransitiveDependencies,
          task: task,
        );

  ToggleTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.task,
  }) : super.internal();

  final Task task;

  @override
  Override overrideWith(
    FutureOr<void> Function(ToggleTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ToggleTaskProvider._internal(
        (ref) => create(ref as ToggleTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        task: task,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _ToggleTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ToggleTaskProvider && other.task == task;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, task.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ToggleTaskRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `task` of this provider.
  Task get task;
}

class _ToggleTaskProviderElement extends AutoDisposeFutureProviderElement<void>
    with ToggleTaskRef {
  _ToggleTaskProviderElement(super.provider);

  @override
  Task get task => (origin as ToggleTaskProvider).task;
}

String _$initializeAppHash() => r'ecc74bb483519fd3b69410575be413a2895033f1';

/// See also [initializeApp].
@ProviderFor(initializeApp)
final initializeAppProvider = AutoDisposeFutureProvider<void>.internal(
  initializeApp,
  name: r'initializeAppProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initializeAppHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InitializeAppRef = AutoDisposeFutureProviderRef<void>;
String _$taskListHash() => r'b7c43add9313d94e18ea57f8538763a2e0160ae7';

/// See also [TaskList].
@ProviderFor(TaskList)
final taskListProvider =
    AutoDisposeStreamNotifierProvider<TaskList, List<Task>>.internal(
  TaskList.new,
  name: r'taskListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskList = AutoDisposeStreamNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
