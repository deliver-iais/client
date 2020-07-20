import 'package:fimber/fimber_base.dart';
import 'package:fixnum/fixnum.dart';

import 'package:deliver_flutter/generated/pub/v1/models/phone.pb.dart';
import 'package:deliver_flutter/generated/pub/v1/profile.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grpc/grpc.dart';

class ProfileRepo {
  static ClientChannel clientChannel = ClientChannel('172.16.111.171',
      port: 30000,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var AuthServiceStub = AuthServiceClient(clientChannel);

  getVerificationCode(int countryCode, String nationalNumber) {
    PhoneNumber phoneNumber = PhoneNumber()
      ..countryCode = countryCode
      ..nationalNumber = Int64.parseInt(nationalNumber);
    var verificationCode =
        AuthServiceStub.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phoneNumber
          ..type = VerificationType.SMS);

    verificationCode
        .then((res) => {
              Fluttertoast.showToast(
                  msg: " رمز ورود برای شما ارسال شد.",
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0)
            })
        .catchError((e) => {
              Fluttertoast.showToast(
                  msg: " خطایی رخ داده است.",
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0)
            });
  }
}
