import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// TODO, change accessibility and improve UI
class NewContact extends StatefulWidget {
  NewContact({Key? key}) : super(key: key);

  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  late PhoneNumber _phoneNumber;

  I18N _i18n = GetIt.I.get<I18N>();
  var _routingServices = GetIt.I.get<RoutingService>();
  var _contactRepo = GetIt.I.get<ContactRepo>();

  String _firstName = "";
  String _lastName = "";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _routingServices.backButtonLeading(context),
        title: Text(_i18n.get("add_new_contact")),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20),
              child: !_isLoading
                  ? IconButton(
                      icon: Icon(Icons.check),
                      iconSize: 40,
                      onPressed: () async {
                        if (_phoneNumber == null) {
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        bool addContact =
                            await _contactRepo.addContact(Contact()
                              ..phoneNumber = _phoneNumber
                              ..firstName = _firstName
                              ..lastName = _lastName);
                        if (addContact) {
                          await showResult();
                          _routingServices.pop();
                        }
                      })
                  : Center(child: CircularProgressIndicator()))
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
                style: Theme.of(context).textTheme.bodyText1,
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
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: _i18n.get("lastName")),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            IntlPhoneField(
              controller: TextEditingController(),
              validator: (value) =>
                  value!.length != 10 || (value.length > 0 && value[0] == '0')
                      ? _i18n.get("invalid_mobile_number")
                      : null,
              style: Theme.of(context).textTheme.bodyText1!,
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
        _phoneNumber.countryCode.toString(),
        _phoneNumber.nationalNumber.toString());
    if (result) {
      setState(() {
        _isLoading = false;
      });
      ToastDisplay.showToast(
          toastText: _i18n.get("contactAdd"), tostContext: context);
    } else {
      setState(() {
        _isLoading = false;
      });
      ToastDisplay.showToast(
          toastText: _i18n.get("contact_not_exist"), tostContext: context);
    }
  }
}
