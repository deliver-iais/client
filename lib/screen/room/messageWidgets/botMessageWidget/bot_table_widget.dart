import 'package:deliver/box/message.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';

class BotTableWidget extends StatelessWidget {
  final Message message;

  const BotTableWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return createTable();
  }

  Widget createTable() {
    var table = message.json.toTable();
    List<TableRow> rows = [];
    List<Widget> columns = [];
    Map<int, TableColumnWidth>? columnWidths = {};

    for (var row in table.rows) {
      columns = [];
      for (int i = 0; i < row.columns.length; ++i) {
        columnWidths[i] = FixedColumnWidth(table.columnWidths[i]);
        columns.add(Container(
          margin: const EdgeInsets.all(8),
          color: row.highlight ? Colors.yellow : null,
          child: Text(
            row.columns[i],
            style: TextStyle(fontWeight: row.bold ? FontWeight.bold : null),
          ),
        ));
      }
      rows.add(TableRow(
        children: columns,
        decoration: const BoxDecoration(),
      ));
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Table(
          border: TableBorder.all(
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows),
    );
  }
}
