import 'dart:math';

import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isDebugEnabled() => UxService.isDeveloperMode;

class Debug extends StatelessWidget {
  final String? label;
  final dynamic data;
  late final text = data.toString();

  Debug(this.data, {Key? key, this.label = "VAL"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ToastDisplay.showToast(
            toastText: "copied '${text.substring(0, min(4, text.length))}...'",
            toastContext: context,
          );
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
    Key? key,
    required this.children,
    this.label,
    this.isOpen = false,
  }) : super(key: key);

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
