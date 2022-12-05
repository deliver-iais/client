import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/widgets/tgs.dart';
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
  final List _customNotificationSounds = [
    ["no sound","no_sound"],
    ["deduction","deduction"],
    ["done for you","done_for_you"],
    ["goes without saying","goes_without_saying"],
    ["open up","open_up"],
    ["piece of cake","piece_of_cake"],
    ["point blank","point_blank"],
    ["pristine","pristine"],
    ["samsung","samsung"],
    ["swiftly","swiftly"],
    ["that was quick","that_was_quick"]
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
    _selectedSongIndex = _customNotificationSounds.indexOf(selectedSong ?? "-");
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
                "-",
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
                return ListTile(
                  onLongPress: () => onTap(
                    index,
                  ),
                  onTap: () => onTap(index),
                  title: Text(data),
                  trailing: _buildSelectIcon(index),
                );
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
                const Tgs.asset(
                  'assets/animations/audio_wave.tgs',
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
