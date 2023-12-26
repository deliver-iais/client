import 'package:deliver/models/user.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

class CreateMucService {
  final BehaviorSubject<bool> _enableSmsBroadcast =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<int> _membersLength = BehaviorSubject.seeded(0);
  final BehaviorSubject<int> _broadcastSmsContactsLength =
      BehaviorSubject.seeded(0);
  final List<User> _contacts = [];
  final List<User> _broadcastSmsContacts = [];

  void reset() {
    _contacts.clear();
    _resetBroadcastSmsListValues();
    _membersLength.add(0);
    _enableSmsBroadcast.add(false);
  }

  void setSmsBroadcastStatus({bool value = false}) {
    _enableSmsBroadcast.add(value);
    if (!value) {
      _resetBroadcastSmsListValues();
    }
  }

  void _resetBroadcastSmsListValues() {
    _broadcastSmsContacts.clear();
    _broadcastSmsContactsLength.add(0);
  }

  BehaviorSubject<bool> isSmsBroadcastEnableStream() => _enableSmsBroadcast;

  List<User> getContacts({bool useBroadcastSmsContacts = false}) =>
      useBroadcastSmsContacts ? _broadcastSmsContacts : _contacts;

  void addContact(User contact, {bool useBroadcastSmsContacts = false}) {
    getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).add(contact);
    selectedMembersLengthStream(
      useBroadcastSmsContacts: useBroadcastSmsContacts,
    ).add(
      getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).length,
    );
  }

  void addContactList(
    List<User> contact, {
    bool useBroadcastSmsContacts = false,
  }) {
    getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).clear();
    getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts)
        .addAll(contact);
    selectedMembersLengthStream(
      useBroadcastSmsContacts: useBroadcastSmsContacts,
    ).add(
      getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).length,
    );
  }

  void deleteContact(User contact, {bool useBroadcastSmsContacts = false}) {
    getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).removeWhere(
      (c) =>
          c.phoneNumber!.nationalNumber ==
              contact.phoneNumber!.nationalNumber &&
          c.phoneNumber!.countryCode == contact.phoneNumber!.countryCode,
    );
    selectedMembersLengthStream(
      useBroadcastSmsContacts: useBroadcastSmsContacts,
    ).add(
      getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).length,
    );
  }

  int getMaxMemberLength(MucCategories mucCategories) {
    if (mucCategories == MucCategories.BROADCAST) {
      return BROADCAST_CHANNEL_MAX_MEMBER_COUNT;
    }
    return MUC_MAX_MEMBER_COUNT;
  }

  BehaviorSubject<int> selectedMembersLengthStream({
    bool useBroadcastSmsContacts = false,
  }) =>
      useBroadcastSmsContacts ? _broadcastSmsContactsLength : _membersLength;

  bool isSelected(User contact, {bool useBroadcastSmsContacts = false}) =>
      getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).any((c) =>
          c.phoneNumber != null
              ? c.phoneNumber!.nationalNumber ==
                      contact.phoneNumber!.nationalNumber &&
                  c.phoneNumber!.countryCode == contact.phoneNumber!.countryCode
              : c.uid!.isSameEntity(contact.uid!.asString()),);
}
