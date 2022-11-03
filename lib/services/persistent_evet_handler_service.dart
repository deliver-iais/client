import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:get_it/get_it.dart';

class PersistentEventHandlerService {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _messageExtractorServices = GetIt.I.get<MessageExtractorServices>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  Future<String> getIssuerNameFromMucSpecificPersistentEvent(
    MucSpecificPersistentEvent mucSpecificPersistentEvent,
  ) async {
    return _roomRepo.getSlangName(
      mucSpecificPersistentEvent.issuer,
    );
  }

  Future<String?> getAssignerNameFromMucSpecificPersistentEvent(
    MucSpecificPersistentEvent mucSpecificPersistentEvent,
  ) async {
    if ({
      MucSpecificPersistentEvent_Issue.ADD_USER,
      MucSpecificPersistentEvent_Issue.MUC_CREATED,
      MucSpecificPersistentEvent_Issue.KICK_USER
    }.contains(mucSpecificPersistentEvent.issue)) {
      return _roomRepo.getSlangName(
        mucSpecificPersistentEvent.assignee,
      );
    }
    return null;
  }

  Future<String> getPinnedMessageBriefContent(
    String roomUid,
    int messageId,
  ) async {
    final message = await _messageDao.getMessage(
      roomUid,
      messageId,
    );
    final messageSRF =
        await _messageExtractorServices.extractMessageSimpleRepresentative(
      _messageExtractorServices.extractProtocolBufferMessage(message!),
    );
    var content = "";
    if (messageSRF.typeDetails.isNotEmpty) content = messageSRF.typeDetails;
    if (messageSRF.typeDetails.isNotEmpty && messageSRF.text.isNotEmpty) {
      content += ", ";
    }
    if (messageSRF.text.isNotEmpty) {
      content += messageSRF.text
          .split("\n")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join(" ");
    }
    return content;
  }

  String getMucSpecificPersistentEventIssue(
    PersistentEvent persistentEventMessage, {
    bool isChannel = false,
  }) {
    switch (persistentEventMessage.mucSpecificPersistentEvent.issue) {
      case MucSpecificPersistentEvent_Issue.ADD_USER:
        return _i18n.verb(
          "added",
          needParticleSuffixed: true,
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
        return _i18n.verb(
          isChannel ? "change_channel_avatar" : "change_group_avatar",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.JOINED_USER:
        return _i18n.verb(
          "joined",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );
      case MucSpecificPersistentEvent_Issue.KICK_USER:
        return _i18n.verb(
          "kicked",
          needParticleSuffixed: true,
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.LEAVE_USER:
        return _i18n.verb(
          "left",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.MUC_CREATED:
        return _i18n.verb(
          "created",
          needParticleSuffixed: true,
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
        return _i18n.verb(
          isChannel ? "changed_channel_name" : "changed_group_name",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );
      case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
        return _i18n.verb(
          "pinned",
          needParticleSuffixed: true,
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );
      case MucSpecificPersistentEvent_Issue.DELETED:
        return "";
    }
    return "";
  }
}
