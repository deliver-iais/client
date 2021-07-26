import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/fluid_container.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';

import 'package:deliver_flutter/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver_flutter/screen/register/widgets/phone_number.dart' as p;
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class NewContact extends StatefulWidget {
  NewContact({Key key}) : super(key: key);

  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  p.PhoneNumber _phoneNumber;

  I18N _i18n;
  var _routingServices = GetIt.I.get<RoutingService>();

  var _contactRepo = GetIt.I.get<ContactRepo>();

  String _firstName = "";
  String _lastName = "";

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _routingServices.backButtonLeading(),
        title: Text(
          _i18n.get("add_new_contact"),
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                icon: Icon(Icons.check),
                iconSize: 40,
                onPressed: () async {
                  if (_phoneNumber == null) {
                    return;
                  }
                  PhoneNumber phoneNumber = PhoneNumber()
                    ..nationalNumber = Int64.parseInt(_phoneNumber.nationalNumber)
                    ..countryCode = int.parse(_phoneNumber.countryCode);
                  await _contactRepo.addContact(Contact()
                    ..phoneNumber = phoneNumber
                    ..firstName = _firstName
                    ..lastName = _lastName);
                  await showResult();
                  _routingServices.pop();
                }),
          )
        ],
      ),
      body: FluidContainerWidget(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 12),
              child: TextField(
                onChanged: (firstName) {
                  _firstName = firstName;
                },
                style: TextStyle(color: ExtraTheme.of(context).textField),
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: _i18n.get("firstName")),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 12),
              child: TextField(
                onChanged: (lastName) {
                  _lastName = lastName;
                },
                style: TextStyle(color: ExtraTheme.of(context).textField),
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: _i18n.get("lastName")),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            IntlPhoneField(
              validator: (value) => value.length != 10 ||
                      (value.length > 0 && value[0] == '0')
                  ? _i18n.get("invalid_mobile_number")
                  : null,
              style: TextStyle(color: ExtraTheme.of(context).textField),
              onChanged: (ph) {
                _phoneNumber = ph;
              },
              onSubmitted: (p) {
                _phoneNumber = p;
                // checkAndGoNext();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showResult() async {
    var result = await _contactRepo.contactIsExist(
        _phoneNumber.countryCode, _phoneNumber.nationalNumber);
    if (result) {
      Fluttertoast.showToast(
          msg: _i18n.get("contactAdd"));
    } else {
      Fluttertoast.showToast(
          msg: _i18n.get("contact_not_exist"));
    }
  }
}
