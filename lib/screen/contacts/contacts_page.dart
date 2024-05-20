import 'dart:async';

import 'package:collection/collection.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/contacts/empty_contacts.dart';
import 'package:deliver/screen/contacts/sync_contact.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/custom_grid_view.dart';
import 'package:deliver/shared/widgets/not_messenger_contact_widget.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> with CustomPopupMenu {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  var _messengerContacts = [];
  var _notMessengerContacts = [];
  final _allContactsBehavior = BehaviorSubject.seeded(<Contact>[]);

  @override
  void initState() {
    super.initState();
    _contactRepo.watchAllMessengerContacts().listen((contacts) {
      _messengerContacts = contacts
          .whereNot((element) => element.uid == null)
          .where(
            (c) =>
                !_authRepo.isCurrentUser(c.uid!) &&
                !(c.phoneNumber.countryCode == 0),
          )
          .sortedBy(
            (element) => buildName(element.firstName, element.lastName),
          )
          .toList(growable: false);

      _allContactsBehavior
          .add(<Contact>[..._messengerContacts, ..._notMessengerContacts]);
    });

    _contactRepo.watchNotMessengerContact().listen((notMessengerContacts) {
      if (notMessengerContacts.isNotEmpty) {
        _notMessengerContacts = notMessengerContacts
            .sortedBy(
              (element) => buildName(element.firstName, element.lastName),
            )
            .toList(growable: false);

        _allContactsBehavior
            .add(<Contact>[..._messengerContacts, ..._notMessengerContacts]);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _syncContacts();
      });
    });
  }

  void _syncContacts() {
    _contactRepo.syncContacts(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          centerTitle: false,
          titleSpacing: 8,
          title: Text(_i18n.get("contacts")),
          leading: _routingService.backButtonLeading(),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ContactSearchDelegate(),
                ).then((c) {
                  if (c != null && c.uid != null) {
                    _routingService.openRoom(c.uid!);
                  }
                });
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Contact>>(
        stream: _allContactsBehavior.stream,
        builder: (context, snapshot) {
          final contacts = snapshot.data ?? [];
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Stack(
              children: [
                Column(
                  children: [
                    // const SyncContact(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 24.0,
                    //     vertical: 8,
                    //   ),
                    // ),
                    if (_messengerContacts.isEmpty) const EmptyContacts(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16.0,
                        ),
                        child: FlexibleFixedHeightGridView(
                          height: 70,
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final c = contacts[index];
                            if (c.uid != null) {
                              return GestureDetector(
                                onTap: () => c.uid != null
                                    ? _routingService.openRoom(c.uid!)
                                    : null,
                                child: ContactWidget(
                                  user: c.toUser(),
                                  // isSelected: true,
                                  circleIcon: CupertinoIcons.qrcode,
                                  onCircleIcon: () => showQrCode(
                                    context,
                                    buildShareUserUrl(
                                      c.phoneNumber.countryCode,
                                      c.phoneNumber.nationalNumber.toInt(),
                                      c.firstName,
                                      c.lastName,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return NotMessengerContactWidget(
                                contact: snapshot.data![index],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(16.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 8.0),
                      child: MouseRegion(
                        hitTestBehavior: HitTestBehavior.translucent,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanDown: storeDragDownPosition,
                          child: FloatingActionButton(
                            heroTag: "add_contact-fab",
                            onPressed: () async {
                              if (isAndroidNative &&
                                  _contactRepo.hasContactPermission) {
                                _routingService.openNewContact();
                              } else {
                                unawaited(
                                  this.showMenu(
                                    context: context,
                                    items: [
                                      PopupMenuItem<String>(
                                        key: const Key("addNewContact"),
                                        value: "addNewContact",
                                        child: Row(
                                          children: [
                                            const Icon(
                                              CupertinoIcons.person_add,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(_i18n.get("add_contact")),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        key: const Key("importContact"),
                                        value: "importContact",
                                        child: Row(
                                          children: [
                                            const Icon(
                                              CupertinoIcons.arrow_up_doc,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _i18n.get("import_contact"),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ).then(
                                    (value) => _selectContactMenu(value ?? ""),
                                  ),
                                );
                              }
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _selectContactMenu(String key) {
    switch (key) {
      case "addNewContact":
        _routingService.openNewContact();
        break;
      case "importContact":
        _contactRepo.importContactsFormVcard();
        break;
    }
  }
}

class ContactSearchDelegate extends SearchDelegate<Contact?> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _contacts = <Contact>[];

  ContactSearchDelegate() {
    _contactRepo.watchAll().listen((contacts) {
      _contacts
        ..clear()
        ..addAll(
          contacts
              .where(
                (c) =>
                    c.uid == null ||
                    (!_authRepo.isCurrentUser(c.uid!) &&
                        !(c.phoneNumber.countryCode == 0)),
              )
              .sortedBy((element) => "${element.firstName}${element.lastName}")
              .sortedBy((element) => "${element.uid != null ? 0 : 1}"),
        );
    });
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredContacts = _contacts
        .where(
          (c) =>
              query.isEmpty ||
              "${c.firstName}${c.lastName}"
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24.0),
      child: FlexibleFixedHeightGridView(
        height: 70,
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final c = filteredContacts[index];
          if (c.uid != null) {
            return GestureDetector(
              onTap: () => close(context, c),
              child: ContactWidget(
                user: c.toUser(),
                circleIcon: CupertinoIcons.qrcode,
                onCircleIcon: () => showQrCode(
                  context,
                  buildShareUserUrl(
                    c.phoneNumber.countryCode,
                    c.phoneNumber.nationalNumber.toInt(),
                    c.firstName,
                    c.lastName,
                  ),
                ),
              ),
            );
          } else {
            return NotMessengerContactWidget(
              contact: c,
            );
          }
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}
