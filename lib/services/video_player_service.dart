import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';

class VideoPlayerService {
  Player? currentDesktopPlayer;
  Map<int, Player> desktopPlayers = {};

  Player createDesktopPlayer(String videoFilePath) {
    currentDesktopPlayer?.stop();
    currentDesktopPlayer = Player(id: videoFilePath.hashCode);
    desktopPlayers[videoFilePath.hashCode] = currentDesktopPlayer!;
    currentDesktopPlayer?.open(
      Playlist(
        medias: [
          Media.file(
            File(videoFilePath),
          ),
        ],
      ),
    );
    return currentDesktopPlayer!;
  }
}
