class ServicesDiscoveryRepo {
  // todo  call services to get host and port for any microServices..
  ConnectionDetails AvatarConnection = ConnectionDetails()
    ..host = "172.16.111.171"
    ..port = 30000;

  ConnectionDetails AuthConnection = ConnectionDetails()
    ..host = " 172.16.111.171"
    ..port = 30000;

  ConnectionDetails FileConnection = ConnectionDetails()
    ..host = "172.16.111.171"
    ..port = 30000;
}

class ConnectionDetails {
  String host;
  int port;
}
