import 'dart:convert';
import 'dart:ffi';

import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/sticker.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:fixnum/fixnum.dart';

extension JsonMapper on String {
  File toFile() {
    // return File.fromJson(this);
    File f = File.create();
    f.uuid = (jsonDecode(this))['uuid'];
    // f.size = Int64.parseInt((jsonDecode(this))['size'].toString());
    f.size = Int64.parseInt('60000');
    f.type = (jsonDecode(this))['type'];
    f.name = (jsonDecode(this))['name'];
    f.caption = (jsonDecode(this))['caption'];
    f.width = 200;
    f.height = 200;
    f.duration = 0.0;
    return f;
  }

  Sticker toSticker() {
    return Sticker.fromJson(this);
  }

  Text toText() {
    // return Text.fromJson(this);
    Text t = Text.create();
    t.text = (jsonDecode(this))['text'];
    return t;
  }

  Location toLocation() {
    return Location.fromJson(this);
  }

  PaymentTransaction toPaymentTransaction() {
    return PaymentTransaction.fromJson(this);
  }

  Poll toPoll() {
    return Poll.fromJson(this);
  }

  Form toForm() {
    return Form.fromJson(this);
  }

  LiveLocation toLiveLocation() {
    return LiveLocation.fromJson(this);
  }

  PersistentEvent toPersistentEvent() {
    return PersistentEvent.fromJson(this);
  }
}
