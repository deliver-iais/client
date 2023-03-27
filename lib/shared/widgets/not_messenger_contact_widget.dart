import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotMessengerContactWidget extends StatelessWidget {
  final Contact contact;

  const NotMessengerContactWidget({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: AnimationSettings.slow,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: messageBorder,
        border: Border.all(color: theme.colorScheme.outline),
        color: theme.colorScheme.surface,
      ),
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox(
            width: 15,
          ),
          const Icon(
            CupertinoIcons.person,
            size: 30,
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              buildName(contact.firstName, contact.lastName),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              splashRadius: 40,
              iconSize: 24,
              onPressed: () async {
                final uri = Uri.parse(
                  'sms:${contact.countryCode}${contact.nationalNumber}?body=$INVITE_MESSAGE',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $uri';
                }
              },
              icon: Icon(
                CupertinoIcons.chat_bubble_text,
                color: theme.colorScheme.primary,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
