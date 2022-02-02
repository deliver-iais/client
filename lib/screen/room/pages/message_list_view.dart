import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({Key? key}) : super(key: key);

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  Widget build(BuildContext context) {
    Key forwardListKey = UniqueKey();
    Widget forwardList = SliverAnimatedList(
      itemBuilder: _itemBuilder,
      initialItemCount: 1,
      key: forwardListKey,
    );

    Widget forwardList2 = SliverAnimatedList(
      itemBuilder: _itemBuilder,
      initialItemCount: 1,
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
          viewportBuilder: (BuildContext context, ViewportOffset offset) {
            print(offset);
            return Viewport(
                offset: offset,
                axisDirection: AxisDirection.down,
                center: forwardListKey,
                slivers: [
                  reverseList,
                  forwardList,
                  forwardList2,
                ]);
          },
        ),
      ),
    );
  }

  final rnd = Random(42);

  Widget _itemBuilder2(
      BuildContext context, int index, Animation<double> animation) {
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
