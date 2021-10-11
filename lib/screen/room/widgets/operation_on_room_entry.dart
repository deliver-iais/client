import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:flutter/material.dart';

class OperationOnRoomEntry extends PopupMenuEntry<OperationOnRoom> {
  final bool isPinned;

  OperationOnRoomEntry({this.isPinned = false});

  @override
  OperationOnRoomEntryState createState() => OperationOnRoomEntryState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnRoom value) {}
}

class OperationOnRoomEntryState extends State<OperationOnRoomEntry> {
  onPinMessage() {
    Navigator.pop<OperationOnRoom>(context, OperationOnRoom.PIN_ROOM);
  }

  onUnPinMessage() {
    Navigator.pop<OperationOnRoom>(context, OperationOnRoom.UN_PIN_ROOM);
  }

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.isPinned)
              TextButton(
                  onPressed: () {
                    onPinMessage();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.push_pin,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(i18n.get("pin_room")),
                  ]))
            else
              TextButton(
                  onPressed: () {
                    onUnPinMessage();
                  },
                  child: Row(children: [
                    Icon(
                      Icons.remove,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(i18n.get("unpin_room")),
                  ])),
          ],
        ),
      ),
    );
  }
}
