import 'package:deliver/box/message.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class BotTableWidget extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  const BotTableWidget({
    Key? key,
    required this.message,
    required this.colorScheme,
    required this.maxWidth,
  }) : super(key: key);

  @override
  State<BotTableWidget> createState() => _BotTableWidgetState();
}

class _BotTableWidgetState extends State<BotTableWidget> {
  final _controller = ScrollController();
  bool _isEndOfTheList = false;
  bool _isFirstOfTheList = true;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (_controller.position.maxScrollExtent > 0) {
        setState(() {});
      }
    });
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.position.pixels) {
        setState(() {
          _isFirstOfTheList = false;
          _isEndOfTheList = true;
        });
      } else if (_controller.position.pixels == 0) {
        setState(() {
          _isFirstOfTheList = true;
          _isEndOfTheList = false;
        });
      } else if (_controller.position.pixels > 0) {
        setState(() {
          _isFirstOfTheList = false;
          _isEndOfTheList = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return createTable(context);
  }

  Widget createTable(BuildContext context) {
    final rows = <TableRow>[];
    final columnWidths = <int, TableColumnWidth>{};
    initRows(columnWidths, rows);
    return Stack(
      alignment: Alignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
          ),
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(24),
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
        if (!_isFirstOfTheList)
          fadeLayout(
            isLeftPosition: true,
          ),
        if (!_isFirstOfTheList)
          arrowIcon(
            arrowIcon: Icons.arrow_back_ios_outlined,
            isLeftPosition: true,
          ),
        if (!_isEndOfTheList) fadeLayout(),
        if (!_isEndOfTheList)
          arrowIcon(
            arrowIcon: Icons.arrow_forward_ios,
          ),
      ],
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
            margin: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                row.columns[i],
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

  Widget arrowIcon({required IconData arrowIcon, bool isLeftPosition = false}) {
    if (_controller.hasClients &&
        _controller.position.viewportDimension >= widget.maxWidth) {
      return Positioned(
        left: isLeftPosition ? 0 : null,
        right: isLeftPosition ? null : 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.colorScheme.primary.withAlpha(100),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: IconButton(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              icon: Icon(
                arrowIcon,
                color: widget.colorScheme.primary,
              ),
              onPressed: () {
                _controller.animateTo(
                  isLeftPosition
                      ? _controller.position.pixels - widget.maxWidth * 0.7
                      : _controller.position.pixels + widget.maxWidth * 0.7,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget fadeLayout({
    bool isLeftPosition = false,
  }) {
    if (_controller.hasClients &&
        _controller.position.viewportDimension >= widget.maxWidth) {
      final color =
          ExtraTheme.of(context).messageBackgroundColor(widget.message.from);
      return Positioned(
        left: isLeftPosition ? 0 : null,
        right: isLeftPosition ? null : 0,
        width: widget.maxWidth * 0.2,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:
                  isLeftPosition ? Alignment.centerLeft : Alignment.centerRight,
              end:
                  isLeftPosition ? Alignment.centerRight : Alignment.centerLeft,
              stops: const [0.0, 0.8, 1.0],
              colors: [
                color,
                color.withAlpha(80),
                color.withAlpha(30),
              ],
            ),
          ),
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
