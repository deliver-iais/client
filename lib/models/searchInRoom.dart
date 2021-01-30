import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

class SearchInRoom{
  Uid uid;
  String name;
  String lastName;
  String username;

  SearchInRoom({this.uid, this.name, this.lastName, this.username});
}