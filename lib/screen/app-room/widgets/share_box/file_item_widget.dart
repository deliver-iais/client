import 'package:flutter/material.dart';

import 'helper_classes.dart';

class FileItemWidget extends StatelessWidget {
  final FileItem fileItem;
  final bool selected; 
  final Function onTap; 
  final IconData iconData;

  const FileItemWidget({Key key, @required this.fileItem, @required this.selected, @required this.onTap, @required this.iconData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: selected ? Colors.black12 : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                iconData,
                color: Colors.deepOrange,
                size: 30,
              ),
              onPressed: onTap,
            ),
            SizedBox(
              width: 20,
            ),
            Flexible(
              child: Text(
                fileItem.displayName ??
                    fileItem.album ??
                    fileItem.artist ??
                    fileItem.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}