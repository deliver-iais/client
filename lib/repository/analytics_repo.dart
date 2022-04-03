import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:grpc/service_api.dart';

/// TODO: We should add some DAO models for saving and sending analytics to server after some periods of time
class AnalyticsRepo {
  /// All type of GRPC requests in application
  static final Map<String, int> _requestsFrequency = {};

  /// Rooms or all other pages in app will be count in times of seeing
  static final Map<String, int> _pageViewFrequency = {};

  /// All type of GRPC requests in application
  Map<String, int> get requestsFrequency => _requestsFrequency;

  /// Rooms or all other pages in app will be count in times of seeing
  Map<String, int> get pageViewFrequency => _pageViewFrequency;

  final StreamController<void> _events = StreamController.broadcast();

  /// All events of changes
  Stream<void> get events => _events.stream;

  /// CountUp
  static void countUp(Map<String, int> map, String key) =>
      map[key] = (map[key] ?? 0) + 1;

  void incRF(String key) {
    _events.add(null);
    countUp(_requestsFrequency, key);
  }

  void incPVF(String key) {
    _events.add(null);
    countUp(_pageViewFrequency, key);
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
