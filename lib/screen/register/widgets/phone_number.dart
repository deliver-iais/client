import 'package:flutter/foundation.dart';

class PhoneNumber {
  String countryISOCode;
  String countryCode;
  String nationalNumber;

  PhoneNumber({
    @required this.countryISOCode,
    @required this.countryCode,
    @required this.nationalNumber,
  });

  String get completeNumber {
    return countryCode + nationalNumber;
  }
}
