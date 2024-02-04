import 'package:deliver/models/user.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class CreateMucService {
  final BehaviorSubject<bool> _enableSmsBroadcast =
      BehaviorSubject.seeded(false);

  final selected = <User>[].obs;
  final List<User> _broadcastSmsContacts = [];

  void reset() {
    selected.clear();
    _resetBroadcastSmsListValues();
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
  }

  BehaviorSubject<bool> isSmsBroadcastEnableStream() => _enableSmsBroadcast;

  List<User> getSelected({bool useBroadcastSmsContacts = false}) =>
      useBroadcastSmsContacts ? _broadcastSmsContacts : selected;

  void addSelected(User selected, {bool useBroadcastSmsContacts = false}) {
    getSelected(useBroadcastSmsContacts: useBroadcastSmsContacts).add(selected);
  }

  void addContactList(
    List<User> contact, {
    bool useBroadcastSmsContacts = false,
  }) {
    getSelected(useBroadcastSmsContacts: useBroadcastSmsContacts).clear();
    getSelected(useBroadcastSmsContacts: useBroadcastSmsContacts)
        .addAll(contact);
  }

  void deleteFromSelected(User contact,
      {bool useBroadcastSmsContacts = false}) {
    selected.remove(contact);
  }

  int getMaxMemberLength(MucCategories mucCategories) {
    if (mucCategories == MucCategories.BROADCAST) {
      return BROADCAST_CHANNEL_MAX_MEMBER_COUNT;
    }
    return MUC_MAX_MEMBER_COUNT;
  }

  bool isSelected(User contact, {bool useBroadcastSmsContacts = false}) =>
      selected.contains(contact);
}
