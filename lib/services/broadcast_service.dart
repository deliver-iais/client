import 'dart:async';

import 'package:background_sms/background_sms.dart';
import 'package:collection/collection.dart';
import 'package:deliver/box/broadcast_message_status_type.dart';
import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/box/broadcast_success_and_failed_count.dart';
import 'package:deliver/box/dao/broadcast_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

enum BroadcastRunningStatus {
  RUNNING,
  PAUSE,
  END,
}

class BroadcastService {
  final Map<String, Uid> _pendingBroadcastMessage = {};
  final Map<Uid, BehaviorSubject<BroadcastRunningStatus>>
      _broadcastRunningStatus = {};
  final _i18n = GetIt.I.get<I18N>();
  final _notificationForegroundService =
      GetIt.I.get<NotificationForegroundService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();

  final _broadcastDao = GetIt.I.get<BroadcastDao>();
  final _logger = GetIt.I.get<Logger>();
  final _mucDao = GetIt.I.get<MucDao>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  MessageRepo? _messageRepo;

  Future<void> startBroadcast(
    Message message,
  ) async {
    _logger.i("start broad cast");
    unawaited(
      _analyticsService.sendLogEvent(
        "sendBroadcastMessage",
      ),
    );
    unawaited(_sendMessageToBroadcastMembers(message));
    unawaited(
      _sendSmsBroadcast(
        message,
      ),
    );
  }

  BehaviorSubject<BroadcastRunningStatus>? getBroadcastRunningStatus(
    Uid broadcastRoomId,
  ) {
    if (_broadcastRunningStatus[broadcastRoomId] == null) {
      _broadcastRunningStatus[broadcastRoomId] =
          BehaviorSubject.seeded(BroadcastRunningStatus.PAUSE);
    }
    return _broadcastRunningStatus[broadcastRoomId];
  }

  String getBroadcastRunningStatusAsString(
    BroadcastRunningStatus broadcastRunningStatus,
  ) {
    switch (broadcastRunningStatus) {
      case BroadcastRunningStatus.RUNNING:
        return _i18n.get("running_broadcast");
      case BroadcastRunningStatus.PAUSE:
        return _i18n.get("pause_broadcast");
      case BroadcastRunningStatus.END:
        return _i18n.get("ended_broadcast");
    }
  }

  void pauseBroadcast(
    Uid broadcastRoomId,
  ) {
    if (_broadcastRunningStatus[broadcastRoomId] != null) {
      _broadcastRunningStatus[broadcastRoomId]!
          .add(BroadcastRunningStatus.PAUSE);
    } else {
      _broadcastRunningStatus[broadcastRoomId] =
          BehaviorSubject.seeded(BroadcastRunningStatus.PAUSE);
    }
    if (!_hasAnotherRunningBroadcast(broadcastRoomId)) {
      _notificationForegroundService.foregroundServiceStop();
    }
  }

  BroadcastRunningStatus getBroadcastRunningStatusDependOnWaitingCount(
    BroadcastRunningStatus? broadcastRunningStatus,
    int waitingCount,
  ) {
    if (broadcastRunningStatus == BroadcastRunningStatus.PAUSE ||
        broadcastRunningStatus == null) {
      if (waitingCount == 0) {
        return BroadcastRunningStatus.END;
      }
      return BroadcastRunningStatus.PAUSE;
    }

    return broadcastRunningStatus;
  }

  Future<void> resumeBroadcast(
    Uid broadcastRoomId,
    List<BroadcastStatus> waitingBroadcastList,
  ) async {
    _setBroadcastRunningStateAsActive(broadcastRoomId);
    final broadcastId = waitingBroadcastList.first.broadcastMessageId;
    final message = await _getMessageRepo.getSingleMessageFromDb(
      roomUid: broadcastRoomId,
      id: broadcastId,
    );
    if (message != null) {
      final messageBroadcastWaitingList = waitingBroadcastList
          .where((element) => !element.isSmsBroadcast)
          .toList();
      final smsBroadcastWaitingList = waitingBroadcastList
          .where((element) => element.isSmsBroadcast)
          .toList();
      unawaited(
        _sendWaitingSmsBroadcast(
          smsBroadcastWaitingList,
          message,
        ),
      );
      unawaited(
        _sendWaitingBroadcastAndCheckForAck(
          messageBroadcastWaitingList,
          message,
        ),
      );
    }
  }

  Future<void> resendFailedBroadcasts(
    Uid broadcastRoomId,
    List<BroadcastStatus> failedBroadcastList,
  ) async {
    _setBroadcastRunningStateAsActive(broadcastRoomId);
    final waitingBroadcastList = <BroadcastStatus>[];
    //set all failed broadcast as waiting
    for (final failedBroadcast in failedBroadcastList) {
      final waitingBroadcast =
          failedBroadcast.copyWith(status: BroadcastMessageStatusType.WAITING);
      await _broadcastDao.saveBroadcastStatus(
        broadcastRoomId,
        waitingBroadcast,
      );
      waitingBroadcastList.add(waitingBroadcast);
    }
    final broadcastId = failedBroadcastList.first.broadcastMessageId;
    await _broadcastDao.setBroadcastFailedCount(
      broadcastId,
      broadcastRoomId,
      0,
    );
    final message = await _getMessageRepo.getSingleMessageFromDb(
      roomUid: broadcastRoomId,
      id: broadcastId,
    );
    await _sendWaitingBroadcastAndCheckForAck(
      waitingBroadcastList,
      message!,
    );
  }

  void _setBroadcastRunningStateAsActive(Uid broadcastRoomId) {
    _notificationForegroundService.broadcastForegroundServiceStart();
    if (_broadcastRunningStatus[broadcastRoomId] == null) {
      _broadcastRunningStatus[broadcastRoomId] =
          BehaviorSubject.seeded(BroadcastRunningStatus.RUNNING);
    } else {
      _broadcastRunningStatus[broadcastRoomId]
          ?.add(BroadcastRunningStatus.RUNNING);
    }
  }

  void cancelBroadcast(
    Uid broadcastRoomId,
  ) {
    _endBroadcast(broadcastRoomId);
    _broadcastDao.clearAllBroadcastStatus(broadcastRoomId);
    _pendingBroadcastMessage
        .removeWhere((key, value) => value == broadcastRoomId);
  }

  Uid? getBroadcastPendingMessage(String packetId) =>
      _pendingBroadcastMessage[packetId];

  Stream<List<BroadcastStatus>> getAllBroadcastStatusAsStream(
    Uid broadcastRoomId,
  ) =>
      _broadcastDao.getAllBroadcastStatusAsStream(broadcastRoomId);

  Future<void> deletePendingBroadcastMessage(
    String packetId,
    Uid broadcastRoomUid,
  ) async {
    final splitPacketId = packetId.split("-");
    if (splitPacketId.length >= 4) {
      final broadcastId = getBroadcastIdFromPacketId(packetId);
      final broadcastStatus = await _broadcastDao.getBroadcastStatus(
        packetId,
        broadcastRoomUid,
      );
      if (broadcastStatus?.status == BroadcastMessageStatusType.FAILED) {
        await _broadcastDao.decreaseBroadcastFailedCount(
          broadcastId,
          broadcastRoomUid,
        );
      }
      await _broadcastDao.deleteBroadcastStatus(
        packetId,
        broadcastRoomUid,
      );
      _pendingBroadcastMessage.remove(packetId);

      await _broadcastDao.increaseBroadcastSuccessCount(
        broadcastId,
        broadcastRoomUid,
      );
    }
  }

  Future<void> _sendMessageToBroadcastMembers(
    Message message,
  ) async {
    final broadcastRoomId = message.roomUid;
    final broadcastId = message.id;
    if (broadcastId != null) {
      _setBroadcastRunningStateAsActive(message.roomUid);
      final members = (await _mucDao.getAllMembers(broadcastRoomId));
      final bcStatusList = await _setAllBroadcastMemberStatusAsWaiting(
        members,
        broadcastId,
        broadcastRoomId,
      );
      await _sendWaitingBroadcastAndCheckForAck(
        bcStatusList,
        message,
      );
    }
  }

  Future<List<Uid>?> getFirstPageOfBroadcastMembers(Uid broadcastUid) async {
    var recipientUidList = (await _mucDao.getMembersFirstPage(broadcastUid, 4))
        .map((e) => e.memberUid)
        .toList();

    if (recipientUidList.isEmpty) {
      recipientUidList = (await _mucRepo.fetchMucMembers(broadcastUid, 4))
          .map((e) => e.memberUid)
          .toList();
    }

    return recipientUidList;
  }

  bool _hasAnotherRunningBroadcast(Uid roomId) {
    return _broadcastRunningStatus.entries.firstWhereOrNull(
          (element) =>
              element.value.value == BroadcastRunningStatus.RUNNING &&
              element.key != roomId,
        ) !=
        null;
  }

  Future<List<BroadcastSuccessAndFailedCount>>
      getAllBroadcastSuccessAndFailedCount(Uid broadcastRoomId) {
    return _broadcastDao.getAllBroadcastSuccessAndFailedCount(broadcastRoomId);
  }

  Future<void> _sendWaitingBroadcastAndCheckForAck(
    List<BroadcastStatus> bcStatusList,
    Message message,
  ) async {
    final broadcastRoomId = message.roomUid;
    final broadcastId = message.id!;
    for (final bc in bcStatusList) {
      if (_broadcastRunningStatus[broadcastRoomId]?.value ==
          BroadcastRunningStatus.RUNNING) {
        final msg = message.copyWith(
          to: bc.to.asUid(),
          packetId: bc.sendingId,
          generatedBy: broadcastRoomId,
        );
        _pendingBroadcastMessage[bc.sendingId] = broadcastRoomId;

        _getMessageRepo.sendBroadcastMessageToServer(msg);
        await _broadcastDao.saveBroadcastStatus(
          broadcastRoomId,
          bc.copyWith(
            status: BroadcastMessageStatusType.SENDING,
          ),
        );
        await Future.delayed(
          const Duration(
            seconds: BROADCAST_MESSAGE_DELAY,
          ),
        );
        await _checkLastBroadcastStatus(
          bc,
          broadcastRoomId,
          broadcastId,
        );
      } else {
        break;
      }
    }
    await _setBroadcastAsEnded(broadcastRoomId);
  }

  Future<void> _setBroadcastAsEnded(
    Uid broadcastRoomId,
  ) async {
    if (_broadcastRunningStatus[broadcastRoomId]?.value ==
        BroadcastRunningStatus.RUNNING) {
      final hasWaitingBroadcastMessage = (await _broadcastDao
                  .getAllBroadcastStatus(broadcastRoomId))
              .firstWhereOrNull(
            (element) => element.status == BroadcastMessageStatusType.WAITING,
          ) !=
          null;
      if (!hasWaitingBroadcastMessage) {
        await _endBroadcast(broadcastRoomId);
      }
    }
  }

  Future<void> _endBroadcast(Uid broadcastRoomId) async {
    _broadcastRunningStatus[broadcastRoomId]?.add(
      BroadcastRunningStatus.END,
    );
    if (!_hasAnotherRunningBroadcast(broadcastRoomId)) {
      await _notificationForegroundService.foregroundServiceStop();
    }
  }

  Future<void> _checkLastBroadcastStatus(
    BroadcastStatus bc,
    Uid broadcastRoomId,
    int broadcastId,
  ) async {
    final broadcastMessageRoomUid = _pendingBroadcastMessage[bc.sendingId];

    if (broadcastMessageRoomUid != null) {
      await _broadcastDao.saveBroadcastStatus(
        broadcastRoomId,
        bc.copyWith(status: BroadcastMessageStatusType.FAILED),
      );
      await _broadcastDao.increaseBroadcastFailedCount(
        broadcastId,
        broadcastRoomId,
      );
    }
  }

  Future<List<BroadcastStatus>> _setAllBroadcastMemberStatusAsWaiting(
    Iterable<Member?> members,
    int broadcastId,
    Uid broadcastRoomId,
  ) async {
    final bcStatusList = <BroadcastStatus>[];
    for (final member in members) {
      final packetId = await _getMessageRepo.createBroadcastMessagePackedId(
        member!.memberUid,
        broadcastId,
      );
      final broadcastStatus = BroadcastStatus(
        sendingId: packetId,
        broadcastMessageId: broadcastId,
        status: BroadcastMessageStatusType.WAITING,
        to: member.memberUid.asString(),
      );

      await _broadcastDao.saveBroadcastStatus(
        broadcastRoomId,
        broadcastStatus,
      );
      bcStatusList.add(broadcastStatus);
    }
    return bcStatusList;
  }

  String getBroadcastStatusTypeAsString(BroadcastMessageStatusType type) {
    switch (type) {
      case BroadcastMessageStatusType.WAITING:
        return _i18n.get("waiting");
      case BroadcastMessageStatusType.SENDING:
        return _i18n.get("sending");
      case BroadcastMessageStatusType.FAILED:
        return _i18n.get("failed");
    }
  }

  Future<void> _sendSmsBroadcast(
    Message message,
  ) async {
    if (isAndroidNative) {
      final members = await _mucDao.getAllBroadcastSmsMembers(message.roomUid);
      final phoneNumbers = members
          .map(
            (member) => "0"
                "${member?.phoneNumber!.nationalNumber.toInt()}",
          )
          .toList();
      if (members.isNotEmpty) {
        final bcList = <BroadcastStatus>[];
        for (var i = 0; i < phoneNumbers.length; i++) {
          final status = BroadcastStatus(
            broadcastMessageId: message.id!,
            to: members[i]!.name,
            status: BroadcastMessageStatusType.WAITING,
            sendingId: phoneNumbers[i],
            isSmsBroadcast: true,
          );
          bcList.add(status);
          await _broadcastDao.saveBroadcastStatus(
            message.roomUid,
            status,
          );
        }
        await Permission.sms.request();
        if (_broadcastRunningStatus[message.roomUid]?.value ==
            BroadcastRunningStatus.RUNNING) {
          await _sendWaitingSmsBroadcast(
            bcList,
            message,
          );
        }
      }
    }
  }

  Future<String> _createSmsMessageFromMessage(Message message) async {
    final messageExtractorServices = GetIt.I.get<MessageExtractorServices>();
    final mb =
        await messageExtractorServices.extractMessageSimpleRepresentative(
      messageExtractorServices.extractProtocolBufferMessage(message),
    );

    // var text = "${_i18n.get("sms_broad_cast_title")}:\n${mb.typeDetails}";
    // if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty) {
    //   text = "$text,";
    // }
    // if (mb.text.isNotEmpty) {
    //   text =
    //       "$text  ${mb.text.split("\n").map((e) => e.trim()).where((e) => e.isNotEmpty).join(" ")}";
    // }
    // return "$text\n$APPLICATION_LANDING_URL";

    // Changing This For Now
    return "${mb.typeDetails.isNotEmpty ? "${mb.typeDetails}, " : ""}${mb.text}"
        .trim();
  }

  int getBroadcastIdFromPacketId(String packetId) {
    return int.parse(packetId.split("-")[3]);
  }

  Future<void> _sendWaitingSmsBroadcast(
    List<BroadcastStatus> bcStatusList,
    Message message,
  ) async {
    for (var i = 0; i < bcStatusList.length; i++) {
      if (_broadcastRunningStatus[message.roomUid]?.value ==
          BroadcastRunningStatus.RUNNING) {
        final smsText = await _createSmsMessageFromMessage(message);

        if (smsText.isNotEmpty) {
          await BackgroundSms.sendMessage(
            phoneNumber: bcStatusList[i].sendingId,
            message: smsText,
          );
          await _broadcastDao.deleteBroadcastStatus(
            bcStatusList[i].sendingId,
            message.roomUid,
          );
          await Future.delayed(const Duration(seconds: BROADCAST_SMS_DELAY));
        } else {
          break;
        }
      } else {
        break;
      }
    }
    await _setBroadcastAsEnded(
      message.roomUid,
    );
  }

  MessageRepo get _getMessageRepo =>
      _messageRepo ??= GetIt.I.get<MessageRepo>();
}
