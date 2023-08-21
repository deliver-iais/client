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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: ShakeWidget(
        controller: shakeWidgetController,
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: widget.formField.radioButtonList.hasMultiSelection()
                  ? ListView.builder(
                      itemCount: widget.formField.radioButtonList.values.length,
                      itemBuilder: (_, index) {
                        final data =
                            widget.formField.radioButtonList.values[index];
                        return Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: StreamBuilder<List<String>>(
                            stream: selectedItems.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Checkbox(
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
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                    )
                  : RadioListTile<List<String>>(
                      title: Text(
                        widget.formField.id,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        softWrap: true,
                      ),
                      groupValue: widget.formField.radioButtonList.values,
                      activeColor: Colors.green,
                      onChanged: (s) => widget.selected(""),
                      toggleable: true,
                      value: widget.formField.radioButtonList.values,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
