import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CustomNotificationSoundSelection extends StatefulWidget {
  final String roomUid;

  CustomNotificationSoundSelection({Key key, this.roomUid}) : super(key: key);

  @override
  _CustomNotificationSoundSelectionState createState() =>
      _CustomNotificationSoundSelectionState();
}

class _CustomNotificationSoundSelectionState
    extends State<CustomNotificationSoundSelection> {
  bool isSelectionMode = false;
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  List<String> staticData = [
    "deduction",
    "done_for_you",
    "goes_without_saying",
    "open_up",
    "piece_of_cake",
    "point_blank",
    "pristine",
    "samsung",
    "swiftly",
    "that_was_quick"
  ];
  Map<int, bool> selectedFlag = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Choose a song',
          style: TextStyle(fontWeight: FontWeight.w600),
        )),
        leading: InkWell(
          child: Icon(Icons.clear),
          onTap: () {
            _routingService.pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: () {
                  var index = 0;
                  if (selectedFlag.containsValue(true)) {
                    for (int key in selectedFlag.keys) {
                      if (selectedFlag[key] == true) index = key;
                    }
                    _roomRepo.setRoomCustomNotification(
                        widget.roomUid, staticData[index]);
                  }
                  _routingService.pop();
                },
                child: Text("Ok")),
          )
        ],
      ),
      body: FutureBuilder(
        future: _roomRepo.getRoomCustomNotification(widget.roomUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (builder, index) {
                String data = staticData[index];
                selectedFlag[index] = selectedFlag[index] ?? false;
                bool isSelected = selectedFlag[index];
                return ListTile(
                  onLongPress: () => onLongPress(isSelected, index),
                  onTap: () => onTap(isSelected, index),
                  title: Text("${data}"),
                  leading: _buildSelectIcon(isSelected, data),
                );
              },
              itemCount: staticData.length,
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag.clear();
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag.clear();
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  Widget _buildSelectIcon(bool isSelected, String data) {
    if (isSelectionMode) {
      return Icon(
        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        color: Theme.of(context).primaryColor,
      );
    } else {
      return CircleAvatar(
        child: Text('${data.substring(0, 1)}'),
      );
    }
  }
}
