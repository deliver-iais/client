import 'package:collection/collection.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/contacts/empty_contacts.dart';
import 'package:deliver/screen/contacts/sync_contact.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/custom_grid_view.dart';
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

class ContactsPageState extends State<ContactsPage> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _contactsBehavior = BehaviorSubject.seeded(<Contact>[]);

  @override
  void initState() {
    super.initState();
    _syncContacts();
    _contactRepo.watchAll().listen((contacts) {
      _contactsBehavior.add(
        contacts
            .where((c) => !_authRepo.isCurrentUser(c.uid))
            .sortedBy((element) => "${element.firstName}${element.lastName}")
            .toList(growable: false),
      );
    });
  }

  void _syncContacts() {
    SyncContact.showSyncContactDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          centerTitle: false,
          titleSpacing: 8,
          title: Row(
            children: [
              Text(_i18n.get("contacts"), style: textTheme.titleMedium),
              SyncContact.syncingStatusWidget(context)
            ],
          ),
          leading: _routingService.backButtonLeading(),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ContactSearchDelegate(),
                ).then((c) {
                  if (c != null) {
                    _routingService.openRoom(c.uid);
                  }
                });
              },
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: StreamBuilder<List<Contact>>(
        stream: _contactsBehavior,
        builder: (context, snapshot) {
          final contacts = snapshot.data ?? [];

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Stack(
              children: [
                if (contacts.isNotEmpty)
                  ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${contacts.length} ${_i18n.get("contacts")}",
                              style: textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FlexibleFixedHeightGridView(
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final c = contacts[index];

                            return GestureDetector(
                              onTap: () => _routingService.openRoom(c.uid),
                              child: ContactWidget(
                                contact: c,
                                // isSelected: true,
                                circleIcon: CupertinoIcons.qrcode,
                                onCircleIcon: () => showQrCode(
                                  context,
                                  buildShareUserUrl(
                                    c.countryCode,
                                    c.nationalNumber,
                                    c.firstName!,
                                    c.lastName!,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                else
                  const EmptyContacts(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      child: const Icon(CupertinoIcons.add),
                      onPressed: () {
                        _routingService.openNewContact();
                      },
                      // label: Text(_i18n.get("add_new_contact")),
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
              .sortedBy((element) => "${element.firstName}${element.lastName}")
              .where((c) => !_authRepo.isCurrentUser(c.uid)),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: FlexibleFixedHeightGridView(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final c = filteredContacts[index];

          return GestureDetector(
            onTap: () => close(context, c),
            child: ContactWidget(
              contact: c,
              onCircleIcon: () => showQrCode(
                context,
                buildShareUserUrl(
                  c.countryCode,
                  c.nationalNumber,
                  c.firstName!,
                  c.lastName!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}
