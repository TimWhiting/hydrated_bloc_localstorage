import 'dart:io';

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
    final storage = LocalStorage('hydrated_bloc');
    await storage.ready;
    _instance = HydratedBlocLocalStorage._(storage);
    return _instance;
  }

  HydratedBlocLocalStorage._(this._storage);

  @override
  Future<void> clear() async {
    if (await _storage.ready) {
      _instance = null;
      await _storage.clear();
      return await _storage.dispose();
    } else {
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    if (await _storage.ready) {
      return _storage.deleteItem(key);
    } else {
      return null;
    }
  }

  @override
  dynamic read(String key) async {
    if (await _storage.ready) {
      return _storage.getItem(key);
    } else {
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    if (await _storage.ready) {
      return _storage.setItem(key, value);
    } else {
      return null;
    }
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
