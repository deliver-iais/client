import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({Key? key}) : super(key: key);

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final controller = ScrollController();
  final k = const ValueKey(1);

  @override
  Widget build(BuildContext context) {
    Key forwardListKey = UniqueKey();
    Widget forwardList = SliverAnimatedList(
      itemBuilder: _itemBuilder,
      initialItemCount: 0,
      key: forwardListKey,
    );

    Widget reverseList = SliverAnimatedList(
      itemBuilder: _itemBuilder2,
      initialItemCount: 100,
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Endless List'),
        ),
        body: Scrollable(
          controller: controller,
          key: k,
          viewportBuilder: (BuildContext context, ViewportOffset offset) {
            print(offset);
            return Viewport(
                offset: offset,
                anchor: 1,
                axisDirection: AxisDirection.down,
                center: forwardListKey,
                slivers: [
                  reverseList,
                  forwardList,
                ]);
          },
        ),
      ),
    );
  }

  final rnd = Random(42);

  Widget _itemBuilder2(
      BuildContext context, int index, Animation<double> animation) {
    print("2 $index");
    return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 1000), () => ""),
        builder: (context, snapshot) {
          if (!snapshot.hasData || index < 820) {
            Container(
                color: Colors.blue,
                child: Text(index.toString(),
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                margin: const EdgeInsets.all(8),
                width: 100,
                height: 1000);
          }
          return Container(
              color: Colors.blue,
              child: Text(index.toString(),
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
              margin: const EdgeInsets.all(8),
              width: 100,
              height: rnd.nextInt(50) + 40.0);
        });
  }

  Widget _itemBuilder(
      BuildContext context, int index, Animation<double> animation) {
    print("1 $index");
    return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 1000), () => ""),
        builder: (context, snapshot) {
          if (!snapshot.hasData || index < 820) {
            Container(
                color: Colors.red,
                child: Text(index.toString(),
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                margin: const EdgeInsets.all(8),
                width: 100,
                height: 1000);
          }
          return Container(
              color: Colors.red,
              child: Text(index.toString(),
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
              margin: const EdgeInsets.all(8),
              width: 100,
              height: rnd.nextInt(50) + 40.0);
        });
  }
}