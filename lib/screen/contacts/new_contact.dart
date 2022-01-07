import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// TODO, change accessibility and improve UI
class NewContact extends StatefulWidget {
  const NewContact({Key? key}) : super(key: key);

  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  PhoneNumber? _phoneNumber;

  final _i18n = GetIt.I.get<I18N>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  String _firstName = "";
  String _lastName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _routingServices.backButtonLeading(),
        title: Text(_i18n.get("add_new_contact")),
      ),
      body: FluidContainerWidget(
        child: Section(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (firstName) {
                      _firstName = firstName;
                    },
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration:
                        InputDecoration(labelText: _i18n.get("firstName")),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (lastName) {
                      _lastName = lastName;
                    },
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration:
                        InputDecoration(labelText: _i18n.get("lastName")),
                  ),
                  const SizedBox(height: 10),
                  IntlPhoneField(
                    controller: TextEditingController(),
                    validator: (value) => value!.length != 10 ||
                            (value.isNotEmpty && value[0] == '0')
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
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(_i18n.get("save")),
                      onPressed: () async {
                        if (_phoneNumber != null) {
                          bool addContact =
                              await _contactRepo.addContact(Contact()
                                ..phoneNumber = _phoneNumber!
                                ..firstName = _firstName
                                ..lastName = _lastName);
                          if (addContact) {
                            await showResult(_phoneNumber!);
                            _routingServices.pop();
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showResult(PhoneNumber pn) async {
    var result = await _contactRepo.contactIsExist(
        pn.countryCode.toString(), pn.nationalNumber.toString());
    if (result) {
      ToastDisplay.showToast(
          toastText: _i18n.get("contactAdd"), tostContext: context);
    } else {
      ToastDisplay.showToast(
          toastText: _i18n.get("contact_not_exist"), tostContext: context);
    }
  }
}
