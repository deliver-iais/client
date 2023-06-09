import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AttachContact extends StatefulWidget {
  final Function() pop;
  final Uid roomUid;
  final ScrollController scrollController;

  const AttachContact({
    super.key,
    required this.pop,
    required this.roomUid,
    required this.scrollController,
  });

  @override
  State<AttachContact> createState() => _AttachContactState();
}

class _AttachContactState extends State<AttachContact> {
  final _contactDao = GetIt.I.get<ContactDao>();
  final _i18n = GetIt.I.get<I18N>();
  final _allContactsBehavior = BehaviorSubject.seeded(<Contact>[]);
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final TextEditingController editingController = TextEditingController();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _contactRepo.syncContacts(context);
    _contactDao.watchAllMessengerContacts().listen((event) {
      contacts = event;
      _allContactsBehavior.add(contacts);
    });
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
            item.firstName
                .replaceAll(RegExp(r"\s\b|\b\s"), "")
                .toLowerCase()
                .contains(query) ||
            (item.lastName.isNotEmpty &&
                item.lastName
                    .replaceAll(RegExp(r"\s\b|\b\s"), "")
                    .toLowerCase()
                    .contains(query))) {
          dummyListData.add(item);
        }
      }
      _allContactsBehavior.add(dummyListData);
    } else {
      _allContactsBehavior.add(contacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 12.0, bottom: 4),
          child: SearchBox(
            onChange: (str) => filterSearchResults(str),
            onCancel: () => filterSearchResults(""),
            controller: editingController,
          ),
        ),
        StreamBuilder<List<Contact>>(
          stream: _allContactsBehavior,
          builder: (c, snapShot) {
            if (snapShot.hasData &&
                snapShot.data != null &&
                snapShot.data!.isNotEmpty) {
              return Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: snapShot.data!.length,
                  itemBuilder: (c, index) =>
                      buildIndex(snapShot.data![index], context),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildIndex(Contact contact, BuildContext context) {
    return GestureDetector(
      child: ContactWidget(
        contact: contact,
      ),
      onTap: () {
        showFloatingModalBottomSheet(
          context: context,
          builder: (c) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatarWidget(
                    contact.uid!,
                    37,
                    // borderRadius: secondaryBorder,
                    showSavedMessageLogoIfNeeded: true,
                  ),
                ),
                Text(
                  contact.phoneNumber.countryCode.toString() +
                      contact.phoneNumber.nationalNumber.toString(),
                ),
                Text(
                  buildName(contact.firstName, contact.lastName),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context);

                    _messageRepo.sendShareUidMessage(
                      widget.roomUid,
                      message_pb.ShareUid()
                        ..uid = contact.uid!
                        ..name = buildName(contact.firstName, contact.lastName)
                        ..phoneNumber = "${contact.phoneNumber.countryCode}"
                            "${contact.phoneNumber.nationalNumber}",
                    );
                  },
                  child: Text(
                    _i18n.get("share_contact"),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
