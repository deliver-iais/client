import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swipedetector/swipedetector.dart';

class MediaDetailsPage extends StatefulWidget {
  String mediaUrl;
  int mediaListLenght;
  int mediaPosition;
  String heroTag;
  List<String> mediaList;
  String mediaSender;
  String mediaTime;

  MediaDetailsPage(
      {Key key,
      this.mediaUrl,
      this.mediaListLenght,
      this.mediaPosition,
      this.heroTag,
      this.mediaList,
      this.mediaSender,
      this.mediaTime})
      : super(key: key);

  @override
  _MediaDetailsPageState createState() => _MediaDetailsPageState();
}

class _MediaDetailsPageState extends State<MediaDetailsPage> {
  bool _showAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              elevation: 0,
              title: Text("${widget.mediaPosition + 1} " +
                  "of" +
                  " ${widget.mediaListLenght}"),
              actions: [
                /*Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                    Icons.more_vert
                ),
              )
          ),*/
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: SwipeDetector(
        child: GestureDetector(
          child: Center(
              child: Hero(
                  tag: widget.heroTag,
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                    imageUrl: widget.mediaUrl,
                  ))),
          onTap: () {
            setState(() {
              _showAppBar = !_showAppBar;
            });
            // Navigator.pop(context);
          },
        ),
        onSwipeLeft: () {
          setState(() {
            widget.mediaUrl = widget.mediaList[widget.mediaPosition + 1];
            widget.mediaPosition = widget.mediaPosition + 1;
          });
        },
        onSwipeRight: () {
          setState(() {
            if (widget.mediaPosition != 0) {
              widget.mediaUrl = widget.mediaList[widget.mediaPosition - 1];
              widget.mediaPosition = widget.mediaList.indexOf(widget.mediaUrl);
            } else
              widget.mediaUrl = widget.mediaList[widget.mediaPosition];
          });
        },
        swipeConfiguration: SwipeConfiguration(
            verticalSwipeMinVelocity: 100.0,
            verticalSwipeMinDisplacement: 50.0,
            verticalSwipeMaxWidthThreshold: 100.0,
            horizontalSwipeMaxHeightThreshold: 50.0,
            horizontalSwipeMinDisplacement: 50.0,
            horizontalSwipeMinVelocity: 500.0),
      ),
      bottomNavigationBar: _showAppBar
          ? BottomAppBar(
              child: GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mediaSender,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Text(widget.mediaTime.split(" ")[0] +
                                " at " +
                                widget.mediaTime.split(" ")[1]),
                          ])),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),
            ))
          : null,
    );
  }
}
