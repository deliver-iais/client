import 'dart:async';
import 'dart:ui';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/shared/methods/platform.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:win_toast/win_toast.dart';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'navigationActionId';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String iosNotificationCategoryPlain = 'plainCategory';

/// action id for reply
const String replyActionId = 'reply';

/// action id for mark as read
const String markAsReadActionId = 'mark_as_read';

///should always in top or static
Future<void> notificationTapBackground(
  NotificationResponse? notificationResponse,
) async {
  try {
    if (!GetIt.I.isRegistered<MessageRepo>()) {
      await setupDI();
      await GetIt.I.get<CoreServices>().initStreamConnection();
      Logger().i(
        'setUpDI',
      );
    }
    Logger().i(
      'notification(${notificationResponse!.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}',
    );
    final _messageRepo = GetIt.I.get<MessageRepo>();
    if (notificationResponse.input?.isNotEmpty ?? false) {
      if (notificationResponse.actionId == replyActionId) {
        replyToMessage(_messageRepo, notificationResponse);
        markAsRead(notificationResponse);
      }
    } else if (notificationResponse.actionId == markAsReadActionId) {
      Logger().i(
        'mark as read notification(${notificationResponse.id! - notificationResponse.payload.hashCode}) id',
      );
      markAsRead(notificationResponse);
    }

    final send = IsolateNameServer.lookupPortByName('notification_send_port');
    send?.send(notificationResponse);
  } catch (e) {
    Logger().e(e);
  }
}

void replyToMessage(
  MessageRepo _messageRepo,
  NotificationResponse notificationResponse,
) {
  _messageRepo.sendTextMessage(
    notificationResponse.payload!.asUid(),
    notificationResponse.input!,
    replyId: notificationResponse.id! - notificationResponse.payload.hashCode,
  );
}

void markAsRead(
  NotificationResponse notificationResponse, {
  int? messageId,
  String? payload,
}) {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  _messageRepo.sendSeen(
    messageId ??
        notificationResponse.id! - notificationResponse.payload.hashCode,
    payload?.asUid() ?? notificationResponse.payload!.asUid(),
  );
  _roomRepo.updateMySeen(
    uid: payload ?? notificationResponse.payload!,
    messageId: messageId ??
        notificationResponse.id! - notificationResponse.payload.hashCode,
    hiddenMessageCount: 0,
  );
}

abstract class Notifier {
  static void onCallAccept(String roomUid) {
    GetIt.I
        .get<RoutingService>()
        .openCallScreen(roomUid.asUid(), isCallAccepted: true);
  }

  static void onCallReject() {
    GetIt.I.get<CallRepo>().declineCall();
  }

  Future<void> notifyText(MessageBrief message);

  Future<void> notifyIncomingCall(String roomUid, String roomName);

  Future<void> cancel(int id, String roomUid);

  Future<void> cancelAll();

  Future<void> cancelById(int id);
}

class NotificationServices {
  final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
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
  }) async {
    final rn = roomName ?? await _roomRepo.getSlangName(roomUid.asUid());

    return _notifier.notifyIncomingCall(roomUid, rn);
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
    final mb = (await extractMessageBrief(_i18n, _roomRepo, _authRepo, message))
        .copyWith(roomName: roomName);
    if (!mb.ignoreNotification) {
      return _notifier.notifyText(_synthesize(mb));
    }
  }

  MessageBrief _synthesize(MessageBrief mb) {
    if (mb.text.isNotEmpty) {
      return mb.copyWith(
        text: BoldTextParser.transformer(
          ItalicTextParser.transformer(mb.text),
        ),
      );
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
  Future<void> notifyText(MessageBrief message) async {}

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {}

  @override
  Future<void> cancel(int id, String roomUid) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {}
}

class IOSNotifier implements Notifier {
  @override
  Future<void> notifyText(MessageBrief message) async {}

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {}

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
  Future<void> notifyText(MessageBrief message) async {
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
        final deliverIcon = await _fileServices.getDeliverIcon();
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
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {
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
        final deliverIcon = await _fileServices.getDeliverIcon();
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
  Future<void> notifyText(MessageBrief message) async {
    js.context.callMethod(
      "showNotification",
      [message.roomName, createNotificationTextFromMessageBrief(message)],
    );
  }

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {}
}

class LinuxNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      LinuxFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  void linuxSelectNotification(
    String? payload,
  ) {
    final room = payload?.split('#')[0];
    if (room != null && room.isNotEmpty) {
      DesktopWindow.focus();
      _routingService.openRoom(room);
    }
  }

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
            linuxSelectNotification(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              linuxSelectNotification(notificationResponse.payload);
            } else if (notificationResponse.actionId == markAsReadActionId) {
              markAsRead(
                notificationResponse,
                messageId:
                    int.parse(notificationResponse.payload!.split('#')[1]),
                payload: notificationResponse.payload!.split('#')[0],
              );
            }

            break;
        }
        return;
      },
    );
  }

  @override
  Future<void> notifyText(MessageBrief message) async {
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
        const LinuxNotificationAction(
          key: navigationActionId,
          label: 'show chat',
        ),
        const LinuxNotificationAction(
          key: markAsReadActionId,
          label: 'Mark as read',
        ),
      ],
    );

    return _flutterLocalNotificationsPlugin.show(
      message.roomUid.asString().hashCode,
      message.roomName,
      createNotificationTextFromMessageBrief(message),
      notificationDetails: platformChannelSpecifics,
      payload: message.roomUid.asString() + "#" + message.id.toString(),
    );
  }

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {}

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
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

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
            androidOnSelectNotification(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _setupAndroidDidNotificationLaunchApp();
  }

  Future<void> _setupAndroidDidNotificationLaunchApp() {
    return _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((notificationAppLaunchDetails) {
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        // TODO(hasan): Refactor routing service to accept offline open room actions and apply them after launch, https://gitlab.iais.co/deliver/wiki/-/issues/473
        modifyRoutingByNotificationTapInBackgroundInAndroid
            .add(notificationAppLaunchDetails!.notificationResponse!.payload!);
      }
    });
  }

  Future<void> androidOnSelectNotification(String? room) async {
    if (room != null && room.isNotEmpty) {
      _routingService.openRoom(room);
    }
    return;
  }

  Future<void> onCallRejected(
    String sessionId,
    int callType,
    int callerId,
    String callerName,
    Set<int> opponentsIds,
    Map<String, String>? userInfo,
  ) async {
    Notifier.onCallReject();
  }

  Future<void> onCallAccepted(
    String sessionId,
    int callType,
    int callerId,
    String callerName,
    Set<int> opponentsIds,
    Map<String, String>? userInfo,
  ) async {
    Notifier.onCallAccept(userInfo!["uid"]!);
  }

  @override
  Future<void> cancelById(int id) {
    return _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> notifyText(MessageBrief message) async {
    if (message.ignoreNotification) return;
    AndroidBitmap<Object>? largeIcon;
    var selectedNotificationSound = "that_was_quick";
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
    if (selectedSound != null) {
      if (selectedSound != "-") {
        selectedNotificationSound = selectedSound;
      }
    }

    const inboxStyleInformation =
        InboxStyleInformation([], contentTitle: 'new messages');

    final androidNotificationDetails = AndroidNotificationDetails(
      selectedNotificationSound + message.roomUid.asString(),
      channel.name,
      channelDescription: channel.description,
      styleInformation: inboxStyleInformation,
      groupKey: channel.groupId,
      sound: RawResourceAndroidNotificationSound(selectedNotificationSound),
      setAsGroupSummary: true,
    );
    _flutterLocalNotificationsPlugin
        .show(
          message.roomUid.hashCode,
          'Attention',
          'new messages',
          notificationDetails: androidNotificationDetails,
        )
        .ignore();

    final platformChannelSpecifics = AndroidNotificationDetails(
      selectedNotificationSound + message.roomUid.asString(),
      channel.name,
      channelDescription: channel.description,
      groupKey: channel.groupId,
      largeIcon: largeIcon,
      styleInformation: const BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'reply',
          'Reply to ${message.roomName}',
          inputs: <AndroidNotificationActionInput>[
            const AndroidNotificationActionInput(
              label: 'Enter a message',
            ),
          ],
        ),
        const AndroidNotificationAction(
          'mark_as_read',
          "Mark as read",
        ),
      ],
      sound: RawResourceAndroidNotificationSound(selectedNotificationSound),
    );
    _flutterLocalNotificationsPlugin
        .show(
          message.roomUid.asString().hashCode + message.id!,
          message.roomName,
          createNotificationTextFromMessageBrief(message),
          notificationDetails: platformChannelSpecifics,
          payload: message.roomUid.asString(),
        )
        .ignore();
  }

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {
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
    await ConnectycubeFlutterCallKit.showCallNotification(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      callerId: 123456789,
      callType: 0,
      path: path,
      callerName: roomName,
      userInfo: {"uid": roomUid},
      opponentsIds: {1},
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

class MacOSNotifier implements Notifier {
  final _logger = GetIt.I.get<Logger>();
  final _flutterLocalNotificationsPlugin =
      MacOSFlutterLocalNotificationsPlugin();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  MacOSNotifier() {
    final darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        iosNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettingsDarwin,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            final room = notificationResponse.payload;
            if (room != null && room.isNotEmpty) {
              _routingService.openRoom(room);
            }
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
    );
  }

  @override
  Future<void> notifyText(MessageBrief message) async {
    if (message.ignoreNotification) return;

    final attachments = <DarwinNotificationAttachment>[];

    final la = await _avatarRepo.getLastAvatar(message.roomUid);

    if (la != null) {
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
      categoryIdentifier: darwinNotificationCategoryText,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.roomUid.asString().hashCode,
      message.roomName,
      createNotificationTextFromMessageBrief(message),
      notificationDetails: darwinNotificationDetails,
      payload: message.roomUid.asString(),
    );
  }

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {}

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

String createNotificationTextFromMessageBrief(MessageBrief mb) {
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
