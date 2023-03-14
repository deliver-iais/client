import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:flutter/material.dart';

class Debug extends StatelessWidget {
  final String? label;
  final dynamic data;
  late final text = data.toString();

  Debug(this.data, {super.key, this.label = "VAL"});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          saveToClipboard(text);
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: secondaryBorder / 1.2,
            border: Border.all(color: theme.colorScheme.onErrorContainer),
            color: theme.colorScheme.errorContainer,
          ),
          child: Text("$label: $text"),
        ),
      ),
    );
  }
}

class DebugC extends StatefulWidget {
  final String? label;
  final List<Widget> children;
  final bool isOpen;

  const DebugC({
    super.key,
    required this.children,
    this.label,
    this.isOpen = false,
  });

  @override
  State<DebugC> createState() => _DebugCState();
}

class _DebugCState extends State<DebugC> {
  bool isOpen = false;

  @override
  void initState() {
    isOpen = widget.isOpen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isOpen) {
      return Tooltip(
        message: widget.label ?? "",
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: secondaryBorder,
            border: Border.all(width: 2, color: theme.colorScheme.onError),
            color: theme.colorScheme.error,
          ),
          child: IconButton(
            color: theme.colorScheme.onError,
            onPressed: () => setState(() => isOpen = true),
            icon: const Icon(Icons.fullscreen),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(4),
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        borderRadius: secondaryBorder,
        border: Border.all(width: 2, color: theme.colorScheme.onError),
        color: theme.colorScheme.error,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.children,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              color: theme.colorScheme.onError,
              padding: const EdgeInsets.all(2.0),
              iconSize: 16,
              onPressed: () => setState(() => isOpen = false),
              icon: const Icon(Icons.close_fullscreen),
            ),
          ),
        ],
      ),
    );
  }
}
