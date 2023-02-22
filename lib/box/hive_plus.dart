// ignore_for_file: type_annotate_public_apis

import 'package:deliver/repository/analytics_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

Future<BoxPlus<R>> gen<R>(Future<Box<R>> boxFuture) async =>
    BoxPlus(await boxFuture);

class BoxPlus<E> {
  static final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();

  final Box<E> box;

  BoxPlus(this.box);

  E? get(key, {E? defaultValue}) {
    if (kDebugMode) _analyticsRepo.incDao("get/${box.name}");
    return box.get(key, defaultValue: defaultValue);
  }

  Stream<BoxEvent> watch({key}) {
    if (kDebugMode) _analyticsRepo.incDao("watch/${box.name}");
    return box.watch(key: key);
  }

  Future<void> put(key, E value) {
    if (kDebugMode) _analyticsRepo.incDao("put/${box.name}");
    return box.put(key, value);
  }

  Future<void> delete(key) {
    if (kDebugMode) _analyticsRepo.incDao("delete/${box.name}");
    return box.delete(key);
  }

  Future<void> clear() {
    if (kDebugMode) _analyticsRepo.incDao("clear/${box.name}");
    return box.clear();
  }

  Future<void> close() {
    if (kDebugMode) _analyticsRepo.incDao("close/${box.name}");
    return box.close();
  }

  bool get isEmpty {
    if (kDebugMode) _analyticsRepo.incDao("isEmpty/${box.name}");
    return box.isEmpty;
  }

  Iterable<E> get values {
    if (kDebugMode) _analyticsRepo.incDao("values/${box.name}");
    return box.values;
  }
}
