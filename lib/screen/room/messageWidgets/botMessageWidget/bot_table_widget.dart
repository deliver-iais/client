import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/widgets/horizontal_list_widget.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return createTable(context);
  }

  Widget createTable(BuildContext context) {
    final rows = <TableRow>[];
    final columnWidths = <int, TableColumnWidth>{};
    initRows(columnWidths, rows);
    return HorizontalListWidget(
      maxWidth: widget.maxWidth,
      primaryColor: widget.colorScheme.primary,
      controller: _controller,
      fadeLayoutColor:
          ExtraTheme.of(context).messageBackgroundColor(widget.message.from),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
        ),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(12),
            child: Table(
              border: TableBorder.all(
                color: widget.colorScheme.primary,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
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

  void initRows(Map<int, TableColumnWidth> columnWidths, List<TableRow> rows) {
    var columns = <Widget>[];
    final table = widget.message.json.toTable();
    for (final row in table.rows) {
      columns = [];
      for (var i = 0; i < row.columns.length; ++i) {
        columnWidths[i] = table.columnWidths.isNotEmpty
            ? FixedColumnWidth(
                table.columnWidths[i],
              )
            : const IntrinsicColumnWidth();
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
      rows.add(
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
    }
  }
}
