class ServicesDiscoveryRepo {
  // todo  call services to get host and port for any microServices..
  ConnectionDetails avatarConnection = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30070;

  ConnectionDetails authConnection = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30000;

  ConnectionDetails fileConnection = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30010;

  ConnectionDetails contactServices = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30000;


  ConnectionDetails fireBaseServices = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30000;


  ConnectionDetails mucServices = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30101;

  ConnectionDetails coreService = ConnectionDetails()
  ..host = "172.16.111.189"
  ..port = 30100;

  ConnectionDetails mediaConnection = ConnectionDetails()
    ..host = "172.16.111.189"
    ..port = 30101;

}

class ConnectionDetails {
  String host;
  int port;
}