import 'package:deliver/box/message.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class BotTableWidget extends StatelessWidget {
  final Message message;
  final CustomColorScheme colorScheme;

  const BotTableWidget({
    Key? key,
    required this.message,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return createTable();
  }

  Widget createTable() {
    final table = message.json.toTable();
    final rows = <TableRow>[];
    var columns = <Widget>[];
    final columnWidths = <int, TableColumnWidth>{};

    for (final row in table.rows) {
      columns = [];
      for (var i = 0; i < row.columns.length; ++i) {
        columnWidths[i] = FixedColumnWidth(
            table.columnWidths.isNotEmpty ? table.columnWidths[i] : 150,);
        columns.add(
          Container(
            margin: const EdgeInsets.all(8),
            child: Text(
              row.columns[i],
              style: TextStyle(fontWeight: row.bold ? FontWeight.bold : null),
            ),
          ),
        );
      }
      rows.add(
        TableRow(
          children: columns,
          decoration: BoxDecoration(
            color: row.highlight ? colorScheme.primary.withAlpha(150) : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Table(
        border: TableBorder.all(
          color: colorScheme.onPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        columnWidths: columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }
}
