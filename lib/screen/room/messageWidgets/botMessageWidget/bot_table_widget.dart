import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/horizontal_list_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/widgets/blurred_container.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as proto;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotTableWidget extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  const BotTableWidget({
    super.key,
    required this.message,
    required this.colorScheme,
    required this.maxWidth,
  });

  @override
  State<BotTableWidget> createState() => _BotTableWidgetState();
}

class _BotTableWidgetState extends State<BotTableWidget> {
  final _controller = ScrollController();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final rows = <TableRow>[];
    final columnWidths = <int, TableColumnWidth>{};
    initRows(columnWidths, rows);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(p8),
          child: buildTableWidget(
            context: context,
            controller: _controller,
            maxWidth: widget.maxWidth,
            rows: rows,
            columnWidths: columnWidths,
          ),
        ),
        Positioned(
          left: 3,
          top: 3,
          child: IconButton(
            style: IconButton.styleFrom(
              maximumSize: const Size.square(24),
              backgroundColor: widget.colorScheme.primary,
              foregroundColor: widget.colorScheme.onPrimary,
              minimumSize: const Size.square(22),
            ),
            tooltip: _i18n.get("full_screen"),
            icon: const Icon(
              Icons.fullscreen,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            // iconSize: 20,
            onPressed: () => showInDialog(
              buildTableWidget(
                context: context,
                controller: ScrollController(),
                maxWidth: MediaQuery.of(context).size.width * 2 / 3,
                rows: rows,
                columnWidths: columnWidths,
              ),
              context,
            ),
          ),
        ),
      ],
    );
  }

  void showInDialog(Widget table, BuildContext context) {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          scrollable: true,
          contentPadding: const EdgeInsets.all(p12),
          actionsPadding: const EdgeInsets.all(p12),
          titlePadding: EdgeInsets.zero,
          content: ClipRRect(borderRadius: tertiaryBorder, child: table),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(c),
              child: Text(_i18n.get("close")),
            )
          ],
        );
      },
    );
  }

  Widget buildTableWidget({
    required BuildContext context,
    required ScrollController controller,
    required double maxWidth,
    required List<TableRow> rows,
    required Map<int, TableColumnWidth> columnWidths,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: HorizontalListWidget(
        maxWidth: maxWidth,
        primaryColor: widget.colorScheme.primary,
        controller: controller,
        fadeLayoutColor:
            ExtraTheme.of(context).messageBackgroundColor(widget.message.from),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(
                color: widget.colorScheme.primary,
                borderRadius: tertiaryBorder,
              ),
              columnWidths: columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: rows,
            ),
          ),
        ),
      ),
    );
  }

  bool isRegularTable(proto.Table table) {
    final firstColumCount = table.rows.first.columns.length;
    for (final row in table.rows) {
      if (row.columns.length != firstColumCount) {
        return false;
      }
    }
    return true;
  }

  void initRows(
    Map<int, TableColumnWidth> columnWidths,
    List<TableRow> resultRows,
  ) {
    var columns = <Widget>[];
    final table = widget.message.json.toTable();
    final isRegular = isRegularTable(table);
    for (final row in table.rows) {
      columns = [];
      for (var i = 0; i < row.columns.length; ++i) {
        columnWidths[i] = table.columnWidths.isNotEmpty
            ? FixedColumnWidth(
                table.columnWidths[i],
              )
            : const IntrinsicColumnWidth(flex: 0.5);
        columns.add(
          Container(
            margin: const EdgeInsetsDirectional.all(8),
            child: Center(
              child: Text(
                row.columns[i],
                textDirection: row.columns[i].isPersian()
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TextStyle(
                  fontWeight: row.bold ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      }
      if (isRegular) {
        resultRows.add(
          TableRow(
            children: columns,
            decoration: BoxDecoration(
              color: row.highlight
                  ? widget.colorScheme.primary.withAlpha(150)
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        );
      } else {
        resultRows.add(
          TableRow(
            decoration: BoxDecoration(
              color: row.highlight
                  ? widget.colorScheme.primary.withAlpha(150)
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            children: [
              Table(
                border: TableBorder.all(
                  color: widget.colorScheme.primary,
                  // borderRadius: const BorderRadius.all(),
                ),
                columnWidths: columnWidths,
                children: [TableRow(children: columns)],
              )
            ],
          ),
        );
      }
    }
  }
}
