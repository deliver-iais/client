import 'dart:async';

import 'package:deliver/box/dao/show_case_dao.dart';
import 'package:deliver/box/show_case.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:deliver_public_protocol/pub/v1/service_discovery.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ShowCaseRepo {
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _showCaseDao = GetIt.I.get<ShowCaseDao>();
  final _completerMap = <int, Completer<(List<ShowCase>?, bool)>>{};

  Future<(List<ShowCase>?, bool)> getShowCasePage(
    int page, {
    int limit = SHOWCASE_PAGE_SIZE,
  }) async {
    var completer = _completerMap[page];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap[page] = completer;
    final localModifyTime = await _showCaseDao.getShowcaseModifyTime(page) ?? 0;
    final result = await fetchShowCasePage(page, localModifyTime, limit: limit);
    if (result != null &&
        (result.showcase.isNotEmpty ||
            result.lastTimeModified.toInt() > localModifyTime)) {
      completer.complete(
        (
          await _saveFetchedShowCases(
            result.showcase,
            page,
            result.lastTimeModified.toInt(),
          ),
          result.finished
        ),
      );
    } else {
      final (List<ShowCase> showcases, bool isFinished) =
          await _showCaseDao.getShowCasePage(page, pageSize: limit);
      completer.complete((showcases, isFinished));
    }
    return completer.future;
  }

  Future<GetShowCaseRes?> fetchShowCasePage(
    int page,
    int modifyTime, {
    int limit = SHOWCASE_PAGE_SIZE,
  }) async {
    try {
      final result = await _sdr.serviceDiscoveryServiceClient.getShowCases(
        GetShowCaseReq()
          ..limit = Int64(limit)
          ..userPreference = await getUserPreferencePB()
          ..lastTimeModified = Int64(modifyTime)
          ..pointer = Int64(page * limit),
      );
      return result;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Showcase_Type findShowCaseType(String showCaseJson) {
    return Showcase.fromJson(showCaseJson).whichType();
  }

  Future<List<ShowCase>> _saveFetchedShowCases(
    List<Showcase> getShowCases,
    int page,
    int lastModifyTime, {
    int limit = SHOWCASE_PAGE_SIZE,
  }) async {
    if (page == 0) {
      await _showCaseDao.clearAllShowcase();
    }
    final showCasesList = <ShowCase>[];
    for (var i = 0; i < getShowCases.length; i++) {
      final insertedShowCase = ShowCase(
        index: page * limit + i,
        json: getShowCases[i].writeToJson(),
      );
      showCasesList.add(insertedShowCase);
      await _showCaseDao.save(insertedShowCase);
    }
    await _showCaseDao.saveShowcaseModifyTime(page, lastModifyTime);
    return showCasesList;
  }
}
