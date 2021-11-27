import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'bot_info.g.dart';

@HiveType(typeId: BOT_INFO_TRACK_ID)
class BotInfo {
  // DbId
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? description;

  @HiveField(2)
  String? name;

  @HiveField(3)
  Map<String, String>? commands;

  @HiveField(4)
  bool? isOwner;

  BotInfo({required this.uid, this.description, this.name, this.commands, this.isOwner});
}
