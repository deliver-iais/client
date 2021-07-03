import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:rxdart/rxdart.dart';

class CreateMucService {
  BehaviorSubject<int> _membersLength = BehaviorSubject.seeded(0);
  List<Contact> members = [];

  reset() {
    members = [];
    _membersLength.add(members.length);
  }

  addMember(Contact member) {
    members.add(member);
    _membersLength.add(members.length);
  }

  deleteMember(Contact member) {
    members.removeWhere((m) => m.phoneNumber == member.phoneNumber);
    _membersLength.add(members.length);
  }

  Stream<int> selectedLengthStream() => _membersLength.stream;

  isSelected(Contact member) =>
      members.any((m) => m.phoneNumber == member.phoneNumber);
}
