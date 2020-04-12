import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:localstorage/localstorage.dart';

/// Implementation of [HydratedStorage] which uses `PathProvider` and `Hive`
/// to persist and retrieve state changes from the local device.
class HydratedBlocLocalStorage implements HydratedStorage {
  static HydratedBlocLocalStorage _instance;

  LocalStorage _storage;

  /// Returns an instance of [HydratedBlocLocalStorage].
  /// [storageDirectory] can optionally be provided.
  /// By default, [Directory.current] is used.
  static Future<HydratedBlocLocalStorage> getInstance({
    Directory storageDirectory,
  }) async {
    if (_instance != null) {
      return _instance;
    }
    final storage = LocalStorage('hydrated_bloc.json');
    await storage.ready;
    _instance = HydratedBlocLocalStorage._(storage);
    return _instance;
  }

  HydratedBlocLocalStorage._(this._storage);

  @override
  Future<void> clear() async {
    await _storage.clear();
  }

  @override
  Future<void> delete(String key) async {
    return await _storage.deleteItem(key);
  }

  @override
  dynamic read(String key) {
    return _storage.getItem(key);
  }

  @override
  Future<void> write(String key, dynamic value) async {
    return await _storage.setItem(key, value);
  }
}

/// A variant of [HydratedBlocDelegate] which can build
/// a [HydratedBlocLocalStorage] instance using `build()`
class HydratedBlocLocalStorageDelegate extends HydratedBlocDelegate {
  /// Constructs a [HydratedBlocLocalStorageDelegate] object with the optional [storage]
  HydratedBlocLocalStorageDelegate(HydratedStorage storage) : super(storage);

  /// Builds a [HydratedBlocLocalStorageDelegate] with an instance of [HydratedBlocLocalStorage],
  /// optionally using the [storageDirectory] parameter
  static Future<HydratedBlocLocalStorageDelegate> build({Directory storageDirectory}) async =>
      HydratedBlocLocalStorageDelegate(await HydratedBlocLocalStorage.getInstance(storageDirectory: storageDirectory));
}

abstract class HydratedBlocHelper<A, S> extends HydratedBloc<A, S> {
  final HydratedStorage storage = (BlocSupervisor.delegate as HydratedBlocDelegate).storage;
  final int _id;
  @override
  String get id => '$_id';
  HydratedBlocHelper(this._id) : super();

  dynamic readState(String key) {
    return storage.read('\$$id' + key);
  }

  Future<void> saveState(String key, dynamic value) {
    return storage.write('\$$id' + key, value);
  }

  Future<void> deleteState(String key) async {
    return storage.delete('\$$id' + key);
  }

  /// Warning, this will delete all state from all [HydratedBloc]s regardless of [id]
  Future<void> clearState() => storage.clear();
}
