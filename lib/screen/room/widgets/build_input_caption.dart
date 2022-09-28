import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class BuildInputCaption extends StatelessWidget {
  final BehaviorSubject<bool> insertCaption;
  final TextEditingController captionEditingController;
  final void Function() send;
  final int count;
  final bool needDarkBackground;

  const BuildInputCaption({
    Key? key,
    this.needDarkBackground = false,
    required this.insertCaption,
    required this.captionEditingController,
    required this.send,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = GetIt.I.get<I18N>();
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: needDarkBackground
                ? Colors.black.withAlpha(120)
                : theme.colorScheme.background,
            child: AutoDirectionTextField(
              decoration: InputDecoration(
                hintText: i18n.get("add_caption"),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: needDarkBackground ? Colors.white70 : null,
                ),
                suffixIcon: StreamBuilder<bool>(
                  stream: insertCaption,
                  builder: (c, s) {
                    if (s.hasData && s.data!) {
                      return IconButton(
                        onPressed: () => send(),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 35,
                        ),
                        color: theme.primaryColor,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
              style: TextStyle(
                fontSize: 17,
                color: needDarkBackground ? Colors.white : null,
              ),
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 15,
              controller: captionEditingController,
            ),
          ),
        ),
        Positioned(
          right: 15,
          bottom: 20,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: StreamBuilder<bool>(
                  stream: insertCaption,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        !snapshot.data!) {
                      return ClipOval(
                        child: Material(
                          color: theme.primaryColor, // button color
                          child: InkWell(
                            splashColor: theme.primaryColor, // inkwell color
                            child: const SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(
                                Icons.send,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () => send(),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 34.0,
                  right: 0.0,
                  left: 35,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background, // border color
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2), // border width
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor, // inner circle color
                        ),
                        child: Center(
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ), // inner content
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
