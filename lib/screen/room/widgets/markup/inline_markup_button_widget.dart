import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/widgets/blurred_container.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/markup.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class InlineMarkUpButtonWidget extends StatefulWidget {
  final Message message;
  final bool isSender;

  const InlineMarkUpButtonWidget({
    Key? key,
    required this.message,
    required this.isSender,
  }) : super(key: key);

  @override
  State<InlineMarkUpButtonWidget> createState() =>
      _InlineMarkUpButtonWidgetState();
}

class _InlineMarkUpButtonWidgetState extends State<InlineMarkUpButtonWidget> {
  final _botRepo = GetIt.I.get<BotRepo>();
  final _i18n = GetIt.I.get<I18N>();

  late ThemeData theme;

  BehaviorSubject<List<InlineKeyboardRow>> rows = BehaviorSubject.seeded([]);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    final inlineRows =
        widget.message.markup?.toMessageMarkup().inlineKeyboardMarkup.rows;
    if (inlineRows != null && inlineRows.length > 3) {
      rows.add(_getFilteredRows(inlineRows));
    }
    _searchController.addListener(() {
      rows.add(_getFilteredRows(inlineRows!, term: _searchController.text));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    final colorScheme =
        ExtraTheme.of(context).messageColorScheme(widget.message.from);

    final formTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: colorScheme.primary),
    );

    final inlineRows =
        widget.message.markup?.toMessageMarkup().inlineKeyboardMarkup.rows;

    if (inlineRows!.length > 3) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (isLarge(context)) {
              showDialog(
                context: context,
                builder: (c) {
                  return Theme(
                    data: formTheme,
                    child: AlertDialog(
                      content: _buildContent(),
                      titlePadding: const EdgeInsets.symmetric(vertical: 8),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                      ),
                      actionsPadding: const EdgeInsetsDirectional.only(
                        end: 4,
                        start: 4,
                        bottom: 4,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(c);
                          },
                          child: Text(
                            _i18n.get("close"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) {
                    return Theme(
                      data: formTheme,
                      child: Scaffold(
                        appBar: AppBar(
                          leading: IconButton(
                            icon: Icon(
                              CupertinoIcons.clear,
                              color: formTheme.colorScheme.primary,
                            ),
                            onPressed: () => Navigator.pop(c),
                          ),
                          centerTitle: true,
                        ),
                        body: _buildContent(),
                        floatingActionButton: FloatingActionButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    );
                  },
                  fullscreenDialog: true,
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsetsDirectional.all(p8),
            padding: const EdgeInsetsDirectional.only(
              top: p8,
              end: p8,
              start: p8,
              bottom: p8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: secondaryBorder,
            ),
            child: Row(
              children: [
                Ws.asset(
                  "assets/animations/touch.ws",
                  width: 90,
                  height: 70,
                  frameRate: settings.showWsWithHighFrameRate.value
                      ? FrameRate(30)
                      : FrameRate(10),
                  repeat: settings.showAnimations.value,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(
                        const ['**'],
                        value: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _i18n.get("view_buttons"),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 24,
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: _getRows(inlineRows),
      );
    }
  }

  List<InlineKeyboardRow> _getFilteredRows(
    List<InlineKeyboardRow> rows, {
    String term = "",
  }) {
    final filteredRows = <InlineKeyboardRow>[];
    for (final row in rows) {
      var buttons = <InlineKeyboardButton>[];
      buttons =
          row.buttons.where((element) => element.text.contains(term)).toList();
      filteredRows.add(InlineKeyboardRow(buttons: buttons));
    }

    return filteredRows;
  }

  List<Widget> _getRows(List<InlineKeyboardRow> rows) {
    final widgetColumns = <Widget>[];
    for (final row in rows) {
      final widgetRows = _buildInlineRow(row);
      widgetColumns.add(
        IntrinsicHeight(
          child: Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgetRows,
            ),
          ),
        ),
      );
    }

    return widgetColumns;
  }

  List<Widget> _buildInlineRow(
    InlineKeyboardRow row,
  ) {
    final widgetRows = <Widget>[];
    for (final button in row.buttons) {
      widgetRows.add(
        Container(
          padding: const EdgeInsetsDirectional.only(
            bottom: 2.0,
            end: 2.0,
            start: 2.0,
          ),
          child: BlurContainer(
            skew: 3,
            color: theme.dividerColor.withOpacity(0.2),
            padding: const EdgeInsetsDirectional.all(2.0),
            child: TextButton(
              clipBehavior: Clip.hardEdge,
              onPressed: () {
                if (button.hasCallback() &&
                    button.callback.hasPinCodeSettings()) {
                  ShowInputPin().inputPin(
                    context: context,
                    pinCodeSettings: button.callback.pinCodeSettings,
                    data: button.callback.data,
                    botUid: widget.message.roomUid,
                    packetId: widget.message.packetId,
                  );
                } else {
                  _botRepo.handleInlineMarkUpMessageCallBack(
                    widget.message,
                    button,
                  );
                }
              },
              child: Row(
                children: [
                  Text(
                    button.text,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  if (button.hasCallback() &&
                      button.callback.hasPinCodeSettings())
                    const Icon(
                      CupertinoIcons.lock,
                      size: 20,
                      color: Colors.white,
                    )
                  else if (button.hasCallback())
                    const Icon(
                      Icons.open_in_new,
                      size: 20,
                      color: Colors.white,
                    )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widgetRows;
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(labelText: _i18n.get("search")),
        ),
        StreamBuilder(
          stream: rows,
          builder: (c, r) {
            if (r.hasData && r.data != null) {
              return SizedBox(
                width: isLarge(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width,
                height: isLarge(context)
                    ? MediaQuery.of(context).size.height / 2
                    : MediaQuery.of(context).size.height,
                child: ListView.separated(
                  itemBuilder: (c, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildInlineRow(r.data![index]),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (c, i) => const Divider(),
                  itemCount: r.data!.length,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }
}
