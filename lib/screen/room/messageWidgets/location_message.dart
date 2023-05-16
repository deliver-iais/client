import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as map;
import 'package:map_launcher/map_launcher.dart';

class LocationMessageWidget extends StatelessWidget {
  static final _routingServices = GetIt.I.get<RoutingService>();

  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const LocationMessageWidget({
    super.key,
    required this.message,
    required this.isSeen,
    required this.isSender,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final location = message.json.toLocation();
    final theme = Theme.of(context);
    return Stack(
      children: [
        SizedBox(
          width: 270,
          height: 170,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              // onEnter: (event) {
              //   _settings.scrollPhysics
              //       .add(const NeverScrollableScrollPhysics());
              // },
              // onExit: (event) {
              //   _settings.scrollPhysics.add(const ClampingScrollPhysics());
              // },
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(location.latitude, location.longitude),
                  zoom: DEFAULT_ZOOM_LEVEL,
                  enableScrollWheel: false,
                  onTap: (_, point) async {
                    isDesktopDevice
                        ? await showDialog(
                            context: context,
                            builder: (_) => LocationDialog(
                              location: location,
                              from: message.from.asUid(),
                            ),
                          )
                        : _routingServices.openLocation(
                            location,
                            message.from.asUid(),
                            message,
                          );
                  },
                ),
                children: [
                  TileLayer(
                    tileProvider: NetworkTileProvider(),
                    tilesContainerBuilder: settings.themeIsDark.value
                        ? darkModeTilesContainerBuilder
                        : null,
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(location.latitude, location.longitude),
                        builder: (_) {
                          return GestureDetector(
                            child: Icon(
                              Icons.location_pin,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        TimeAndSeenStatus(
          message,
          isSender: isSender,
          isSeen: isSeen,
          needsPadding: true,
          showBackground: true,
        ),
      ],
    );
  }
}

class LocationDialog extends StatelessWidget {
  final Location location;
  final Uid from;
  final double size = isDesktopDevice ? 500 : 350;
  static final _i18n = GetIt.I.get<I18N>();

  LocationDialog({super.key, required this.location, required this.from});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: messageBorder,
          boxShadow: DEFAULT_BOX_SHADOWS,
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.clear_circled),
            ),
            title: Text(_i18n.get("location")),
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: LatLng(location.latitude, location.longitude),
                  zoom: DEFAULT_ZOOM_LEVEL,
                  enableMultiFingerGestureRace: true,
                ),
                children: [
                  TileLayer(
                    tileProvider: NetworkTileProvider(),
                    tilesContainerBuilder: settings.themeIsDark.value
                        ? darkModeTilesContainerBuilder
                        : null,
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(location.latitude, location.longitude),
                        builder: (ctx) => CircleAvatarWidget(from, 20),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                        const Size(350, 50),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsetsDirectional.all(10),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onPressed: () => MapLauncher.showMarker(
                      mapType: MapType.google,
                      coords: map.Coords(location.latitude, location.longitude),
                      title: locationToString(location),
                    ),
                    child: Text(_i18n.get("open_in")),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPage extends StatefulWidget {
  final Location location;
  final Uid from;
  final Message message;

  const LocationPage({
    super.key,
    required this.location,
    required this.from,
    required this.message,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _checkPermissionsService = GetIt.I.get<CheckPermissionsService>();

  final _routingServices = GetIt.I.get<RoutingService>();

  final _i18n = GetIt.I.get<I18N>();

  final _roomRepo = GetIt.I.get<RoomRepo>();

  final position = _determinePosition();

  late final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: _routingServices.backButtonLeading(),
        title: Text(_i18n.get("location")),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () async {
                        isIOSNative
                            ? await MapLauncher.showMarker(
                                mapType: MapType.apple,
                                coords: map.Coords(
                                  widget.location.latitude,
                                  widget.location.longitude,
                                ),
                                title: locationToString(widget.location),
                              )
                            : MapLauncher.showMarker(
                                mapType: MapType.google,
                                coords: map.Coords(
                                  widget.location.latitude,
                                  widget.location.longitude,
                                ),
                                title: locationToString(widget.location),
                              );
                      },
                      child: Text(_i18n.get("open_in")),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<Position>(
            future: _determinePosition(),
            builder: (context, snapshot) {
              final position = snapshot.data;
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(
                    widget.location.latitude,
                    widget.location.longitude,
                  ),
                  zoom: DEFAULT_ZOOM_LEVEL,
                  enableMultiFingerGestureRace: true,
                ),
                children: [
                  TileLayer(
                    tileProvider: NetworkTileProvider(),
                    tilesContainerBuilder: settings.themeIsDark.value
                        ? darkModeTilesContainerBuilder
                        : null,
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      if (position != null)
                        Marker(
                          point: LatLng(position.latitude, position.longitude),
                          builder: (_) {
                            return Container(
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsetsDirectional.all(8),
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
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      Marker(
                        point: LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
                        builder: (_) {
                          return GestureDetector(
                            child: Icon(
                              Icons.location_on_sharp,
                              color: Theme.of(context).colorScheme.error,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 10,
            bottom: 144,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: FutureBuilder<Position>(
                future: _determinePosition(),
                builder: (context, snapshot) {
                  final position = snapshot.data;
                  return IconButton(
                    onPressed: () {
                      if (position != null) {
                        _mapController.move(
                          LatLng(position.latitude, position.longitude),
                          15,
                        );
                      } else {
                        _checkPermissionsService.haveLocationPermission();
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.my_location_sharp),
                    color: theme.colorScheme.primary,
                    iconSize: 30,
                    padding: const EdgeInsetsDirectional.all(1.0),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              height: 140,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  topLeft: Radius.circular(15.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatarWidget(widget.from, 25),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 1,
                            ),
                            FutureBuilder<String>(
                              initialData: _roomRepo.fastForwardName(
                                widget.message.from.asUid(),
                              ),
                              future: _roomRepo
                                  .getName(widget.message.from.asUid()),
                              builder: (context, snapshot) {
                                final roomName =
                                    snapshot.data ?? _i18n.get("loading");
                                return RoomName(
                                  uid: widget.message.from.asUid(),
                                  name: roomName,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                              future: _distance(widget.message),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final distance =
                                      double.parse("${snapshot.data}")
                                          .toStringAsFixed(3);
                                  return Text(
                                    "$distance ${_i18n.get("away")}",
                                  );
                                } else {
                                  return FutureBuilder<bool>(
                                    future: _checkPermissionsService
                                        .haveLocationPermission(),
                                    builder: (context, havePermission) {
                                      if (havePermission.hasData &&
                                          havePermission.data != null &&
                                          havePermission.data!) {
                                        return Text(
                                          _i18n.get("locating"),
                                        );
                                      } else {
                                        return const Text(" ");
                                      }
                                    },
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size(380, 50),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsetsDirectional.all(10),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                theme.colorScheme.primary,
                              ),
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              isIOSNative
                                  ? await MapLauncher.showDirections(
                                      mapType: MapType.apple,
                                      destination: map.Coords(
                                        widget.location.latitude,
                                        widget.location.longitude,
                                      ),
                                    )
                                  : MapLauncher.showDirections(
                                      mapType: MapType.google,
                                      destination: map.Coords(
                                        widget.location.latitude,
                                        widget.location.longitude,
                                      ),
                                    );
                            },
                            child: Text(
                              _i18n.get("direction"),
                              style: TextStyle(
                                color: theme.colorScheme.surface,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Future<double> _distance(Message message) async {
  final location = message.json.toLocation();
  final position = await _determinePosition();
  final distance = Geolocator.distanceBetween(
    position.latitude,
    position.longitude,
    location.latitude,
    location.longitude,
  );
  return distance;
}

Future<Position> _determinePosition() async {
  final checkPermissionsService = GetIt.I.get<CheckPermissionsService>();
  if (await checkPermissionsService.haveLocationPermission()) {
    return checkPermissionsService.getCurrentPosition();
  } else {
    return Future.error('Location permissions are denied');
  }
}

String locationToString(Location location) {
  return "${location.latitude}, ${location.longitude}";
}
