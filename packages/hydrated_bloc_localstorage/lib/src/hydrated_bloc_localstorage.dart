import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:localstorage/localstorage.dart';

/// Implementation of [HydratedStorage] which uses `PathProvider` and `Hive`
/// to persist and retrieve state changes from the local device.
class HydratedBlocLocalStorage implements HydratedStorage {
  static HydratedBlocLocalStorage _instance;

  /// Returns an instance of [HydratedBlocLocalStorage].
  /// [storageDirectory] can optionally be provided.
  /// By default, [Directory.current] is used.
  static Future<HydratedBlocLocalStorage> getInstance({
    Directory storageDirectory,
  }) async {
    if (_instance != null) {
      return _instance;
    }

    _instance = HydratedBlocLocalStorage._();
    return _instance;
  }

  HydratedBlocLocalStorage._();

  @override
  Future<void> clear() async {
    if (_box.isOpen) {
      _instance = null;
      return await _box.deleteFromDisk();
    } else {
      return null;
    }
  }

  @override
  Future<void> delete(String key) {
    if (_box.isOpen) {
      return _box.delete(key);
    } else {
      return null;
    }
  }

  @override
  dynamic read(String key) {
    if (_box.isOpen) {
      return _box.get(key);
    } else {
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic value) {
    if (_box.isOpen) {
      return _box.put(key, value);
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
