import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';

class AttachLocation {
  final _i18n = GetIt.I.get<I18N>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final BuildContext context;
  final Uid roomUid;

  AttachLocation(this.context, this.roomUid);

  FutureBuilder<Position> showLocation() {
    return FutureBuilder(
      future: Geolocator.getCurrentPosition(),
      builder: (c, position) {
        if (position.hasData && position.data != null) {
          return ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3 - 40,
                child: _buildFlutterMap(position.data!),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Icon(
                        Icons.location_on_sharp,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                    ),
                    Text(
                      _i18n.get(
                        "send_this_location",
                      ),
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _messageRepo.sendLocationMessage(
                    position.data!,
                    roomUid,
                  );
                },
              ),
              const SizedBox(
                height: 5,
              ),
              const Divider(),
              //todo  liveLocation
              // GestureDetector(
              //   behavior: HitTestBehavior.translucent,
              //   onTap: () {
              //     liveLocation(i18n, context,position.data);
              //   },
              //   child: Row(
              //     children: [
              //       Container(
              //           child: l.Lottie.asset(
              //             'assets/animations/liveLocation.json',
              //             width: 40,
              //             height: 40,
              //           )),
              //       Text(
              //         i18n.get(
              //           "send_live_location",
              //         ),
              //         style: TextStyle(fontSize: 18),
              //       )
              //     ],
              //   ),
              // )
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  FlutterMap _buildFlutterMap(Position position) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 14.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 170.0,
              height: 170.0,
              point: LatLng(
                position.latitude,
                position.longitude,
              ),
              builder: (ctx) => const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> attachLocationInWindows() async {
    final geoLocatorWindows = GeolocatorPlatform.instance;
    if (!await geoLocatorWindows.isLocationServiceEnabled()) {
      showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text(
              _i18n.get("enable_location_services"),
            ),
            content: Text(
              _i18n.get(
                "enable_location_services_in_windows_helper",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(_i18n.get("i_realized")),
              )
            ],
          );
        },
      ).ignore();
    } else {
      if ((await geoLocatorWindows.checkPermission()) ==
          LocationPermission.denied) {
        final res = await geoLocatorWindows.requestPermission();
        if (res == LocationPermission.denied ||
            res == LocationPermission.deniedForever) {
          showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                title: Text(
                  _i18n.get("enable_location_services"),
                ),
                content: Text(
                  _i18n.get(
                    "enable_location_services_in_windows_helper",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(_i18n.get("i_realized")),
                  )
                ],
              );
            },
          ).ignore();
        }
      } else {
        final position = await geoLocatorWindows.getCurrentPosition();
        showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              title: Text(_i18n.get("send_location")),
              content: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: _buildFlutterMap(position),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                    onPrimary: Theme.of(context).colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: tertiaryBorder,
                    ),
                  ),
                  onPressed: () => Navigator.pop(c),
                  child: Text(_i18n.get("cancel")),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                    onPrimary: Theme.of(context).colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: tertiaryBorder,
                    ),
                  ),
                  onPressed: () {
                    _messageRepo.sendLocationMessage(position, roomUid);
                    Navigator.pop(c);
                  },
                  child: Text(_i18n.get("send")),
                ),
              ],
            );
          },
        ).ignore();
      }
    }
  }

  void liveLocation(I18N i18n, BuildContext context, Position position) {
    final time = BehaviorSubject<String>.seeded("10");
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<String>(
          stream: time,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.only(top: 300, left: 30, right: 30),
              child: Center(
                child: ListView(
                  children: [
                    Container(
                      height: 50,
                      color: Colors.blue,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.greenAccent,
                        size: 40,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        i18n.get("choose_livelocation_time"),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: SizedBox(
                        height: 200,
                        child: ListView(
                          children: [
                            Section(
                              children: [
                                settingsTile(snapshot.data!, "10", () {
                                  time.add("10");
                                }),
                                settingsTile(snapshot.data!, "15", () {
                                  time.add("15");
                                }),
                                settingsTile(snapshot.data!, "30", () {
                                  time.add("30");
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Text(
                              i18n.get("cancel"),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          GestureDetector(
                            child: Text(
                              i18n.get("share"),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _messageRepo.sendLiveLocationMessage(
                                roomUid,
                                int.parse(time.value),
                                position,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  SettingsTile settingsTile(String data, String t, void Function() on) {
    return SettingsTile(
      title: t,
      leading: const Icon(
        Icons.alarm,
        color: Colors.blueAccent,
      ),
      trailing: data == t
          ? const Icon(
              Icons.done,
              color: Colors.blueAccent,
            )
          : const SizedBox.shrink(),
      onPressed: (context) {
        on();
      },
    );
  }
}
