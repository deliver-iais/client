class ServicesDiscoveryRepo {
  ConnectionDetails AvatarConnectipon = ConnectionDetails()
    ..host = "172.16.111.171"
    ..port = 30000;

  ConnectionDetails AuthConnection = ConnectionDetails()
    ..host = " 172.16.111.171"
    ..port = 30000;
}

class ConnectionDetails {
  String host;
  int port;
}
