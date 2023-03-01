import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/box/active_notification.dart' as active_notificaton;
import 'package:deliver/box/call_event.dart' as call_event;
import 'package:deliver/box/current_call_info.dart' as current_call_info;
import 'package:deliver/box/dao/active_notification_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pro;
import 'package:deliver_public_protocol/pub/v1/models/call.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:win_toast/win_toast.dart';

abstract class Notifier {
  static final _analyticsService = GetIt.I.get<AnalyticsService>();

  static void onCallNotificationAction(
    String roomUid, {
    bool isVideoCall = false,
    bool isCallAccepted = true,
  }) {
    GetIt.I.get<RoutingService>().openCallScreen(
          roomUid.asUid(),
          isVideoCall: isVideoCall,
          isCallAccepted: isCallAccepted,
          isIncomingCall: true,
        );
  }

  static void onCallReject() {
    GetIt.I.get<CallRepo>().declineCall();
  }

  static void replyToMessage(NotificationResponse notificationResponse) {
    final payload = parsePayload(notificationResponse.payload);

    if (payload == null) {
      return;
    }

    _analyticsService.sendLogEvent(
      "replyToMessageFromNotification",
    );
    GetIt.I.get<MessageRepo>().sendTextMessage(
          payload.item1.asUid(),
          notificationResponse.input!,
          replyId: payload.item2,
        );
  }

  static void markAsRead(NotificationResponse notificationResponse) {
    final payload = parsePayload(notificationResponse.payload);

    if (payload == null) {
      return;
    }

    _analyticsService.sendLogEvent(
      "markAsReadMessageFromNotification",
    );

    GetIt.I.get<MessageRepo>().sendSeen(payload.item2, payload.item1.asUid());
    GetIt.I.get<RoomRepo>().updateMySeen(
          uid: payload.item1,
          messageId: payload.item2,
          hiddenMessageCount: 0,
        );
    GetIt.I
        .get<ActiveNotificationDao>()
        .removeActiveNotification(payload.item1, payload.item2);
  }

  static void openChat(
    NotificationResponse response, {
    bool appIsInBackground = false,
  }) {
    final payload = Notifier.parsePayload(response.payload);

    if (payload == null) {
      return;
    }

    _analyticsService.sendLogEvent(
      "openChatFromNotification",
    );

    if (isDesktop) {
      DesktopWindow.focus();
    }

    if (appIsInBackground) {
      // TODO(hasan): Refactor routing service to accept offline open room actions and apply them after launch, https://gitlab.iais.co/deliver/wiki/-/issues/473
      modifyRoutingByNotificationTapInBackgroundInAndroid.add(payload.item1);
    } else {
      GetIt.I.get<RoutingService>().openRoom(payload.item1);
    }
  }

  static String genPayload(String roomUid, int id) => "$roomUid#$id";

  static Tuple2<String, int>? parsePayload(String? payload) {
    if (payload == null) {
      return null;
    }

    final list = payload.split("#");

    if (list.length < 2 || list[0].isEmpty) {
      return null;
    }

    try {
      return Tuple2(list[0], int.parse(list[1]));
    } catch (_) {
      return null;
    }
  }

  Future<void> notifyText(MessageSimpleRepresentative message);

  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  );

  Future<void> cancel(String roomUid);

  Future<void> editById(int id, String roomUid, String text);

  Future<void> cancelAll();

  Future<void> cancelById(int id, String roomUid);
}

class NotificationServices {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _messageExtractorServices = GetIt.I.get<MessageExtractorServices>();
  final _notifier = GetIt.I.get<Notifier>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _activeNotificationDao = GetIt.I.get<ActiveNotificationDao>();
  final _uxService = GetIt.I.get<UxService>();

  void notifyOutgoingMessage(String roomUid) {
    if (_routingService.isInRoom(roomUid)) {
      _playSoundOut();
    }
  }

  void notifyIncomingMessage(
    pro.Message message,
    String roomUid, {
    String? roomName,
  }) {
    if (_routingService.isInRoom(roomUid)) {
      _playSoundIn();
    } else {
      _showTextNotification(message, roomUid, roomName: roomName);
    }
  }

  Future<void> notifyIncomingCall(
    String roomUid, {
    String? roomName,
    String? callEventJson,
  }) async {
    final rn = roomName ?? await _roomRepo.getSlangName(roomUid.asUid());

    return _notifier.notifyIncomingCall(roomUid, rn, callEventJson);
  }

  void cancelRoomNotifications(String roomUid) {
    _notifier.cancel(roomUid);
    if (isAndroid) {
      _activeNotificationDao.removeRoomActiveNotification(roomUid);
    }
  }

  void cancelNotificationById(int id, String roomUid) {
    _notifier.cancelById(id, roomUid);
  }

  Future<void> editNotificationById(
    int id,
    String roomUid,
    pro.Message message,
  ) async {
    final mb = (await _messageExtractorServices
        .extractMessageSimpleRepresentative(message));
    return _notifier.editById(id, roomUid, mb.text);
  }

  void cancelAllNotifications() {
    _notifier.cancelAll();
    if (isAndroid) {
      _activeNotificationDao.removeAllActiveNotification();
    }
  }

  Future<void> _showTextNotification(
    pro.Message message,
    String roomUid, {
    String? roomName,
  }) async {
    final mb = (await _messageExtractorServices
            .extractMessageSimpleRepresentative(message))
        .copyWith(roomName: roomName);
    if (!mb.ignoreNotification) {
      return _notifier.notifyText(_synthesize(mb));
    }
  }

  MessageSimpleRepresentative _synthesize(MessageSimpleRepresentative mb) {
    if (mb.text.isNotEmpty) {
      final blocks = onePath(
        [Block(text: mb.text, features: {})],
        justSpoilerDetectors,
        textTransformer(),
      );
      final result = blocks.join();
      return mb.copyWith(text: result);
    }

    return mb;
  }

  void _playSoundIn() {
    if (_uxService.playInChatSounds) {
      _audioService.playSoundIn();
    }
  }

  void _playSoundOut() {
    if (_uxService.playInChatSounds) {
      _audioService.playSoundOut();
    }
  }
}

class FakeNotifier implements Notifier {
  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {}

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {}

  @override
  Future<void> cancel(String roomUid) async {}

  @override
  Future<void> editById(int id, String roomUid, String text) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id, String roomUid) async {}
}

//init on Home_Page init because can't load Deliver Icon and should be init inside initState() function
class WindowsNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _fileServices = GetIt.I.get<FileService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  Map<String, Map<int, Toast>> toastByRoomId = {};

  WindowsNotifier() {
    scheduleMicrotask(() async {
      final ret = await WinToast.instance().initialize(
        appName: APPLICATION_NAME,
        companyName: APPLICATION_DOMAIN,
        productName: APPLICATION_NAME,
      );
      assert(ret);
    });
  }

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    Toast? toast;
    if (!toastByRoomId.containsKey(message.roomUid.node)) {
      toastByRoomId[message.roomUid.node] = {};
    }
    try {
      final lastAvatar = await _avatarRepo.getLastAvatar(message.roomUid);
      if (lastAvatar != null && lastAvatar.fileId != null) {
        final file = await _fileRepo.getFile(
          lastAvatar.fileId!,
          lastAvatar.fileName!,
          thumbnailSize: ThumbnailSize.medium,
        );
        toast = await WinToast.instance().showToast(
          type: ToastType.imageAndText02,
          title: message.roomName,
          subtitle: createNotificationTextFromMessageBrief(message),
          imagePath: file!,
        );
      } else {
        final deliverIcon = await _fileServices.getApplicationIcon();
        if (deliverIcon != null && deliverIcon.existsSync()) {
          toast = await WinToast.instance().showToast(
            type: ToastType.imageAndText02,
            title: message.roomName,
            imagePath: deliverIcon.path,
            subtitle: createNotificationTextFromMessageBrief(message),
          );
        }
      }
      final roomIdToast = toastByRoomId[message.roomUid.node];
      roomIdToast![message.id!] = toast!;
      toast.eventStream.listen((event) {
        if (event is ActivatedEvent) {
          _routingService.openRoom(message.roomUid.asString());
          DesktopWindow.focus();
        }
        final roomIdToast = toastByRoomId[message.roomUid.node];
        roomIdToast?.remove(message.id);
      });
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {
    final actions = <String>[_i18n.get("accept"), _i18n.get("decline")];
    Toast? toast;
    if (!toastByRoomId.containsKey(
      roomUid.asUid().node,
    )) {
      toastByRoomId[roomUid.asUid().node] = {};
    }
    try {
      final lastAvatar = await _avatarRepo.getLastAvatar(roomUid.asUid());
      final callType = callEventJson?.toCallEvent().callType;
      final subtitle = "Incoming ${callType?.name} Call";
      if (lastAvatar != null && lastAvatar.fileId != null) {
        final file = await _fileRepo.getFile(
          lastAvatar.fileId!,
          lastAvatar.fileName!,
          thumbnailSize: ThumbnailSize.medium,
        );

        toast = await WinToast.instance().showToast(
          type: ToastType.imageAndText02,
          title: roomName,
          actions: actions,
          subtitle: _i18n.get("incoming_call"),
          imagePath: file!,
        );
      } else {
        final deliverIcon = await _fileServices.getApplicationIcon();
        if (deliverIcon != null && deliverIcon.existsSync()) {
          toast = await WinToast.instance().showToast(
            type: ToastType.imageAndText02,
            title: roomName,
            imagePath: deliverIcon.path,
            actions: actions,
            subtitle: subtitle,
          );
        }
      }
      final roomIdToast = toastByRoomId[roomUid.asUid().node];
      roomIdToast![-1] = toast!;
      toast.eventStream.listen((event) {
        if (event is ActivatedEvent) {
          if (event.actionIndex == 1) {
            // Decline
            Notifier.onCallReject();
          } else if (event.actionIndex == 0) {
            // Accept
            DesktopWindow.focus();
            if (callType == CallEvent_CallType.VIDEO) {
              Notifier.onCallNotificationAction(roomUid, isVideoCall: true);
            } else {
              Notifier.onCallNotificationAction(roomUid);
            }
          }
        }
        final roomIdToast = toastByRoomId[roomUid.asUid().node];
        roomIdToast?.remove(-1);
      });
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> cancel(String roomUid) async {
    if (toastByRoomId.containsKey(roomUid)) {
      final roomIdToast = toastByRoomId[roomUid];
      for (final element in roomIdToast!.keys.toList()) {
        roomIdToast[element]!.clear();
        roomIdToast.remove(element);
      }
    }
  }

  @override
  Future<void> editById(int id, String roomUid, String text) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id, String roomUid) async {}
}

class WebNotifier implements Notifier {
  @override
  Future<void> cancel(String roomUid) async {}

  @override
  Future<void> editById(int id, String roomUid, String text) async {}

  @override
  Future<void> cancelById(int id, String roomUid) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    js.context.callMethod(
      "showNotification",
      [message.roomName, createNotificationTextFromMessageBrief(message)],
    );
  }

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {}
}

class LinuxNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      LinuxFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Future<void> cancelById(int id, String roomUid) async {}

  LinuxNotifier() {
    const notificationSetting =
        LinuxInitializationSettings(defaultActionName: "");

    _flutterLocalNotificationsPlugin.initialize(
      notificationSetting,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Notifier.openChat(notificationResponse);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == OPEN_CHAT_ACTION_ID) {
              Notifier.openChat(notificationResponse);
            } else if (notificationResponse.actionId ==
                MARK_AS_READ_ACTION_ID) {
              Notifier.markAsRead(notificationResponse);
            }
            break;
        }
        return;
      },
    );
  }

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    if (message.ignoreNotification) return;

    LinuxNotificationIcon icon = AssetsLinuxIcon(
      'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png',
    );

    final la = await _avatarRepo.getLastAvatar(message.roomUid);

    if (la != null && la.fileId != null) {
      final path = await _fileRepo.getFileIfExist(
        la.fileId!,
        la.fileName!,
        thumbnailSize: ThumbnailSize.medium,
      );

      if (path != null && path.isNotEmpty) {
        icon = AssetsLinuxIcon(path);
      }
    }

    final platformChannelSpecifics = LinuxNotificationDetails(
      icon: icon,
      actions: <LinuxNotificationAction>[
        LinuxNotificationAction(
          key: OPEN_CHAT_ACTION_ID,
          label: _i18n.get("open_chat"),
        ),
        LinuxNotificationAction(
          key: MARK_AS_READ_ACTION_ID,
          label: _i18n.get("mark_as_read"),
        ),
      ],
    );

    return _flutterLocalNotificationsPlugin.show(
      message.roomUid.asString().hashCode,
      message.roomName,
      createNotificationTextFromMessageBrief(message),
      notificationDetails: platformChannelSpecifics,
      payload: Notifier.genPayload(message.roomUid.asString(), message.id!),
    );
  }

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {}

  @override
  Future<void> cancel(String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(roomUid.hashCode);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> editById(int id, String roomUid, String text) async {}

  @override
  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }
}

class AndroidNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _activeNotificationDao = GetIt.I.get<ActiveNotificationDao>();
  final _flutterLocalNotificationsPlugin =
      AndroidFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _callService = GetIt.I.get<CallService>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'notifications', // id
    'Notifications', // title
    description: 'All notifications of application.', // description
    importance: Importance.high,
  );

  AndroidNotifier() {
    ConnectycubeFlutterCallKit.instance.init(
      onCallAccepted: onCallAccepted,
      onCallRejected: onCallRejected,
      onNotificationTap: onCallNotificationTap,
    );

    _flutterLocalNotificationsPlugin.createNotificationChannel(channel);

    const notificationSetting =
        AndroidInitializationSettings('@drawable/ic_stat');

    _flutterLocalNotificationsPlugin.initialize(
      notificationSetting,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Notifier.openChat(notificationResponse);
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          androidNotificationTapBackground,
    );
    _setupAndroidDidNotificationLaunchApp();
  }

  //should always in top or static
  static Future<void> androidNotificationTapBackground(
    NotificationResponse? notificationResponse,
  ) async {
    try {
      // hive does not support multithreading
      await Hive.close();
      await setupDI();
    } catch (e) {
      Logger().e(e);
    }
    if (notificationResponse == null) {
      return;
    }

    if (notificationResponse.input?.isNotEmpty ?? false) {
      if (notificationResponse.actionId == REPLY_ACTION_ID) {
        Notifier.replyToMessage(notificationResponse);
        Notifier.markAsRead(notificationResponse);
      }
    } else if (notificationResponse.actionId == MARK_AS_READ_ACTION_ID) {
      Notifier.markAsRead(notificationResponse);
    }
  }

  Future<void> _setupAndroidDidNotificationLaunchApp() {
    return _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((notificationAppLaunchDetails) {
      if ((notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) &&
          notificationAppLaunchDetails!.notificationResponse != null) {
        Notifier.openChat(
          notificationAppLaunchDetails.notificationResponse!,
          appIsInBackground: true,
        );
      }
    });
  }

  Future<void> onCallRejected(CallEvent callEvent) async {
    Notifier.onCallReject();
  }

  Future<void> onCallNotificationTap(CallEvent callEvent) async {
    await GetIt.I.get<CallService>().clearCallData();
    await GetIt.I.get<CallService>().disposeCallData();
    _callService.setRoomUid = callEvent.userInfo!["uid"]!.asUid();
    await _callService.saveCallOnDb(
      getCallInfo(
        callEvent,
        CallEvent_CallStatus.CREATED,
        isNotificationSelected: true,
      ),
    );
  }

  Future<void> onCallAccepted(CallEvent callEvent) async {
    await GetIt.I.get<CallService>().clearCallData();
    await GetIt.I.get<CallService>().disposeCallData();
    _callService.setRoomUid = callEvent.userInfo!["uid"]!.asUid();
    await _callService.saveCallOnDb(
      getCallInfo(callEvent, CallEvent_CallStatus.CREATED, isAccepted: true),
    );
  }

  current_call_info.CurrentCallInfo getCallInfo(
    CallEvent callEvent,
    CallEvent_CallStatus callEvent_CallStatus, {
    bool isNotificationSelected = false,
    bool isAccepted = false,
  }) {
    final callEventInfo =
        call_pro.CallEvent.fromJson(callEvent.userInfo!["callEventJson"]!);

    if (callEventInfo.callType == CallEvent_CallType.VIDEO) {
      Notifier.onCallNotificationAction(
        callEvent.userInfo!["uid"]!,
        isVideoCall: true,
        isCallAccepted: !isNotificationSelected,
      );
    } else {
      Notifier.onCallNotificationAction(
        callEvent.userInfo!["uid"]!,
        isCallAccepted: !isNotificationSelected,
      );
    }

    //here status be JOINED means ACCEPT CALL and when app Start should go on accepting status
    final currentCallEvent = call_event.CallEvent(
      callDuration: callEventInfo.callDuration.toInt(),
      callType: _callService.findCallEventType(callEventInfo.callType),
      callStatus: _callService.findCallEventStatusProto(callEvent_CallStatus),
      id: callEventInfo.callId,
    );

    return current_call_info.CurrentCallInfo(
      callEvent: currentCallEvent,
      from: callEvent.userInfo!["uid"]!,
      to: _authRepo.currentUserUid.toString(),
      expireTime: clock.now().millisecondsSinceEpoch + 60000,
      notificationSelected: isNotificationSelected,
      isAccepted: isAccepted,
    );
  }

  @override
  Future<void> cancelById(int id, String roomUid) async {
    //if we don't have that message in our active notification table
    if ((await _activeNotificationDao.getActiveNotification(roomUid, id)) ==
        null) {
      return;
    }

    // if android(local notification) doesn't have any active notification for that room
    if ((await _flutterLocalNotificationsPlugin.getActiveNotifications())
        .where((element) => element.id == roomUid.hashCode)
        .isEmpty) {
      await _activeNotificationDao.removeRoomActiveNotification(roomUid);
      return;
    }
    final activeNotifications =
        await _activeNotificationDao.getRoomActiveNotification(roomUid);
    await _activeNotificationDao.removeActiveNotification(roomUid, id);
    final lines = <String>[];
    for (final element in activeNotifications) {
      if (element.messageId != id) {
        lines.add(element.messageText);
      }
    }
    if (lines.isNotEmpty) {
      final text = activeNotifications.last.messageText;
      final inboxStyleInformation = _createInboxStyleInformation(
        lines,
        activeNotifications.last.roomName,
        activeNotifications.where((element) => element.messageId != id).length,
      );

      await _flutterLocalNotificationsPlugin.show(
        roomUid.hashCode,
        activeNotifications.last.roomName,
        text,
        notificationDetails: await _createAndroidNotificationDetails(
          roomUid,
          activeNotifications.last.roomName,
          inboxStyleInformation,
        ),
        payload: Notifier.genPayload(
          roomUid,
          activeNotifications.last.messageId,
        ),
      );
    } else {
      await cancel(roomUid);
    }
  }

  @override
  Future<void> editById(int id, String roomUid, String editedText) async {
    //if we don't have that message in our active notification table
    if ((await _activeNotificationDao.getActiveNotification(roomUid, id)) ==
        null) {
      return;
    }

    // if android(local notification) doesn't have any active notification for that room
    if ((await _flutterLocalNotificationsPlugin.getActiveNotifications())
        .where((element) => element.id == roomUid.hashCode)
        .isEmpty) {
      await _activeNotificationDao.removeRoomActiveNotification(roomUid);
      return;
    }

    final activeNotifications =
        await _activeNotificationDao.getRoomActiveNotification(roomUid);
    await _activeNotificationDao.updateActiveNotification(
      roomUid,
      id,
      editedText,
    );

    final lines = <String>[];
    for (final element in activeNotifications) {
      if (element.messageId != id) {
        lines.add(element.messageText);
      } else {
        lines.add(editedText);
      }
    }
    if (lines.isNotEmpty) {
      final String text;
      if (activeNotifications.last.messageId == id) {
        text = editedText;
      } else {
        text = activeNotifications.last.messageText;
      }
      final inboxStyleInformation = _createInboxStyleInformation(
        lines,
        activeNotifications.last.roomName,
        activeNotifications.where((element) => element.messageId != id).length,
      );

      await _flutterLocalNotificationsPlugin.show(
        roomUid.hashCode,
        activeNotifications.last.roomName,
        text,
        notificationDetails: await _createAndroidNotificationDetails(
          roomUid,
          activeNotifications.last.roomName,
          inboxStyleInformation,
        ),
        payload: Notifier.genPayload(
          roomUid,
          activeNotifications.last.messageId,
        ),
      );
    } else {
      await cancel(roomUid);
    }
  }

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    if (message.ignoreNotification) return;

    final lines = <String>[];

    final resLocalNotification =
        await _flutterLocalNotificationsPlugin.getActiveNotifications();
    final roomActiveNotification = resLocalNotification.lastWhereOrNull(
      (element) => (element.groupKey == message.roomUid.asString() &&
          element.body != null &&
          element.body!.isNotEmpty),
    );
    if (roomActiveNotification == null) {
      await _activeNotificationDao
          .removeRoomActiveNotification(message.roomUid.asString());
    }

    final res = await _activeNotificationDao
        .getRoomActiveNotification(message.roomUid.asString());

    for (final element in res) {
      lines.add(element.messageText);
    }

    final text = createNotificationTextFromMessageBrief(message);
    lines.add(text);

    final count = lines.length;
    await _activeNotificationDao.save(
      active_notificaton.ActiveNotification(
        roomUid: message.roomUid.asString(),
        messageId: message.id ?? 0,
        messageText: createNotificationTextFromMessageBrief(message),
        roomName: message.roomName,
      ),
    );
    final inboxStyleInformation = _createInboxStyleInformation(
      lines,
      message.roomName,
      count,
    );
    final platformChannelSpecifics = await _createAndroidNotificationDetails(
      message.roomUid.asString(),
      message.roomName,
      inboxStyleInformation,
      shouldBeQuiet: message.shouldBeQuiet,
    );
    _flutterLocalNotificationsPlugin
        .show(
          message.roomUid.asString().hashCode,
          message.roomName,
          text,
          notificationDetails: platformChannelSpecifics,
          payload: Notifier.genPayload(message.roomUid.asString(), message.id!),
        )
        .ignore();
  }

  BigTextStyleInformation _createInboxStyleInformation(
    List<String> lines,
    String roomName,
    int count,
  ) {
    return BigTextStyleInformation(
      _getCustomInboxStyleInformation(lines).join("\n"),
      contentTitle: lines.length > 1
          ? '$count ${_i18n.get("messages_from")} $roomName'
          : _i18n.get("new_messages"),
      summaryText: lines.length > 1
          ? '$count ${_i18n.get("messages")}'
          : _i18n.get("new_messages"),
    );
  }

  List<String> _getCustomInboxStyleInformation(List<String> lines) {
    final newLines = lines.last.length > 100
        ? [lines.last]
        : lines.length > 8
            ? lines.sublist(lines.length - 8, lines.length)
            : lines;
    Iterable<String> list = newLines;
    if (newLines.length > 1) {
      list = newLines.map((e) {
        if (e.length > 100) {
          return "${e.substring(0, 30)}...";
        } else {
          return e;
        }
      });
    }
    return list.toList();
  }

  Future<AndroidNotificationDetails> _createAndroidNotificationDetails(
    String roomUid,
    String roomName,
    StyleInformation inboxStyleInformation, {
    bool shouldBeQuiet = true,
  }) async {
    AndroidBitmap<Object>? largeIcon;
    var selectedNotificationSound =
        shouldBeQuiet ? "no_sound" : "that_was_quick";
    final selectedSound = await _roomRepo.getRoomCustomNotification(roomUid);
    final la = await _avatarRepo.getLastAvatar(roomUid.asUid());
    if (la != null && la.fileId != null && la.fileName != null) {
      final path = await _fileRepo.getFileIfExist(
        la.fileId!,
        la.fileName!,
        thumbnailSize: ThumbnailSize.medium,
      );

      if (path != null && path.isNotEmpty) {
        largeIcon = FilePathAndroidBitmap(path);
      }
    }
    if (!shouldBeQuiet) {
      if (selectedSound != "default") {
        selectedNotificationSound = selectedSound;
      }
    }

    return AndroidNotificationDetails(
      selectedNotificationSound + roomUid,
      channel.name,
      channelDescription: channel.description,
      groupKey: roomUid,
      largeIcon: largeIcon,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: inboxStyleInformation,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          REPLY_ACTION_ID,
          '${_i18n.get("reply_to")} $roomName',
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              label: _i18n.get("enter_a_message"),
            ),
          ],
        ),
        AndroidNotificationAction(
          MARK_AS_READ_ACTION_ID,
          _i18n.get("mark_as_read"),
        ),
      ],
      sound: RawResourceAndroidNotificationSound(selectedNotificationSound),
    );
  }

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {
    final la = await _avatarRepo.getLastAvatar(roomUid.asUid());
    String? path;
    if (la != null && la.fileId != null && la.fileName != null) {
      path = await _fileRepo.getFileIfExist(
        la.fileId!,
        la.fileName!,
        thumbnailSize: ThumbnailSize.medium,
      );
    }
    final callType = callEventJson?.toCallEvent().callType;
    //callType: 0 ==>Audio call 1 ==>Video call
    final ceJson = callEventJson ?? "";
    await ConnectycubeFlutterCallKit.showCallNotification(
      CallEvent(
        sessionId: clock.now().millisecondsSinceEpoch.toString(),
        callerId: 123456789,
        callType: callType == CallEvent_CallType.AUDIO ? 0 : 1,
        callerName: roomName,
        userInfo: {"uid": roomUid, "callEventJson": ceJson},
        avatarPath: path,
        opponentsIds: const {1},
        rejectActionText: _i18n.get("decline"),
        acceptActionText: _i18n.get("accept"),
      ),
    );
    vibrate(duration: 60000, pattern: List.filled(60, 1000)).ignore();
    await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
  }

  @override
  Future<void> cancel(String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(roomUid.hashCode);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }
}

class IOSNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin = IOSFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  // final _i18n = GetIt.I.get<I18N>();

  IOSNotifier() {
    final darwinNotificationCategories = <DarwinNotificationCategory>[
      const DarwinNotificationCategory(
        DARWIN_NOTIFICATION_CATEGORY_TEXT,
        // actions: <DarwinNotificationAction>[
        //   DarwinNotificationAction.text(
        //     REPLY_ACTION_ID,
        //     _i18n.get("reply"),
        //     buttonTitle: 'Send',
        //     placeholder: _i18n.get("enter_a_message"),
        //   ),
        //   DarwinNotificationAction.plain(
        //     MARK_AS_READ_ACTION_ID,
        //     _i18n.get("mark_as_read"),
        //     options: <DarwinNotificationActionOption>{
        //       DarwinNotificationActionOption.destructive,
        //   },
        //   ),
        // ],
      )
    ];
    final initializationSettingsDarwin = DarwinInitializationSettings(
      notificationCategories: darwinNotificationCategories,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettingsDarwin,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Notifier.openChat(notificationResponse);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == REPLY_ACTION_ID) {
              Notifier.replyToMessage(notificationResponse);
              Notifier.markAsRead(notificationResponse);
            } else if (notificationResponse.actionId ==
                MARK_AS_READ_ACTION_ID) {
              Notifier.markAsRead(notificationResponse);
            }
            break;
        }
      },
    );

    _setupIOSDidNotificationLaunchApp();
  }

  Future<void> _setupIOSDidNotificationLaunchApp() {
    return _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((notificationAppLaunchDetails) {
      if ((notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) &&
          notificationAppLaunchDetails!.notificationResponse != null) {
        Notifier.openChat(
          notificationAppLaunchDetails.notificationResponse!,
          appIsInBackground: true,
        );
      }
    });
  }

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    if (message.ignoreNotification) return;

    final attachments = <DarwinNotificationAttachment>[];

    final la = await _avatarRepo.getLastAvatar(message.roomUid);

    if (la != null && la.fileId != null && la.fileName != null) {
      final path = await _fileRepo.getFileIfExist(
        la.fileId!,
        la.fileName!,
        thumbnailSize: ThumbnailSize.medium,
      );

      if (path != null && path.isNotEmpty) {
        attachments.add(DarwinNotificationAttachment(path));
      }
    }
    final darwinNotificationDetails = DarwinNotificationDetails(
      attachments: attachments,
      badgeNumber: 0,
      categoryIdentifier: DARWIN_NOTIFICATION_CATEGORY_TEXT,
    );

    return _flutterLocalNotificationsPlugin.show(
      message.roomUid.asString().hashCode,
      message.roomName,
      createNotificationTextFromMessageBrief(message),
      notificationDetails: darwinNotificationDetails,
      payload: Notifier.genPayload(message.roomUid.asString(), message.id!),
    );
  }

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {}

  @override
  Future<void> cancel(String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(roomUid.hashCode);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> cancelById(int id, String roomUid) async {}

  @override
  Future<void> editById(int id, String roomUid, String text) async {}
}

class MacOSNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      MacOSFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _fileService = GetIt.I.get<FileService>();
  final _i18n = GetIt.I.get<I18N>();

  MacOSNotifier() {
    final darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        DARWIN_NOTIFICATION_CATEGORY_TEXT,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            REPLY_ACTION_ID,
            _i18n.get("reply"),
            buttonTitle: 'Send',
            placeholder: _i18n.get("enter_a_message"),
          ),
          DarwinNotificationAction.plain(
            MARK_AS_READ_ACTION_ID,
            _i18n.get("mark_as_read"),
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
        ],
      )
    ];
    final initializationSettingsDarwin = DarwinInitializationSettings(
      notificationCategories: darwinNotificationCategories,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettingsDarwin,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            Notifier.openChat(notificationResponse);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == REPLY_ACTION_ID) {
              Notifier.replyToMessage(notificationResponse);
              Notifier.markAsRead(notificationResponse);
            } else if (notificationResponse.actionId ==
                MARK_AS_READ_ACTION_ID) {
              Notifier.markAsRead(notificationResponse);
            }
            break;
        }
      },
    );
  }

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    if (message.ignoreNotification) return;

    final attachments = <DarwinNotificationAttachment>[];

    final la = await _avatarRepo.getLastAvatar(message.roomUid);

    if (la != null && la.fileId != null && la.fileName != null) {
      final path = await _fileRepo.getFileIfExist(
        la.fileId!,
        la.fileName!,
        thumbnailSize: ThumbnailSize.medium,
      );

      if (path != null && path.isNotEmpty) {
        // Macos not accepting webp, so we convert them to jpeg
        final file = File('${(await getTemporaryDirectory()).path}/avatar.jpg');
        await file
            .writeAsBytes(await _fileService.convertImageToJpg(File(path)));

        attachments.add(DarwinNotificationAttachment(file.path));
      }
    }
    final darwinNotificationDetails = DarwinNotificationDetails(
      attachments: attachments,
      badgeNumber: 0,
      categoryIdentifier: DARWIN_NOTIFICATION_CATEGORY_TEXT,
    );

    return _flutterLocalNotificationsPlugin.show(
      message.roomUid.asString().hashCode,
      message.roomName,
      createNotificationTextFromMessageBrief(message),
      notificationDetails: darwinNotificationDetails,
      payload: Notifier.genPayload(message.roomUid.asString(), message.id!),
    );
  }

  @override
  Future<void> notifyIncomingCall(
    String roomUid,
    String roomName,
    String? callEventJson,
  ) async {}

  @override
  Future<void> cancel(String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(roomUid.hashCode);
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      _logger.e(e);
    }
  }

  @override
  Future<void> cancelById(int id, String roomUid) async {}

  @override
  Future<void> editById(int id, String roomUid, String text) async {}
}

String createNotificationTextFromMessageBrief(MessageSimpleRepresentative mb) {
  var text = "";
  if (!(mb.roomUid.isBot() || mb.roomUid.isUser()) && mb.senderIsAUserOrBot) {
    text += "${mb.sender.trim()}: ";
  }
  if (mb.typeDetails.isNotEmpty) {
    text += mb.typeDetails;
  }
  if (mb.typeDetails.isNotEmpty && mb.text.isNotEmpty) {
    text += ", ";
  }
  if (mb.text.isNotEmpty) {
    text += mb.text;
  }

  return text;
}
