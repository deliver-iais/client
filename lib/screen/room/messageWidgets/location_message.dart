import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
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
import 'package:maps_launcher/maps_launcher.dart';

import '../../../services/routing_service.dart';
import '../../../shared/widgets/room_name.dart';

class LocationMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;
  static final _routingServices = GetIt.I.get<RoutingService>();

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
                    isWeb
                            ?
                    //         LocationDialog(location: location, from: message.from.asUid(),);
                            // LocationDialog(location: location, from: message.from.asUid(),);
                            await showDialog(
                                context: context,
                                builder: (_) => LocationDialog(
                                  location: location,
                                  from: message.from.asUid(),
                                ),
                              )
                            :
                     Navigator.push(
                                context,
                                SlideRightRoute(
                                    page: LocationPage(
                                  location: location,
                                  from: message.from.asUid(),
                                  message: message,
                                )),
                              )
                        // _routingServices.openLocation(location, message.from.asUid())
                        ;
                  },
                ),
                layers: [
                  TileLayerOptions(
                    tileProvider: NetworkTileProvider(),
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        point: LatLng(location.latitude, location.longitude),
                        // builder: (ctx) =>
                        //     CircleAvatarWidget(message.from.asUid(), 20),
                        builder: (_) {
                          return GestureDetector(
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
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
  static final _routingServices = GetIt.I.get<RoutingService>();

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
          borderRadius: mainBorder,
          boxShadow: DEFAULT_BOX_SHADOWS,
        ),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(location.latitude, location.longitude),
            zoom: 15.0,
            enableMultiFingerGestureRace: true,
          ),
          layers: [
            TileLayerOptions(
              tileProvider: NetworkTileProvider(),
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                    point: LatLng(location.latitude, location.longitude),
                    builder: (_) {
                      return GestureDetector(
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                        ),
                      );
                    }),
              ],
            ),
          ],
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
  String _roomName = "";
  final Message message;

  LocationPage(
      {super.key,
      required this.location,
      required this.from,
      required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: _routingServices.backButtonLeading(),
        title: Text(_i18n.get("location")),
        actions: [
          IconButton(
              onPressed: () => MapsLauncher.launchCoordinates(location.latitude,
                  location.longitude, '$_roomName location'),
              icon: const Icon(CupertinoIcons.arrowshape_turn_up_right))
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(location.latitude, location.longitude),
              zoom: 15.0,
              enableMultiFingerGestureRace: true,
            ),
            layers: [
              TileLayerOptions(
                tileProvider: NetworkTileProvider(),
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(
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
                ],
              ),
            ],
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              height: 100,
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
                      vertical: 10.0, horizontal: 10.0),
                  child: Column(children: [
                    Row(
                      children: [
                        CircleAvatarWidget(from, 25),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<String>(
                              initialData: _roomRepo
                                  .fastForwardName(message.from.asUid()),
                              future: _roomRepo.getName(message.from.asUid()),
                              builder: (context, snapshot) {
                                _roomName =
                                    snapshot.data ?? _i18n.get("loading");
                                return RoomName(
                                    uid: message.from.asUid(), name: _roomName);
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                child:  Text("${farAwayDestination(message)}"),
                                )
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // Center(
                    //
                    // ),
                  ],),),
            ),
          )
        ],
      ),
    );
  }
}

Future<double> farAwayDestination(Message message)  async {
  final location = message.json.toLocation();
  final position = await _determinePosition() ;
  return Geolocator.distanceBetween(position.latitude, position.longitude, location.latitude, location.longitude);
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
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
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
