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
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  ContactsPage({Key key}) : super(key: key) {
    _syncContacts();
  }

  _syncContacts() async {
    bool isAlreadyContactAccessTipShowed =
        await _sharedDao.getBoolean(SHARED_DAO_SHOW_CONTACT_DIALOG);
    if (!isAlreadyContactAccessTipShowed || isDesktop()) {
      _contactRepo.syncContacts();
    }
  }

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
    widget._syncContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _showSyncContactDialog(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: FluidContainerWidget(
          child: AppBar(
            backgroundColor: ExtraTheme.of(context).boxBackground,
            titleSpacing: 8,
            title: Text(
              I18N.of(context).get("contacts"),
              style: TextStyle(color: ExtraTheme.of(context).textField),
            ),
            leading: _routingService.backButtonLeading(),
          ),
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
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Column(
                    children: [
                      SearchBox(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
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
                      Expanded(
                          child: Scrollbar(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            if (_authRepo.isCurrentUser(contacts[index].uid) ||
                                searchHasResult(contacts[index]))
                              return SizedBox.shrink();
                            else
                              return Divider();
                          },
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            var c = contacts[index];
                            if (searchHasResult(c)) return SizedBox.shrink();
                            return _authRepo.isCurrentUser(c.uid)
                                ? SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () {
                                      if (c.uid != null) {
                                        _rootingServices.openRoom(c.uid);
                                      } else {
                                        // todo invite contact
                                      }
                                    },
                                    child: ContactWidget(
                                        contact: c,
                                        circleIcon: Icons.qr_code_rounded,
                                        onCircleIcon: () => showQrCode(
                                            context,
                                            buildShareUserUrl(
                                                c.countryCode,
                                                c.nationalNumber,
                                                c.firstName,
                                                c.lastName))),
                                  );
                          },
                        ),
                      )),
                      Divider(),
                      Container(
                        height: 40,
                        width: double.infinity,
                        child: TextButton.icon(
                          icon: Icon(
                            Icons.add,
                          ),
                          onPressed: () {
                            _routingService.openCreateNewContactPage();
                          },
                          label: Text(I18N.of(context).get("add_new_contact")),
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
    if (!isAlreadyContactAccessTipShowed == null && !isDesktop()) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
              actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
              backgroundColor: Colors.white,
              title: Container(
                height: 80,
                color: Colors.blue,
                child: Icon(
                  Icons.contacts,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              content: Container(
                width: 200,
                child: Text(I18N.of(context).get("send_contacts_message"),
                    style: Theme.of(context).textTheme.subtitle1),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      _sharedDao.putBoolean(
                          SHARED_DAO_SHOW_CONTACT_DIALOG, true);
                      Navigator.pop(context);
                      widget._syncContacts();
                    },
                    child: Text(
                      I18N.of(context).get("continue"),
                    ))
              ],
            );
          });
    }
  }

  bool searchHasResult(Contact contact) {
    var name = contact.firstName + contact.lastName;
    print(name);
    return _searchMode && !name.toLowerCase().contains(_query.toLowerCase());
  }
}
