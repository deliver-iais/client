import 'package:deliver/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SelectMucType extends StatefulWidget {
  final Function(ChannelType channelType) onMucTypeChange;
  final ChannelType mucType;
  final Color backgroundColor;

  const SelectMucType({
    Key? key,
    required this.onMucTypeChange,
    required this.mucType,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  SelectMucTypeState createState() => SelectMucTypeState();
}

class SelectMucTypeState extends State<SelectMucType> {
  late ChannelType _groupValue;
  final I18N _i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    _groupValue = widget.mucType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              // Negative padding
              transform: Matrix4.translationValues(
                5.0,
                -10.0,
                0.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
              ),
              child: Text(
                _i18n.get("channel_type"),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            Column(
              children: [
                buildSelectMucTypeRow(
                  title: _i18n.get("public_channel"),
                  description: _i18n.get("public_channel_description"),
                  radioValue: ChannelType.PUBLIC,
                ),
                buildSelectMucTypeRow(
                  title: _i18n.get("private_channel"),
                  description: _i18n.get("private_channel_description"),
                  radioValue: ChannelType.PRIVATE,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildSelectMucTypeRow({
    required ChannelType radioValue,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<ChannelType>(
            activeColor: theme.primaryColor,
            value: radioValue,
            groupValue: _groupValue,
            onChanged: (value) {
              if (value != null) {
                widget.onMucTypeChange(value);
                setState(() {
                  _groupValue = value;
                });
              }
            },
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
