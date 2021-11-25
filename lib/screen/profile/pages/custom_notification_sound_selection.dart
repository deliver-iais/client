import 'package:audioplayers/audioplayers.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class CustomNotificationSoundSelection extends StatefulWidget {
  final String roomUid;
  AudioCache _player =
      AudioCache(prefix: 'android/', fixedPlayer: AudioPlayer());

  CustomNotificationSoundSelection({Key? key, required this.roomUid})
      : super(key: key);

  @override
  _CustomNotificationSoundSelectionState createState() =>
      _CustomNotificationSoundSelectionState();
}

class _CustomNotificationSoundSelectionState
    extends State<CustomNotificationSoundSelection> {
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
  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          i18n.get("choose_a_song"),
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
            padding: const EdgeInsets.all(12),
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
                child: Text(
                  i18n.get("ok"),
                )),
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
                bool isSelected = selectedFlag[index]!;
                return ListTile(
                  onLongPress: () => onLongPress(isSelected, index),
                  onTap: () => onTap(isSelected, index),
                  title: Text("$data"),
                  trailing: _buildSelectIcon(isSelected, data),
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
    });
    widget._player.fixedPlayer!.stop();
    widget._player.play("app/src/main/res/raw/${staticData[index]}.mp3");
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag.clear();
      selectedFlag[index] = !isSelected;
    });
  }

  Widget _buildSelectIcon(bool isSelected, String data) {
    final _shakeController = ShakeWidgetController();
    return StreamBuilder<Object>(
        stream: widget._player.fixedPlayer!.onPlayerStateChanged,
        builder: (context, snapshot) {
          return Container(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isSelected && snapshot.data == PlayerState.PLAYING)
                    ShakeWidget(
                        controller: _shakeController,
                        child: TGS.asset(
                          'assets/animations/audio_wave.tgs',
                          autoPlay: true,
                          width: 60,
                          height: 60,
                        )),
                  Lottie.asset('assets/animations/audio_wave.tgs',
                      width: 40, height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      isSelected
                          ? Icons.radio_button_checked_outlined
                          : Icons.radio_button_off,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ));
        });
  }
}
