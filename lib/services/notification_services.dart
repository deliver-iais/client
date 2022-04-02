import 'dart:async';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import "package:deliver/web_classes/js.dart" if (dart.library.html) 'dart:js'
    as js;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
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

  Future<void> notifyText(MessageBrief message);

  Future<void> notifyIncomingCall(String roomUid, String roomName);

  Future<void> cancel(int id, String roomUid);

  Future<void> cancelAll();

  Future<void> cancelById(int id);
}

class NotificationServices {
  final _audioService = GetIt.I.get<AudioService>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _notifier = GetIt.I.get<Notifier>();

  Future<void> showTextNotification(pro.Message message,
      {String? roomName}) async {
    final mb = (await extractMessageBrief(_i18n, _roomRepo, _authRepo, message))
        .copyWith(roomName: roomName);
    if (!mb.ignoreNotification) {
      _notifier.notifyText(_synthesize(mb));
    }
  }

  Future<void> showIncomingCallNotification(String roomUid,
      {String? roomName}) async {
    final rn = roomName ?? await _roomRepo.getSlangName(roomUid.asUid());

    _notifier.notifyIncomingCall(roomUid, rn);
  }

  MessageBrief _synthesize(MessageBrief mb) {
    if (mb.text.isNotEmpty) {
      return mb.copyWith(
          text: BoldTextParser.transformer(
              ItalicTextParser.transformer(mb.text)));
    }

    return mb;
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

  Future<void> playSoundIn() async {}

  void playSoundOut() {
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
          productName: APPLICATION_NAME);
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
      final lastAvatar =
          await _avatarRepo.getLastAvatar(message.roomUid, false);
      if (lastAvatar != null && lastAvatar.fileId != null) {
        final file = await _fileRepo.getFile(
            lastAvatar.fileId!, lastAvatar.fileName!,
            thumbnailSize: ThumbnailSize.medium);
        toast = await WinToast.instance().showToast(
            type: ToastType.imageAndText02,
            title: message.roomName,
            subtitle: createNotificationTextFromMessageBrief(message),
            imagePath: file!);
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
    if (!toastByRoomId.containsKey(roomUid.asUid().node)) {
      toastByRoomId[roomUid.asUid().node] = {};
    }
    try {
      final lastAvatar =
          await _avatarRepo.getLastAvatar(roomUid.asUid(), false);
      if (lastAvatar != null && lastAvatar.fileId != null) {
        final file = await _fileRepo.getFile(
            lastAvatar.fileId!, lastAvatar.fileName!,
            thumbnailSize: ThumbnailSize.medium);
        toast = await WinToast.instance().showToast(
            type: ToastType.imageAndText02,
            title: roomName,
            actions: actions,
            subtitle: "Incoming Call",
            imagePath: file!);
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
    js.context.callMethod("showNotification",
        [message.roomName, createNotificationTextFromMessageBrief(message)]);
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

  @override
  Future<void> cancelById(int id) async {}

  LinuxNotifier() {
    const notificationSetting =
        LinuxInitializationSettings(defaultActionName: "");

    _flutterLocalNotificationsPlugin.initialize(notificationSetting,
        onSelectNotification: (room) {
      if (room != null && room.isNotEmpty) {
        DesktopWindow.focus();
        _routingService.openRoom(room);
      }
      return;
    });
  }

  @override
  Future<void> notifyText(MessageBrief message) async {
    if (message.ignoreNotification) return;

    LinuxNotificationIcon icon = AssetsLinuxIcon(
        'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png');

    final la = await _avatarRepo.getLastAvatar(message.roomUid, false);

    if (la != null && la.fileId != null) {
      final path = await _fileRepo.getFileIfExist(la.fileId!, la.fileName!,
          thumbnailSize: ThumbnailSize.medium);

      if (path != null && path.isNotEmpty) {
        icon = AssetsLinuxIcon(path);
      }
    }

    final platformChannelSpecifics = LinuxNotificationDetails(icon: icon);

    _flutterLocalNotificationsPlugin.show(message.roomUid.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: platformChannelSpecifics,
        payload: message.roomUid.asString());
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
      groupId: "all_group");

  AndroidNotifier() {
    ConnectycubeFlutterCallKit.instance
        .init(onCallAccepted: onCallAccepted, onCallRejected: onCallRejected);

    _flutterLocalNotificationsPlugin.createNotificationChannel(channel);

    const notificationSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    _flutterLocalNotificationsPlugin.initialize(notificationSetting,
        onSelectNotification: androidOnSelectNotification);
    androidDidNotificationLaunchApp();
  }

  Future<void> androidDidNotificationLaunchApp() async {
    final notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      androidOnSelectNotification(notificationAppLaunchDetails!.payload);
    }
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
  Future<void> cancelById(int id) async {
    _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> notifyText(MessageBrief message) async {
    if (message.ignoreNotification) return;
    AndroidBitmap<Object>? largeIcon;
    var selectedNotificationSound = "that_was_quick";
    final selectedSound =
        await _roomRepo.getRoomCustomNotification(message.roomUid.asString());
    final la = await _avatarRepo.getLastAvatar(message.roomUid, false);
    if (la != null && la.fileId != null && la.fileName != null) {
      final path = await _fileRepo.getFileIfExist(la.fileId!, la.fileName!,
          thumbnailSize: ThumbnailSize.medium);

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
        selectedNotificationSound + message.roomUid.asString(), channel.name,
        channelDescription: channel.description,
        styleInformation: inboxStyleInformation,
        groupKey: channel.groupId,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(selectedNotificationSound),
        setAsGroupSummary: true);
    _flutterLocalNotificationsPlugin.show(
        message.roomUid.hashCode, 'Attention', 'new messages',
        notificationDetails: androidNotificationDetails);

    final platformChannelSpecifics = AndroidNotificationDetails(
      selectedNotificationSound + message.roomUid.asString(),
      channel.name,
      channelDescription: channel.description,
      groupKey: channel.groupId,
      largeIcon: largeIcon,
      styleInformation: const BigTextStyleInformation(''),
      playSound: true,
      sound: RawResourceAndroidNotificationSound(selectedNotificationSound),
    );
    _flutterLocalNotificationsPlugin.show(
        message.roomUid.asString().hashCode + message.id!,
        message.roomName,
        createNotificationTextFromMessageBrief(message),
        notificationDetails: platformChannelSpecifics,
        payload: message.roomUid.asString());
  }

  @override
  Future<void> notifyIncomingCall(String roomUid, String roomName) async {
    ConnectycubeFlutterCallKit.showCallNotification(
        sessionId: "123456789",
        callerId: 123456789,
        callType: 1,
        callerName: roomName,
        userInfo: {"uid": roomUid},
        opponentsIds: {1},
        path: null);
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
  }

  @override
  Future<void> cancel(int id, String roomUid) async {
    try {
      final activeNotification =
          await _flutterLocalNotificationsPlugin.getActiveNotifications();
      for (final element in activeNotification!) {
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
    const macNotificationSetting = MacOSInitializationSettings();

    _flutterLocalNotificationsPlugin.initialize(macNotificationSetting,
        onSelectNotification: (room) {
      if (room != null && room.isNotEmpty) {
        _routingService.openRoom(room);
      }
      return;
    });
  }

  @override
  Future<void> notifyText(MessageBrief message) async {
    if (message.ignoreNotification) return;

    final attachments = <MacOSNotificationAttachment>[];

    final la = await _avatarRepo.getLastAvatar(message.roomUid, false);

    if (la != null) {
      final path = await _fileRepo.getFileIfExist(la.fileId!, la.fileName!,
          thumbnailSize: ThumbnailSize.medium);

      if (path != null && path.isNotEmpty) {
        attachments.add(MacOSNotificationAttachment(path));
      }
    }

    final macOSPlatformChannelSpecifics =
        MacOSNotificationDetails(attachments: attachments, badgeNumber: 0);
    _flutterLocalNotificationsPlugin.show(message.roomUid.asString().hashCode,
        message.roomName, createNotificationTextFromMessageBrief(message),
        notificationDetails: macOSPlatformChannelSpecifics,
        payload: message.roomUid.asString());
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
