import 'package:deliver/box/message.dart' as model;
import 'package:deliver/box/message_type.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart'
    as location_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:fixnum/fixnum.dart';

class MessageUtils {
  static message_pb.MessageByClient createMessageByClient(
      model.Message message,) {
    final byClient = message_pb.MessageByClient()
      ..packetId = message.packetId
      ..to = message.to
      ..replyToId = Int64(message.replyToId);

    if (message.forwardedFrom != null) {
      byClient.forwardFrom = message.forwardedFrom!;
    }
    if (message.generatedBy != null) {
      byClient.generatedBy = message.generatedBy!;
    }

    switch (message.type) {
      case MessageType.TEXT:
        byClient.text = message_pb.Text.fromJson(message.json);
        break;
      case MessageType.FILE:
        byClient.file = file_pb.File.fromJson(message.json);
        break;
      case MessageType.LOCATION:
        byClient.location = location_pb.Location.fromJson(message.json);
        break;
      case MessageType.STICKER:
        // byClient.sticker = sticker_pb.Sticker.fromJson(message.json);
        break;
      case MessageType.FORM_RESULT:
        byClient.formResult = form_pb.FormResult.fromJson(message.json);
        break;
      case MessageType.SHARE_UID:
        byClient.shareUid = message_pb.ShareUid.fromJson(message.json);
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        byClient.sharePrivateDataAcceptance =
            SharePrivateDataAcceptance.fromJson(message.json);
        break;
      case MessageType.FORM:
        byClient.form = message.json.toForm();
        break;
      case MessageType.CALL:
        byClient.callEvent = call_pb.CallEvent.fromJson(message.json);
        break;
      case MessageType.TABLE:
        byClient.table = form_pb.Table.fromJson(message.json);
        break;
      case MessageType.LIVE_LOCATION:
      case MessageType.POLL:
      case MessageType.PERSISTENT_EVENT:
      case MessageType.NOT_SET:
      case MessageType.BUTTONS:
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      case MessageType.TRANSACTION:
      case MessageType.PAYMENT_INFORMATION:
      case MessageType.CALL_LOG:
        break;
    }
    return byClient;
  }
}
