import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
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
import '../../../services/routing_service.dart';
import '../../../shared/widgets/room_name.dart';

class LocationMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;
  static final _routingServices = GetIt.I.get<RoutingService>();
  final _uxService = GetIt.I.get<UxService>();

   LocationMessageWidget({
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
              //   _uxService.scrollPhysics
              //       .add(const NeverScrollableScrollPhysics());
              // },
              // onExit: (event) {
              //   _uxService.scrollPhysics.add(const ClampingScrollPhysics());
              // },
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(location.latitude, location.longitude),
                  zoom: 15.0,
                  enableScrollWheel: false,
                  onTap: (_, point) async {
                    isWeb || isDesktop
                        ?
                        // LocationDialog(location: location, from: message.from.asUid(),);
                        // LocationDialog(location: location, from: message.from.asUid(),);
                        await showDialog(
                            context: context,
                            builder: (_) => LocationDialog(
                              location: location,
                              from: message.from.asUid(),
                            ),
                          )
                        :
                        // Navigator.push(
                        //   context,
                        //   SlideRightRoute(
                        //       page: LocationPage(
                        //         location: location,
                        //         from: message.from.asUid(),
                        //         message: message,
                        //       )),
                        // )
                        _routingServices.openLocation(
                            location,
                            message.from.asUid(),
                            message,
                          );
                  },
                ),
                children: [
                  TileLayer(
                    tileProvider: NetworkTileProvider(),
                    tilesContainerBuilder: _uxService.themeIsDark
                        ? darkModeTilesContainerBuilder
                        : null,
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(location.latitude, location.longitude),
                        // builder: (ctx) =>
                        //     CircleAvatarWidget(message.from.asUid(), 20),
                        builder: (_) {
                          return GestureDetector(
                            child:  Icon(
                              Icons.location_pin,
                              color: Theme.of(context).errorColor,
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
  final double size = isDesktop ? 500 : 350;
  static final _i18n = GetIt.I.get<I18N>();
  final _uxService = GetIt.I.get<UxService>();
  final String _roomName = "";

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
                  zoom: 15.0,
                  enableMultiFingerGestureRace: true,
                ),
                children: [
                  TileLayer(
                    tileProvider: NetworkTileProvider(),
                    tilesContainerBuilder: _uxService.themeIsDark
                        ? darkModeTilesContainerBuilder
                        : null,
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
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
                alignment: FractionalOffset.bottomLeft,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: FloatingActionButton(
                      heroTag: 'zoomInButton',
                      mini: true,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      onPressed: () {
                        // final bounds = map.bounds;
                        // final centerZoom = map.getBoundsCenterZoom(bounds, options);
                        // var zoom = centerZoom.zoom + 1;
                        // if (zoom > maxZoom) {
                        //   zoom = maxZoom;
                        // }
                        // map.move(centerZoom.center, zoom,
                        //     source: MapEventSource.custom);
                      },
                      child: const Icon(Icons.zoom_in, color: Colors.black),
                    ),
                  )
                ]),
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
                        const EdgeInsets.all(10),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onPressed: () => MapLauncher.showMarker(
                      mapType: MapType.google,
                      coords: map.Coords(location.latitude, location.longitude),
                      title: "$_roomName location",
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

class LocationPage extends StatelessWidget {
  final Location location;
  final Uid from;
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _uxService = GetIt.I.get<UxService>();
  String _roomName = "";
  final position = _determinePosition();
  final Message message;
  late final MapController _mapController = MapController();

  // final List<AvailableMap> availableMaps =  map.MapLauncher.installedMaps();

  LocationPage({
    super.key,
    required this.location,
    required this.from,
    required this.message,
  });

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
                        isIOS
                            ? await MapLauncher.showMarker(
                                mapType: MapType.apple,
                                coords: map.Coords(
                                    location.latitude, location.longitude),
                                title: "$_roomName location",
                              )
                            : MapLauncher.showMarker(
                                mapType: MapType.google,
                                coords: map.Coords(
                                    location.latitude, location.longitude),
                                title: "$_roomName location",
                              );
                      },

                      // onPressed: () {
                      //   showGeneralDialog(context: context,
                      //       pageBuilder: (context,animation1 , animation2){
                      //         return Align(
                      //           alignment: Alignment.bottomCenter,
                      //           child: Container(
                      //             height: 200,
                      //             width: MediaQuery.of(context).size.width,
                      //             decoration: BoxDecoration(
                      //               color: theme.colorScheme.surface,
                      //               borderRadius: const BorderRadius.only(
                      //                 topRight: Radius.circular(15.0),
                      //                 topLeft: Radius.circular(15.0),
                      //               ),
                      //             ),
                      //             child: Column(
                      //               children:  [
                      //                 Text(_i18n.get("open_in")),
                      //                 Container(
                      //
                      //                 ),
                      //                 TextButton(
                      //                   onPressed: () => Navigator.pop(context),
                      //                   child: const Text("cancel"),
                      //
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //
                      //         );
                      //       },
                      //     transitionBuilder: (_, animation1,animation2 , child) {
                      //     return SlideTransition(
                      //       position: Tween(
                      //         begin: const Offset(0, 1),
                      //         end: const Offset(0, 0),
                      //       ).animate(animation1),
                      //       child: child,
                      //     );
                      //   }
                      //       // transitionBuilder: (context,animation1,animation2,child){
                      //   );
                      //
                      // },
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
                  center: LatLng(location.latitude, location.longitude),
                  zoom: 15.0,
                  enableMultiFingerGestureRace: true,
                ),
                children: [
                  TileLayer(
                    tileProvider: NetworkTileProvider(),
                    tilesContainerBuilder: _uxService.themeIsDark
                        ? darkModeTilesContainerBuilder
                        : null,
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    // subdomains: ['a', 'b', 'c'],
                    // tilesContainerBuilder:
                    // darkMode ? darkModeTilesContainerBuilder : null,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(location.latitude, location.longitude),
                        builder: (_) {
                          return GestureDetector(
                            child: Icon(
                              Icons.location_on_sharp,
                              color: Theme.of(context).errorColor,
                              size: 28,
                            ),
                          );
                        },
                      ),
                      if (position != null)
                        Marker(
                          point: LatLng(position.latitude, position.longitude),
                          builder: (_) {
                            return Container(
                              width: 1000.0,
                              height: 1000.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                // borderRadius: BorderRadius.circular(48.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: (Colors.lightBlue[100])!,
                                    blurRadius: 20.0,
                                  )
                                ],
                              ),
                              child:  Icon(
                                Icons.circle_sharp,
                                color: theme.colorScheme.primary,
                                size: 14,
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
                      }

                      // _mapController.
                    },
                    icon: const Icon(Icons.my_location_sharp),
                    color: theme.colorScheme.primary,
                    iconSize: 30,
                    padding: const EdgeInsets.all(1.0),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatarWidget(from, 25),
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
                              initialData: _roomRepo
                                  .fastForwardName(message.from.asUid()),
                              future: _roomRepo.getName(message.from.asUid()),
                              builder: (context, snapshot) {
                                _roomName =
                                    snapshot.data ?? _i18n.get("loading");
                                return RoomName(
                                  uid: message.from.asUid(),
                                  name: _roomName,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                              future: _distance(message),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var distance = snapshot.data;
                                  distance = double.parse("$distance")
                                      .toStringAsFixed(3);
                                  return Text("$distance ${_i18n.get("away")}");
                                } else {
                                  return Text(_i18n.get("locating"));
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
                                const EdgeInsets.all(10),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  theme.colorScheme.primary),
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              isIOS
                                  ? await MapLauncher.showDirections(
                                      mapType: MapType.apple,
                                      destination: map.Coords(
                                        location.latitude,
                                        location.longitude,
                                      ),
                                    )
                                  : MapLauncher.showDirections(
                                      mapType: MapType.google,
                                      destination: map.Coords(
                                        location.latitude,
                                        location.longitude,
                                      ),
                                    );
                            },
                            child: Text(
                              _i18n.get("direction"),
                              style:
                                  TextStyle(color: theme.colorScheme.surface),
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
  return distance / 1609.344;
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return Geolocator.getCurrentPosition();
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

// class BottomDialog {
//   void showBottomDialog(BuildContext context) {
//     showGeneralDialog(
//       barrierLabel: "showGeneralDialog",
//       barrierDismissible: true,
//       barrierColor: Colors.black.withOpacity(0.6),
//       transitionDuration: const Duration(milliseconds: 400),
//       context: context,
//       pageBuilder: (context, _, ) {
//         return Align(
//           alignment: Alignment.bottomCenter,
//           child: _buildDialogContent(),
//         );
//       },
//       transitionBuilder: (_, animation1, , child) {
//     return SlideTransition(
//     position: Tween(
//     begin: const Offset(0, 1),
//     end: const Offset(0, 0),
//     ).animate(animation1),
//     child: child,
//     );
//     },
//     );
//   }
