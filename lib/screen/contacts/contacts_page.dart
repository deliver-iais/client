import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _rootingServices = GetIt.I.get<RoutingService>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  bool _searchMode = false;
  String _query = "";

  @override
  void initState() {
    _syncContacts();
    super.initState();
  }

  _syncContacts() {
    _showSyncContactDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: ExtraTheme.of(context).boxBackground,
          titleSpacing: 8,
          title: Text(
            I18N.of(context)!.get("contacts"),
            style: TextStyle(color: ExtraTheme.of(context).textField),
          ),
          leading: _routingService.backButtonLeading(context),
        ),
      ),
      body: FluidContainerWidget(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ExtraTheme.of(context).boxOuterBackground,
          ),
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
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SearchBox(
                          borderRadius: BorderRadius.circular(8),
                          onChange: (str) {
                            if (str.isNotEmpty) {
                              setState(() {
                                _searchMode = true;
                                _query = str;
                              });
                            } else {
                              setState(() {
                                _searchMode = false;
                              });
                            }
                          },
                          onCancel: () {
                            setState(() {
                              _searchMode = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                          child: Scrollbar(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            if (_authRepo.isCurrentUser(contacts[index].uid) ||
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
                                  _rootingServices.openRoom(c.uid,
                                      context: context);
                                },
                                child: ContactWidget(
                                    contact: c,
                                    circleIcon: Icons.qr_code_rounded,
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
                        ),
                      )),
                      const Divider(),
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.add,
                          ),
                          onPressed: () {
                            _routingService.openCreateNewContactPage(context);
                          },
                          label: Text(I18N.of(context)!.get("add_new_contact")),
                        ),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }

  _showSyncContactDialog(BuildContext context) async {
    bool isAlreadyContactAccessTipShowed =
        await _sharedDao.getBoolean(SHARED_DAO_SHOW_CONTACT_DIALOG);
    if (!isAlreadyContactAccessTipShowed && !isDesktop()) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
              actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
              backgroundColor: Colors.white,
              title: Container(
                height: 80,
                color: Colors.blue,
                child: const Icon(
                  Icons.contacts,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              content: SizedBox(
                width: 200,
                child: Text(I18N.of(context)!.get("send_contacts_message"),
                    style: Theme.of(context).textTheme.subtitle1),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      _sharedDao.putBoolean(
                          SHARED_DAO_SHOW_CONTACT_DIALOG, true);
                      Navigator.pop(context);
                      _contactRepo.syncContacts();
                    },
                    child: Text(
                      I18N.of(context)!.get("continue"),
                    ))
              ],
            );
          });
    } else {
      _contactRepo.syncContacts();
    }
  }

  bool searchHasResult(Contact contact) {
    var name = contact.firstName! + contact.lastName!;
    return _searchMode && !name.toLowerCase().contains(_query.toLowerCase());
  }
}
