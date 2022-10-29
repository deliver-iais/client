import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';

class PointToLatLngPage extends StatefulWidget {
  Position position;
  Uid roomUid;

  PointToLatLngPage({Key? key, required this.position, required this.roomUid})
      : super(key: key);

  @override
  PointToLatlngPage createState() {
    return PointToLatlngPage();
  }
}

class PointToLatlngPage extends State<PointToLatLngPage> {
  late final MapController mapController = MapController();
  final pointSize = 10.0;
  final pointY = 100.0;
  late LatLng latLng;

  final _i18n = GetIt.I.get<I18N>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  // late final BuildContext context;

  @override
  void initState() {
    super.initState();
    latLng = LatLng(widget.position.latitude, widget.position.longitude);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // updatePoint(null, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _uxService = GetIt.I.get<UxService>();
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                onMapEvent: (event) {
                  updatePoint(null, context);
                },
                center: latLng,
                zoom: 5,
                minZoom: 15,
              ),
              children: [
                TileLayer(
                  tilesContainerBuilder: _uxService.themeIsDark
                      ? darkModeTilesContainerBuilder
                      : null,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      // width: pointSize,
                      // height: pointSize,
                      point: LatLng(
                          widget.position.latitude, widget.position.longitude,),
                      builder: (_) {
                        return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(48.0),
                              boxShadow: [
                                BoxShadow(
                                  color: (theme.colorScheme.primary
                                      .withOpacity(0.7)),
                                  blurRadius: 20.0,
                                )
                              ],
                            ),
                            child: Container(
                                width: 200,
                                height: 200,
                                // padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                    color: theme.colorScheme.primary)));
                      },
                    ),
                      Marker(
                        point: latLng,
                        builder: (_) {
                          return GestureDetector(
                            child: Icon(
                              Icons.location_pin,
                              color: Theme.of(context).errorColor,
                              size: 28,
                            ),
                          );
                        },
                      )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Column(
            children: [
              Directionality(
                textDirection: _i18n.defaultTextDirection,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Material(
                            color: theme.primaryColor, // button color
                            child: InkWell(
                              splashColor: theme.shadowColor.withOpacity(0.3),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.position.latitude != latLng.latitude || widget.position.longitude != latLng.longitude)
                              Text(
                                _i18n.get(
                                  "send_this_location",
                                ),
                                style: const TextStyle(fontSize: 18),
                              )
                            else
                              Text(
                                _i18n.get(
                                  "send_current_location",
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                            if (widget.position.latitude != latLng.latitude || widget.position.longitude != latLng.longitude )
                              Text("${latLng.latitude},${latLng.longitude}")
                            else
                              Text("${widget.position.accuracy}")
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _messageRepo.sendLocationMessage(
                      // LatLng(widget.position.latitude, widget.position.longitude),
                      latLng,
                      widget.roomUid,
                    );
                  },
                ),
              ),
              const Divider(),
            ],
          ),
        ],
      ),
    );
  }
  void updatePoint(MapEvent? event, BuildContext context) {
    final pointX = _getPointX(context);
    setState(() {
      final newLocation =
          mapController.pointToLatLng(CustomPoint(pointX, pointY));
      if (newLocation != null) {
        latLng = newLocation;
      }
    });
  }
  double _getPointX(BuildContext context) {
    return MediaQuery.of(context).size.width / 2;
  }
}

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
        print(position.data);
        if (position.hasData && position.data != null) {
          return PointToLatLngPage(
            position: position.data!,
            roomUid: roomUid,
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
        zoom: 24.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 170.0,
              height: 170.0,
              point: LatLng(
                position.latitude,
                position.longitude,
              ),
              builder: (ctx) => Icon(
                Icons.location_pin,
                color: Theme.of(context).errorColor,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: tertiaryBorder,
                    ),
                  ),
                  onPressed: () => Navigator.pop(c),
                  child: Text(_i18n.get("cancel")),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: tertiaryBorder,
                    ),
                  ),
                  onPressed: () {
                    _messageRepo.sendLocationMessage(
                        LatLng(position.latitude, position.longitude), roomUid,);
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
    final theme = Theme.of(context);
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
                      color: theme.primaryColor,
                      child: Icon(
                        Icons.location_on,
                        color: theme.primaryColorLight,
                        size: 40,
                      ),
                    ),
                    Text(
                      i18n.get("choose_live_location_time"),
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          child: Text(
                            i18n.get("cancel"),
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.primaryColor,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        GestureDetector(
                          child: Text(
                            i18n.get("share"),
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).errorColor,
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
    final theme = Theme.of(context);
    return SettingsTile(
      title: t,
      leading: Icon(
        Icons.alarm,
        color: theme.primaryColor,
      ),
      trailing: data == t
          ? Icon(
              Icons.done,
              color: theme.primaryColor,
            )
          : const SizedBox.shrink(),
      onPressed: (context) {
        on();
      },
    );
  }
}
