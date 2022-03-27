import 'package:deliver/box/contact.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/contacts/sync_contact.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _rootingServices = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

  @override
  void initState() {
    _syncContacts();
    super.initState();
  }

  @override
  void dispose() {
    _queryTermDebouncedSubject.close();
    super.dispose();
  }

  _syncContacts() {
    SyncContact().showSyncContactDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UltimateAppBar(
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("contacts")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        showStandardContainer: true,
        child: StreamBuilder<List<Contact>>(
            stream: _contactRepo.watchAll(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Contact>> snapshot) {
              List<Contact> contacts = snapshot.data ?? [];
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SearchBox(
                          // borderRadius: mainBorder,
                          onChange: _queryTermDebouncedSubject.add,
                          onCancel: () => _queryTermDebouncedSubject.add("")),
                    ),
                    Expanded(
                        child: Scrollbar(
                      child: StreamBuilder<String>(
                          stream: _queryTermDebouncedSubject.stream,
                          builder: (context, sna) {
                            return ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                if (_authRepo
                                        .isCurrentUser(contacts[index].uid) ||
                                    searchHasResult(contacts[index])) {
                                  return const SizedBox.shrink();
                                } else {
                                  return const Divider();
                                }
                              },
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext ctx, int index) {
                                var c = contacts[index];
                                if (searchHasResult(c)) {
                                  return const SizedBox.shrink();
                                }
                                if (_authRepo.isCurrentUser(c.uid)) {
                                  return const SizedBox.shrink();
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      _rootingServices.openRoom(c.uid);
                                    },
                                    child: ContactWidget(
                                        contact: c,
                                        circleIcon: CupertinoIcons.qrcode,
                                        onCircleIcon: () => showQrCode(
                                            context,
                                            buildShareUserUrl(
                                                c.countryCode,
                                                c.nationalNumber,
                                                c.firstName!,
                                                c.lastName!))),
                                  );
                                }
                              },
                            );
                          }),
                    )),
                    const Divider(),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(
                          CupertinoIcons.add,
                        ),
                        onPressed: () {
                          _routingService.openNewContact();
                        },
                        label: Text(_i18n.get("add_new_contact")),
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }

  bool searchHasResult(Contact contact) {
    var name = contact.firstName! + contact.lastName!;
    return !name
        .toLowerCase()
        .contains(_queryTermDebouncedSubject.value.toLowerCase());
  }
}
