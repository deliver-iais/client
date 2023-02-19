import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class CustomNotificationSoundSelection extends StatefulWidget {
  final String roomUid;

  const CustomNotificationSoundSelection({super.key, required this.roomUid});

  @override
  CustomNotificationSoundSelectionState createState() =>
      CustomNotificationSoundSelectionState();
}

class CustomNotificationSoundSelectionState
    extends State<CustomNotificationSoundSelection> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _audioService = GetIt.I.get<AudioService>();
  late final _customNotificationSounds = <List<String>>[
    [_roomRepo.getCustomNotificationShowingName("no_sound"), "no_sound"],
    [
      _roomRepo.getCustomNotificationShowingName("that_was_quick"),
      "that_was_quick"
    ],
    [_roomRepo.getCustomNotificationShowingName("deduction"), "deduction"],
    [
      _roomRepo.getCustomNotificationShowingName("done_for_you"),
      "done_for_you"
    ],
    [
      _roomRepo.getCustomNotificationShowingName("goes_without_saying"),
      "goes_without_saying"
    ],
    [_roomRepo.getCustomNotificationShowingName("open_up"), "open_up"],
    [
      _roomRepo.getCustomNotificationShowingName("piece_of_cake"),
      "piece_of_cake"
    ],
    [_roomRepo.getCustomNotificationShowingName("point_blank"), "point_blank"],
    [_roomRepo.getCustomNotificationShowingName("pristine"), "pristine"],
    [_roomRepo.getCustomNotificationShowingName("samsung"), "samsung"],
    [_roomRepo.getCustomNotificationShowingName("swiftly"), "swiftly"],
  ];

  int _selectedSongIndex = -1;

  void _addLifeCycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message != null && message == AppLifecycleState.inactive.toString()) {
        _audioService.stopTemporaryAudio();
      }
      return message;
    });
  }

  @override
  void dispose() {
    _audioService.stopTemporaryAudio();
    super.dispose();
  }

  @override
  void initState() {
    _addLifeCycleListener();
    initialSelectedIndex();

    super.initState();
  }

  Future<void> initialSelectedIndex() async {
    final selectedSong =
        await _roomRepo.getRoomCustomNotification(widget.roomUid);
    _selectedSongIndex = _customNotificationSounds.indexWhere((element) {
      return (element[1] == selectedSong);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _i18n.get("choose_a_song"),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        leading: InkWell(
          child: const Icon(Icons.check),
          onTap: () {
            if (_selectedSongIndex != -1) {
              _roomRepo.setRoomCustomNotification(
                widget.roomUid,
                _customNotificationSounds[_selectedSongIndex][1],
              );
            } else {
              _roomRepo.setRoomCustomNotification(
                widget.roomUid,
                "that_was_quick",
              );
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: _roomRepo.getRoomCustomNotification(widget.roomUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (builder, index) {
                final data = _customNotificationSounds[index][0];
                if (index == 0) {
                  return ListTile(
                    onLongPress: () => onTap(
                      index,
                    ),
                    onTap: () => onTap(index),
                    title: Text(data),
                    trailing: _buildSelectIcon(index),
                    tileColor:
                        Theme.of(context).colorScheme.error.withOpacity(0.3),
                  );
                } else {
                  return ListTile(
                    onLongPress: () => onTap(
                      index,
                    ),
                    onTap: () => onTap(index),
                    title: Text(data),
                    trailing: _buildSelectIcon(index),
                  );
                }
              },
              itemCount: _customNotificationSounds.length,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void onTap(int index) {
    if (_selectedSongIndex == index) {
      _selectedSongIndex = -1;
      _audioService.stopTemporaryAudio();
    } else {
      _selectedSongIndex = index;
      _audioService.playTemporaryAudio(
        AudioSourcePath.asset(
          "app/src/main/res/raw/${_customNotificationSounds[index][1]}.mp3",
        ),
        prefix: "android/",
      );
    }
  }

  Widget _buildSelectIcon(int index) {
    final theme = Theme.of(context);
    return StreamBuilder<Object>(
      stream: _audioService.temporaryPlayerState,
      builder: (context, snapshot) {
        return SizedBox(
          width: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_selectedSongIndex == index &&
                  snapshot.data == AudioPlayerState.playing)
                const Ws.asset(
                  'assets/animations/audio_wave.ws',
                  width: 40,
                  height: 60,
                ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  _selectedSongIndex == index
                      ? Icons.radio_button_checked_outlined
                      : Icons.radio_button_off,
                  color: theme.primaryColor,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
