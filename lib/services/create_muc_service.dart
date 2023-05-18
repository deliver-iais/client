import 'package:deliver/box/contact.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:rxdart/rxdart.dart';

class CreateMucService {
  final BehaviorSubject<bool> _enableSmsBroadcast =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<int> _membersLength = BehaviorSubject.seeded(0);
  final BehaviorSubject<int> _broadcastSmsContactsLength =
      BehaviorSubject.seeded(0);
  final List<Contact> _contacts = [];
  final List<Contact> _broadcastSmsContacts = [];

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

  List<Contact> getContacts({bool useBroadcastSmsContacts = false}) =>
      useBroadcastSmsContacts ? _broadcastSmsContacts : _contacts;

  void addContact(Contact contact, {bool useBroadcastSmsContacts = false}) {
    getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).add(contact);
    selectedMembersLengthStream(
      useBroadcastSmsContacts: useBroadcastSmsContacts,
    ).add(
      getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).length,
    );
  }

  void addContactList(
    List<Contact> contact, {
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

  void deleteContact(Contact contact, {bool useBroadcastSmsContacts = false}) {
    getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).removeWhere(
      (c) =>
          c.nationalNumber == contact.nationalNumber &&
          c.countryCode == contact.countryCode,
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

  bool isSelected(Contact contact, {bool useBroadcastSmsContacts = false}) =>
      getContacts(useBroadcastSmsContacts: useBroadcastSmsContacts).any(
        (c) =>
            c.nationalNumber == contact.nationalNumber &&
            c.countryCode == contact.countryCode,
      );
}
