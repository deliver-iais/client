import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:fixnum/fixnum.dart';

String buildPhoneNumber(int countryCode, int nationalNumber) =>
    "+$countryCode-$nationalNumber";

String buildPhoneNumberSimpleText(int countryCode, int nationalNumber) =>
    "+$countryCode$nationalNumber";

PhoneNumber? getPhoneNumber(String pStr) {
  try{
    final phone = pStr
        .replaceAll(RegExp(r"\s+\b|\b\s"), '')
        .replaceAll('+', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '');

    final phoneNumber = PhoneNumber();
    switch (phone.length) {
      case 11:
        phoneNumber.countryCode = 98;
        phoneNumber.nationalNumber = Int64.parseInt(phone.substring(1, 11));
        return phoneNumber;
      case 12:
        phoneNumber.countryCode = int.parse(phone.substring(0, 2));
        phoneNumber.nationalNumber = Int64.parseInt(phone.substring(2, 12));
        return phoneNumber;
      case 10:
        phoneNumber.countryCode = 98;
        phoneNumber.nationalNumber = Int64.parseInt(phone.substring(0, 10));
        return phoneNumber;
    }
  }catch(_){

  }

  return null;
}
