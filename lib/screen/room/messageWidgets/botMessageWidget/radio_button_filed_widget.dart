import 'dart:math';

import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RadioButtonFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final void Function(String?) selected;
  final void Function(GlobalKey<FormState>) setFormKey;

  const RadioButtonFieldWidget({
    super.key,
    required this.formField,
    required this.selected,
    required this.setFormKey,
  });

  @override
  RadioButtonFieldWidgetState createState() => RadioButtonFieldWidgetState();
}

class RadioButtonFieldWidgetState extends State<RadioButtonFieldWidget> {
  final _formKey = GlobalKey<FormState>();
  final ShakeWidgetController shakeWidgetController = ShakeWidgetController();
  BehaviorSubject<List<String>> selectedItems = BehaviorSubject.seeded([]);
  BehaviorSubject<String> selectedItem = BehaviorSubject.seeded("");

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: ShakeWidget(
        controller: shakeWidgetController,
        child: Form(
          key: _formKey,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.formField.id,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: widget.formField.radioButtonList.hasMultiSelection()
                ? SizedBox(
                    height: min(
                      widget.formField.radioButtonList.values.length * 55,
                      200,
                    ),
                    width: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.formField.radioButtonList.values.length,
                      itemBuilder: (_, index) {
                        final data =
                            widget.formField.radioButtonList.values[index];
                        return StreamBuilder<List<String>>(
                          stream: selectedItems.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(data),
                                  Checkbox(
                                    value: snapshot.data!.contains(data),
                                    onChanged: (_) {
                                      if (snapshot.data!.contains(data)) {
                                        selectedItems.add(
                                          selectedItems.value
                                              .where(
                                                (
                                                  element,
                                                ) =>
                                                    element != data,
                                              )
                                              .toList(),
                                        );
                                        widget.selected(
                                          selectedItems.value.join(","),
                                        );
                                      } else {
                                        selectedItems.add(
                                          selectedItems.value..add(data),
                                        );
                                        widget.selected(
                                          selectedItems.value.join(","),
                                        ); // select
                                      }
                                    },
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  )
                : StreamBuilder<String>(
                    stream: selectedItem.stream,
                    builder: (context, selected) {
                      return SizedBox(
                        width: 200,
                        height: min(
                          widget.formField.radioButtonList.values.length * 55,
                          200,
                        ),
                        child: ListView(
                          children: <Widget>[
                            for (String value
                                in widget.formField.radioButtonList.values)
                              RadioListTile(
                                value: value,
                                groupValue: selected.data,
                                title: Text(value),
                                onChanged: (val) {
                                  selectedItem.add(val!);
                                  widget.selected(val);
                                },
                                activeColor: Colors.green,
                              )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
