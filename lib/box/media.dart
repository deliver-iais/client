
import 'package:deliver_flutter/box/media_type.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';


part 'media.g.dart';

@HiveType(typeId: MEDIA_TRACK_ID)
class Media {


  // DbId
  @HiveField(0)
  int createdOn;

  @HiveField(1)
  String createdBy;

  @HiveField(2)
  String json;

  @HiveField(3)
  String roomId;

  @HiveField(4)
  int messageId;


  @HiveField(5)
   MediaType type;


  Media(
      { this.createdOn, this.json, this.roomId, this.messageId,this.type,this.createdBy});


}