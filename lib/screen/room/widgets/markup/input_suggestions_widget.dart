import 'package:deliver/screen/room/widgets/horizontal_list_widget.dart';
import 'package:flutter/material.dart';

class InputSuggestionsWidget extends StatefulWidget {
  final List<String> inputSuggestions;

  const InputSuggestionsWidget({Key? key, required this.inputSuggestions})
      : super(key: key);

  @override
  InputSuggestionsWidgetState createState() => InputSuggestionsWidgetState();
}

class InputSuggestionsWidgetState extends State<InputSuggestionsWidget> {
  final _controller = ScrollController();
  Size? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NotificationListener(
      onNotification: (notification) {
          setState(() {
            if (mounted && context.findRenderObject() != null) {
              final renderBox = context.findRenderObject() as RenderBox;
              size = renderBox.size;
            }
        });
        return true;
      },
      child: HorizontalListWidget(
        controller: _controller,
        fadeLayoutColor: theme.colorScheme.surface,
        maxWidth: size?.width ?? MediaQuery.of(context).size.width,
        primaryColor: theme.primaryColor,
        child: Container(
          height: 40,
          color: theme.colorScheme.surface,
          child: ListView.separated(
            controller: _controller,
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: VerticalDivider(
                  color: theme.primaryColorLight,
                ),
              );
            },
            scrollDirection: Axis.horizontal,
            itemCount: widget.inputSuggestions.length,
            itemBuilder: (c, i) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.inputSuggestions[i]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
