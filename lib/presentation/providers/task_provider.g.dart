// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addTaskHash() => r'38677d8e0dd916604023f60d358c8eca264720f0';

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
    TaskCategory? category,
  }) {
    return AddTaskProvider(
      title: title,
      date: date,
      category: category,
    );
  }

  @override
  AddTaskProvider getProviderOverride(
    covariant AddTaskProvider provider,
  ) {
    return call(
      title: provider.title,
      date: provider.date,
      category: provider.category,
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
    TaskCategory? category,
  }) : this._internal(
          (ref) => addTask(
            ref as AddTaskRef,
            title: title,
            date: date,
            category: category,
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
          category: category,
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
    required this.category,
  }) : super.internal();

  final String title;
  final DateTime date;
  final TaskCategory? category;

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
        category: category,
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
        other.date == date &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, title.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AddTaskRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `title` of this provider.
  String get title;

  /// The parameter `date` of this provider.
  DateTime get date;

  /// The parameter `category` of this provider.
  TaskCategory? get category;
}

class _AddTaskProviderElement extends AutoDisposeFutureProviderElement<void>
    with AddTaskRef {
  _AddTaskProviderElement(super.provider);

  @override
  String get title => (origin as AddTaskProvider).title;
  @override
  DateTime get date => (origin as AddTaskProvider).date;
  @override
  TaskCategory? get category => (origin as AddTaskProvider).category;
}

String _$deleteTaskHash() => r'e0e396f5ef3a2d68d725537a388d4c9c021faa23';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
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

String _$toggleTaskHash() => r'ad3024554e14d49556ba99c750abcaae6ff0ecb6';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
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

String _$updateTaskHash() => r'a5b6d0da4bf884014e818b689c27618aaa1ee4f2';

/// See also [updateTask].
@ProviderFor(updateTask)
const updateTaskProvider = UpdateTaskFamily();

/// See also [updateTask].
class UpdateTaskFamily extends Family<AsyncValue<void>> {
  /// See also [updateTask].
  const UpdateTaskFamily();

  /// See also [updateTask].
  UpdateTaskProvider call(
    Task task,
  ) {
    return UpdateTaskProvider(
      task,
    );
  }

  @override
  UpdateTaskProvider getProviderOverride(
    covariant UpdateTaskProvider provider,
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
  String? get name => r'updateTaskProvider';
}

/// See also [updateTask].
class UpdateTaskProvider extends AutoDisposeFutureProvider<void> {
  /// See also [updateTask].
  UpdateTaskProvider(
    Task task,
  ) : this._internal(
          (ref) => updateTask(
            ref as UpdateTaskRef,
            task,
          ),
          from: updateTaskProvider,
          name: r'updateTaskProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateTaskHash,
          dependencies: UpdateTaskFamily._dependencies,
          allTransitiveDependencies:
              UpdateTaskFamily._allTransitiveDependencies,
          task: task,
        );

  UpdateTaskProvider._internal(
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
    FutureOr<void> Function(UpdateTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateTaskProvider._internal(
        (ref) => create(ref as UpdateTaskRef),
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
    return _UpdateTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateTaskProvider && other.task == task;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, task.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateTaskRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `task` of this provider.
  Task get task;
}

class _UpdateTaskProviderElement extends AutoDisposeFutureProviderElement<void>
    with UpdateTaskRef {
  _UpdateTaskProviderElement(super.provider);

  @override
  Task get task => (origin as UpdateTaskProvider).task;
}

String _$initializeAppHash() => r'5224b3d1f9e05d0b8b9e389180ac478c9b545eef';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitializeAppRef = AutoDisposeFutureProviderRef<void>;
String _$taskListHash() => r'f616151c60cb81ff3e25a2846af8cbdd74af625b';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
