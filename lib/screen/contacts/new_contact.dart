import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NewContact extends StatefulWidget {
  const NewContact({super.key});

  @override
  NewContactState createState() => NewContactState();
}

class NewContactState extends State<NewContact> {
  PhoneNumber? _phoneNumber;

  final _i18n = GetIt.I.get<I18N>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();

  String _firstName = "";
  String _lastName = "";
  int _maxLength = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  Directionality(
                    textDirection: _i18n.defaultTextDirection,
                    child: AutoDirectionTextField(
                      onChanged: (firstName) {
                        _firstName = firstName;
                      },
                      controller: TextEditingController(),
                      style: theme.textTheme.bodyText1,
                      decoration:
                          InputDecoration(labelText: _i18n.get("firstName")),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: _i18n.defaultTextDirection,
                    child: AutoDirectionTextField(
                      onChanged: (lastName) {
                        _lastName = lastName;
                      },
                      controller: TextEditingController(),
                      style: theme.textTheme.bodyText1,
                      decoration:
                          InputDecoration(labelText: _i18n.get("lastName")),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: _i18n.defaultTextDirection,
                    child: IntlPhoneField(
                      controller: TextEditingController(),
                      maxLength: _maxLength,
                      onMaxLengthChanged: (_) {},
                      validator: (value) =>
                          (value!.length == 11 && value[0] != '0') ||
                                  (value.length < 10 &&
                                      (value.isNotEmpty && value[0] == '0'))
                              ? _i18n.get("invalid_mobile_number")
                              : null,
                      style: theme.textTheme.bodyText1,
                      onChanged: (ph) {
                        _phoneNumber = ph;
                      },
                      onSubmitted: (p) {
                        _phoneNumber = p;
                        // checkAndGoNext();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(_i18n.get("save")),
                      onPressed: () async {
                        if (_phoneNumber != null) {
                          final contactAdded =
                              await _contactRepo.sendNewContact(
                            Contact()
                              ..phoneNumber = _phoneNumber!
                              ..firstName = _firstName
                              ..lastName = _lastName,
                          );
                          showResult(contactAdded: contactAdded);
                          if (contactAdded) _routingServices.pop();
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

  void showResult({bool contactAdded = false}) {
    if (contactAdded) {
      ToastDisplay.showToast(
        toastText: _i18n.get("contactAdd"),
        toastContext: context,
      );
    } else {
      ToastDisplay.showToast(
        toastText: _i18n.get("contact_not_exist"),
        toastContext: context,
      );
    }
  }
}
