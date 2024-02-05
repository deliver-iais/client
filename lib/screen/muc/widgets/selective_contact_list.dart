import 'package:collection/collection.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/user.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/contacts/empty_contacts.dart';
import 'package:deliver/screen/contacts/sync_contact.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class SelectiveContactsList extends StatefulWidget {
  final Uid? mucUid;
  final bool useSmsBroadcastList;
  final MucCategories categories;
  final bool openMucInfoDeterminationPage;

  const SelectiveContactsList({
    super.key,
    required this.categories,
    this.mucUid,
    this.useSmsBroadcastList = false,
    this.openMucInfoDeterminationPage = false,
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

  List<User> selectedList = [];

  final _items = <User>[].obs;

  List<User> contacts = [];

  List<Uid> members = [];

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.openMucInfoDeterminationPage) {
      _createMucService.reset();
    }
    editingController = TextEditingController();
    if (widget.mucUid != null) {
      getMembers();
    }
    super.initState();
  }

  Future<void> getMembers() async {
    final res = await _mucRepo.getAllMembers(widget.mucUid!);
    for (final element in res) {
      members.add(element.memberUid);
    }
  }

  void filterSearchResults(String query) {
    if (query.startsWith("@")) {
      query = query.substring(1);
    }
    query = query.replaceAll(RegExp(r"\s\b|\b\s"), "").toLowerCase();
    if (query.isNotEmpty) {
      final dummyListData = <User>[];
      for (final item in contacts) {
        final searchTerm = '${item.firstname}${item.lastname}'
            .replaceAll(RegExp(r"\s\b|\b\s"), "")
            .toLowerCase();
        if (searchTerm.contains(query) ||
            item.firstname
                .replaceAll(RegExp(r"\s\b|\b\s"), "")
                .toLowerCase()
                .contains(query) ||
            (item.lastname.isNotEmpty &&
                item.lastname
                    .replaceAll(RegExp(r"\s\b|\b\s"), "")
                    .toLowerCase()
                    .contains(query))) {
          dummyListData.add(item);
        }
      }
      _items
        ..clear()
        ..addAll(dummyListData);
      searchById(query, dummyListData);
    } else {
      _items
        ..clear()
        ..addAll(contacts);
    }
  }

  Future<void> searchById(String id, List<User> filtered) async {
    final fil = await _contactRepo.searchUser(id);
    if (fil.isNotEmpty) {
      filtered.addAll(
        fil.map((e) => User(firstname: e.name ?? "", id: e.id, uid: e.uid)),
      );
      _items
        ..clear()
        ..addAll(filtered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SyncContact(),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 4.0),
              child: SearchBox(
                onChange: (str) => filterSearchResults(str),
                onCancel: () => filterSearchResults(""),
                controller: editingController,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: widget.useSmsBroadcastList
                    ? _contactRepo.getNotMessengerContacts()
                    : _contactRepo.getAllUserAsContact(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    contacts = widget.useSmsBroadcastList
                        ? snapshot.data!
                            .where(
                              (element) => checkIsPhoneNumber(
                                element.phoneNumber.countryCode,
                                element.phoneNumber.nationalNumber.toInt(),
                              ),
                            )
                            .map((e) => e.toUser())
                            .toList()
                        : snapshot.data!
                            .whereNot((element) => element.uid == null)
                            .where(
                              (element) =>
                                  !_authRepo.isCurrentUser(element.uid!) &&
                                  !(element.phoneNumber.countryCode == 0),
                            )
                            .map((e) => e.toUser())
                            .toList();

                    _items
                      ..clear()
                      ..addAll(contacts);

                    return Obx(() => _items.isNotEmpty
                        ? ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (c, index) =>
                                _getListItemTile(context, index),
                          )
                        : ListView(
                            children: [
                              const EmptyContacts(),
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 32,
                                ),
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
                              ),
                            ],
                          ));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        Obx(
          () => _createMucService.selected.isNotEmpty
              ? Positioned.directional(
                  textDirection: _i18n.defaultTextDirection,
                  bottom: p8,
                  end: p8,
                  child: widget.mucUid != null
                      ? FloatingActionButton.extended(
                          icon: const Icon(Icons.add),
                          heroTag: "select_contacts",
                          label: Text(_i18n["add"]),
                          onPressed: () async {
                            final users = <Uid>[];
                            for (final contact in _createMucService.getSelected(
                              useBroadcastSmsContacts:
                                  widget.useSmsBroadcastList,
                            )) {
                              if (contact.uid != null) {
                                users.add(contact.uid!);
                              }
                            }
                            final usersAddCode = await _mucRepo.addMucMember(
                              widget.mucUid!,
                              users,
                            );
                            if (usersAddCode == StatusCode.ok) {
                              _routingService.openRoom(
                                widget.mucUid!,
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
                              if (context.mounted) {
                                ToastDisplay.showToast(
                                  toastText: message,
                                  toastContext: context,
                                );
                              }
                              // _routingService.pop();
                            }
                          },
                        )
                      : Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: 5,
                          ),
                          child: widget.categories ==
                                      MucCategories.BROADCAST &&
                                  !widget.useSmsBroadcastList &&
                                      _createMucService.selected.length < 2
                              ? const SizedBox()
                              : FloatingActionButton.extended(
                                  heroTag: "select_contacts",
                                  icon: const Icon(
                                    Icons.chevron_right_rounded,
                                  ),
                                  label: widget.useSmsBroadcastList
                                      ? Text(_i18n.get("add"))
                                      : Text(_i18n.get("next")),
                                  onPressed: () {
                                    if (widget.openMucInfoDeterminationPage) {
                                      _routingService
                                          .openMucInfoDeterminationPage(
                                        categories: widget.categories,
                                      );
                                    } else {
                                      _routingService.pop();
                                    }
                                  },
                                ),
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if (!members.contains(_items[index].uid)) {
          if (!_createMucService.isSelected(
            _items[index],
            useBroadcastSmsContacts: widget.useSmsBroadcastList,
          )) {
            if (_createMucService.selected.length + members.length <
                _createMucService.getMaxMemberLength(widget.categories)) {
              _createMucService.addSelected(
                _items[index],
                useBroadcastSmsContacts: widget.useSmsBroadcastList,
              );
              editingController.clear();
            } else {
              ToastDisplay.showToast(
                toastText: _i18n.get("member_max_length_error"),
                toastContext: context,
              );
            }
          } else {
            _createMucService.deleteFromSelected(
              _items[index],
              useBroadcastSmsContacts: widget.useSmsBroadcastList,
            );
            editingController.clear();
          }
        }
      },
      child: Obx(
        () => ContactWidget(
          user: _items[index],
          isSelected: _createMucService.isSelected(
            _items[index],
            useBroadcastSmsContacts: widget.useSmsBroadcastList,
          ),
          currentMember: members.contains(_items[index].uid),
        ),
      ),
    );
  }

  bool checkIsPhoneNumber(int countryCode, int phoneNumber) {
    final regex =
        RegExp(r'^(0|0098|98)9(0[1-5]|[1 3]\d|2[0-2]|9[0-4]|98)\d{7}$');
    return regex.hasMatch("$countryCode$phoneNumber");
  }
}
