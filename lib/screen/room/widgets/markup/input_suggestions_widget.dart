import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/screen/room/widgets/horizontal_list_widget.dart';
import 'package:flutter/material.dart';

class InputSuggestionsWidget extends StatefulWidget {
  final List<String> inputSuggestions;
  final InputMessageTextController textController;

  const InputSuggestionsWidget({
    Key? key,
    required this.inputSuggestions,
    required this.textController,
  }) : super(key: key);

  @override
  InputSuggestionsWidgetState createState() => InputSuggestionsWidgetState();
}

class InputSuggestionsWidgetState extends State<InputSuggestionsWidget> {
  final _controller = ScrollController();
  double? size;

  @override
  Widget build(BuildContext context) {
    if (widget.inputSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return NotificationListener(
      onNotification: (notification) {
        setState(() {
          if (mounted && context.findRenderObject() != null) {
            final renderBox = context.findRenderObject() as RenderBox?;
            size = renderBox?.size.width;
          }
        });
        return true;
      },
      child: Column(
        children: [
          HorizontalListWidget(
            controller: _controller,
            fadeLayoutColor: theme.colorScheme.surface,
            maxWidth: size ?? MediaQuery.of(context).size.width,
            primaryColor: theme.colorScheme.primary,
            child: Container(
              height: 40,
              color: theme.colorScheme.surface,
              child: ListView.separated(
                controller: _controller,
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.all(8.0),
                    child: VerticalDivider(
                      color: theme.primaryColorLight,
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
                itemCount: widget.inputSuggestions.length,
                itemBuilder: (c, i) {
                  return InkWell(
                    onTap: () {
                      widget.textController.text = widget.inputSuggestions[i];
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(8.0),
                        child: Text(widget.inputSuggestions[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Divider(
            color: theme.primaryColorLight,
          ),
        ],
      ),
    );
  }
}
