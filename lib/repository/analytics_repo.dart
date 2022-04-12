import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/service_api.dart';

// TODO(hasan): We should add some DAO models for saving and sending analytics to server after some periods of time, https://gitlab.iais.co/deliver/wiki/-/issues/420
// TODO(hasan): Add some analytics for DAO functions, https://gitlab.iais.co/deliver/wiki/-/issues/420
class AnalyticsRepo {
  /// All type of GRPC requests in application
  static final Map<String, int> _requestsFrequency = {};

  /// All type of DAO requests in application
  static final Map<String, int> _daoFrequency = {};

  /// Rooms or all other pages in app will be count in times of seeing
  static final Map<String, int> _pageViewFrequency = {};

  /// All type of GRPC requests in application
  Map<String, int> get requestsFrequency => _requestsFrequency;

  /// Rooms or all other pages in app will be count in times of seeing
  Map<String, int> get pageViewFrequency => _pageViewFrequency;

  /// All type of DAO requests in application
  Map<String, int> get daoFrequency => _daoFrequency;

  final StreamController<void> _events = StreamController.broadcast();

  final StreamController<void> _daoEvents = StreamController.broadcast();

  /// All events of changes except dao changes
  Stream<void> get events => _events.stream;

  /// All events of dao objects
  Stream<void> get daoEvents => _daoEvents.stream;

  /// CountUp
  static void countUp(Map<String, int> map, String key) =>
      map[key] = (map[key] ?? 0) + 1;

  void incRF(String key) {
    if (!kDebugMode) return;
    _events.add(null);
    countUp(_requestsFrequency, key);
  }

  void incPVF(String key) {
    if (!kDebugMode) return;
    _events.add(null);
    countUp(_pageViewFrequency, key);
  }

  void incDao(String key) {
    if (!kDebugMode) return;
    _daoEvents.add(null);
    countUp(_daoFrequency, key);
  }
}

/// GRPC Client Interceptor for capturing all request in application
class AnalyticsClientInterceptor implements ClientInterceptor {
  static final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    _analyticsRepo.incRF("unary${method.path}");
    return invoker(method, request, options);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    _analyticsRepo.incRF("stream${method.path}");
    return invoker(method, requests, options);
  }
}
