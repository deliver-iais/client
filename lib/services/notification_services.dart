import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/box/call_event.dart' as call_event;
import 'package:deliver/box/current_call_info.dart' as current_call_info;
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
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
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';
import 'package:win_toast/win_toast.dart';

abstract class Notifier {
  static void onCallAccept(String roomUid) {
    GetIt.I
        .get<RoutingService>()
        .openCallScreen(roomUid.asUid(), isCallAccepted: true);
  }

  static void onCallReject() {
    GetIt.I.get<CallRepo>().declineCall();
  }

  static void replyToMessage(NotificationResponse notificationResponse) {
    final payload = parsePayload(notificationResponse.payload);

    if (payload == null) {
      return;
    }

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

    GetIt.I.get<MessageRepo>().sendSeen(payload.item2, payload.item1.asUid());
    GetIt.I.get<RoomRepo>().updateMySeen(
          uid: payload.item1,
          messageId: payload.item2,
          hiddenMessageCount: 0,
        );
  }

  static void openChat(
    NotificationResponse response, {
    bool appIsInBackground = false,
  }) {
    final payload = Notifier.parsePayload(response.payload);

    if (payload == null) {
      return;
    }

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

  Future<void> cancel(int id, String roomUid);

  Future<void> cancelAll();

  Future<void> cancelById(int id);
}

class NotificationServices {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _messageExtractorServices = GetIt.I.get<MessageExtractorServices>();
  final _notifier = GetIt.I.get<Notifier>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();

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
    if (_routingService.isInRoom(roomUid) && !isDesktop) {
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
    _notifier.cancel(roomUid.hashCode, roomUid);
  }

  void cancelNotificationById(int id) {
    _notifier.cancelById(id);
  }

  void cancelAllNotifications() {
    _notifier.cancelAll();
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
        simpleTextDetectors,
        textTransformer(),
      );
      final result = blocks.join();
      return mb.copyWith(text: result);
    }

    return mb;
  }

  void _playSoundIn() {
    _audioService.playSoundIn();
  }

  void _playSoundOut() {
    _audioService.playSoundOut();
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
  Future<void> cancel(int id, String roomUid) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {}
}

//init on Home_Page init because can't load Deliver Icon and should be init inside initState() function
class WindowsNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _fileServices = GetIt.I.get<FileService>();
  final _routingService = GetIt.I.get<RoutingService>();

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
    final actions = <String>['Accept', 'Decline'];
    Toast? toast;
    if (!toastByRoomId.containsKey(
      roomUid.asUid().node,
    )) {
      toastByRoomId[roomUid.asUid().node] = {};
    }
    try {
      final lastAvatar = await _avatarRepo.getLastAvatar(roomUid.asUid());
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
          subtitle: "Incoming Call",
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
            subtitle: "Incoming Call",
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
            Notifier.onCallAccept(roomUid);
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
  Future<void> cancel(int id, String roomUid) async {
    if (toastByRoomId.containsKey(roomUid)) {
      final roomIdToast = toastByRoomId[roomUid];
      for (final element in roomIdToast!.keys.toList()) {
        roomIdToast[element]!.clear();
        roomIdToast.remove(element);
      }
    }
  }

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {}
}

class WebNotifier implements Notifier {
  @override
  Future<void> cancel(int id, String roomUid) async {}

  @override
  Future<void> cancelById(int id) async {}

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
  Future<void> cancelById(int id) async {}

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
  Future<void> cancel(int id, String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
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

class AndroidNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
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
    groupId: "all_group",
  );

  AndroidNotifier() {
    ConnectycubeFlutterCallKit.instance
        .init(onCallAccepted: onCallAccepted, onCallRejected: onCallRejected);

    _flutterLocalNotificationsPlugin.createNotificationChannel(channel);

    const notificationSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

  Future<void> onCallAccepted(CallEvent callEvent) async {
    await GetIt.I.get<CallService>().clearCallData();
    Notifier.onCallAccept(callEvent.userInfo!["uid"]!);
    final callEventInfo =
        call_pro.CallEvent.fromJson(callEvent.userInfo!["callEventJson"]!);
    //here status be JOINED means ACCEPT CALL and when app Start should go on accepting status
    final currentCallEvent = call_event.CallEvent(
      callDuration: callEventInfo.callDuration.toInt(),
      endOfCallTime: callEventInfo.endOfCallTime.toInt(),
      callType: _callService.findCallEventType(callEventInfo.callType),
      newStatus:
          _callService.findCallEventStatusProto(CallEvent_CallStatus.JOINED),
      id: callEventInfo.id,
    );

    final callInfo = current_call_info.CurrentCallInfo(
      callEvent: currentCallEvent,
      from: callEvent.userInfo!["uid"]!,
      to: _authRepo.currentUserUid.toString(),
      expireTime: clock.now().millisecondsSinceEpoch + 60000,
    );

    await _callService.saveCallOnDb(callInfo);
  }

  @override
  Future<void> cancelById(int id) {
    return _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> notifyText(MessageSimpleRepresentative message) async {
    if (message.ignoreNotification) return;
    AndroidBitmap<Object>? largeIcon;
    var selectedNotificationSound =
        message.shouldBeQuiet ? "silence" : "that_was_quick";
    final selectedSound =
        await _roomRepo.getRoomCustomNotification(message.roomUid.asString());
    final la = await _avatarRepo.getLastAvatar(message.roomUid);
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
    if (selectedSound != null && !message.shouldBeQuiet) {
      if (selectedSound != "-") {
        selectedNotificationSound = selectedSound;
      }
    }

    final lines = <String>[];

    final res = await _flutterLocalNotificationsPlugin.getActiveNotifications();
    for (final element in res) {
      if (element.groupKey == message.roomUid.asString() &&
          element.body != null &&
          element.body!.isNotEmpty) {
        lines.addAll(element.body!.split("\n"));
      }
    }

    lines.add(createNotificationTextFromMessageBrief(message));

    final text = lines.join("\n");

    final inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle:
          lines.length > 1 ? '${lines.length} messages' : "New messages",
      summaryText: message.roomName,
    );

    final platformChannelSpecifics = AndroidNotificationDetails(
      selectedNotificationSound + message.roomUid.asString(),
      channel.name,
      channelDescription: channel.description,
      groupKey: message.roomUid.asString(),
      largeIcon: largeIcon,
      fullScreenIntent: true,
      styleInformation: inboxStyleInformation,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          REPLY_ACTION_ID,
          '${_i18n.get("reply_to")} ${message.roomName}',
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
    //callType: 0 ==>Audio call 1 ==>Video call
    final ceJson = callEventJson ?? "";
    await ConnectycubeFlutterCallKit.showCallNotification(
      CallEvent(
        sessionId: clock.now().millisecondsSinceEpoch.toString(),
        callerId: 123456789,
        callType: 0,
        callerName: roomName,
        userInfo: {"uid": roomUid, "callEventJson": ceJson},
        avatarPath: path,
        opponentsIds: const {1},
      ),
    );
    await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
  }

  @override
  Future<void> cancel(int id, String roomUid) async {
    try {
      final activeNotification =
          await _flutterLocalNotificationsPlugin.getActiveNotifications();
      for (final element in activeNotification) {
        if (element.channelId!.contains(roomUid) && element.id != 0) {
          await _flutterLocalNotificationsPlugin.cancel(element.id);
        }
      }
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
  Future<void> cancel(int id, String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
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
  Future<void> cancelById(int id) async {}
}

class MacOSNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      MacOSFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
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
              DarwinNotificationActionOption.destructive,
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
  Future<void> cancel(int id, String roomUid) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
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
  Future<void> cancelById(int id) async {}
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
