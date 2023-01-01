import 'package:collection/collection.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/contacts/empty_contacts.dart';
import 'package:deliver/screen/contacts/sync_contact.dart';
import 'package:deliver/screen/muc/widgets/selective_contact.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class SelectiveContactsList extends StatefulWidget {
  final Uid? mucUid;

  final bool isChannel;

  const SelectiveContactsList({
    super.key,
    required this.isChannel,
    this.mucUid,
  });

  @override
  SelectiveContactsListState createState() => SelectiveContactsListState();
}

class SelectiveContactsListState extends State<SelectiveContactsList> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _createMucService = GetIt.I.get<CreateMucService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  late TextEditingController editingController;

  List<Contact> selectedList = [];

  List<Contact>? items;

  List<Contact> contacts = [];

  List<String> members = [];

  @override
  void initState() {
    editingController = TextEditingController();
    if (widget.mucUid != null) getMembers();
    _createMucService.reset();
    super.initState();
  }

  Future<void> getMembers() async {
    final res = await _mucRepo.getAllMembers(widget.mucUid!.asString());
    for (final element in res) {
      members.add(element!.memberUid);
    }
  }

  void filterSearchResults(String query) {
    query = query.replaceAll(RegExp(r"\s\b|\b\s"), "").toLowerCase();
    if (query.isNotEmpty) {
      final dummyListData = <Contact>[];
      for (final item in contacts) {
        final searchTerm = '${item.firstName}${item.lastName}'
            .replaceAll(RegExp(r"\s\b|\b\s"), "")
            .toLowerCase();
        if (searchTerm.contains(query) ||
            item.firstName!
                .replaceAll(RegExp(r"\s\b|\b\s"), "")
                .toLowerCase()
                .contains(query) ||
            (item.lastName != null &&
                item.lastName!
                    .replaceAll(RegExp(r"\s\b|\b\s"), "")
                    .toLowerCase()
                    .contains(query))) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items!.clear();
        items!.addAll(dummyListData);
      });
    } else {
      setState(() {
        items!.clear();
        items!.addAll(contacts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          children: [
            const SyncContact(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SearchBox(
                onChange: (str) => filterSearchResults(str),
                onCancel: () => filterSearchResults(""),
                controller: editingController,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: _contactRepo.getAllUserAsContact(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    contacts = snapshot.data!
                        .whereNot((element) => element.uid == null)
                        .where(
                          (element) =>
                              !_authRepo.isCurrentUser(element.uid!) &&
                              !element.isUsersContact(),
                        )
                        .toList();

                    items ??= contacts;

                    if (items!.isNotEmpty) {
                      return StreamBuilder<int>(
                        stream: _createMucService.selectedLengthStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          return ListView.builder(
                            itemCount: items!.length,
                            itemBuilder: _getListItemTile,
                          );
                        },
                      );
                    } else {
                      return ListView(
                        children: [
                          const EmptyContacts(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: TextButton(
                              onPressed: _routingService.openContacts,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_i18n.get("contacts")),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
        StreamBuilder<int>(
          stream: _createMucService.selectedLengthStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            if (snapshot.data! > 0) {
              return Positioned(
                bottom: 5,
                right: 15,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor,
                  ),
                  child: widget.mucUid != null
                      ? IconButton(
                          icon: const Icon(Icons.check),
                          padding: const EdgeInsets.all(0),
                          onPressed: () async {
                            final users = <Uid>[];
                            for (final contact in _createMucService.contacts) {
                              if (contact.uid != null) {
                                users.add(contact.uid!.asUid());
                              }
                            }
                            final usersAddCode = await _mucRepo.sendMembers(
                              widget.mucUid!,
                              users,
                            );
                            if (usersAddCode == StatusCode.ok) {
                              _routingService.openRoom(
                                widget.mucUid!.asString(),
                                popAllBeforePush: true,
                              );
                              // _createMucService.reset();

                            } else {
                              var message = _i18n.get("error_occurred");
                              if (usersAddCode == StatusCode.unavailable) {
                                message = _i18n.get("notwork_is_unavailable");
                              } else if (usersAddCode ==
                                  StatusCode.permissionDenied) {
                                message = _i18n.get("permission_denied");
                              }

                              ToastDisplay.showToast(
                                toastText: message,
                                toastContext: context,
                              );
                              // _routingService.pop();
                            }
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            _routingService.openGroupInfoDeterminationPage(
                              isChannel: widget.isChannel,
                            );
                          },
                        ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        )
      ],
    );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if (!members.contains(items![index].uid)) {
          if (!_createMucService.isSelected(items![index])) {
            _createMucService.addContact(items![index]);
            editingController.clear();
          } else {
            _createMucService.deleteContact(items![index]);
            editingController.clear();
          }
        }
      },
      child: SelectiveContact(
        contact: items![index],
        isSelected: _createMucService.isSelected(items![index]),
        currentMember: members.contains(items![index].uid),
      ),
    );
  }
}
