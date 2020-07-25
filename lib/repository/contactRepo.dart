
import 'package:deliver_flutter/generated-protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_flutter/generated-protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/contactServices.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class ContactRepo {
  static var servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  static ClientChannel clientChannel = ClientChannel(
      servicesDiscoveryRepo.ContactServies.host,
      port: servicesDiscoveryRepo.ContactServies.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  sendContacts(List<Contact> list) async {
    var contactServices = ContactServiceClient(clientChannel);
    var sendContacts = SaveContactsReq();
    list.forEach((element) {
      sendContacts.contactList.add(element);
    });
   contactServices.saveContacts(sendContacts);
  }
}
