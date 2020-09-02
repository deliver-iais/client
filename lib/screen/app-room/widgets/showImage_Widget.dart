import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowImagePage extends StatefulWidget {
  final File imageFile;
  final String contactUid;

  const ShowImagePage({Key key, this.imageFile, this.contactUid})
      : super(key: key);

  @override
  _ImageWidget createState() => _ImageWidget();
}

class _ImageWidget extends State<ShowImagePage> {
  TextEditingController controller;

  File image;

  @override
  Widget build(BuildContext context) {
   AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        floatingActionButton: new FloatingActionButton(
          child: Icon(
            Icons.send,
            color: Colors.blueAccent,
          ),
          onPressed: (){
            // TODO add file sending function
//            uploadFile.uploadFile(widget.imageFile.path);
          },
          splashColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Text(
            widget.contactUid,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Stack(
          children: <Widget>[
            Hero(
              tag: widget.imageFile.path,
              child: Container(
                // color: Colors.black12,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.file(widget.imageFile).image,
                      fit: BoxFit.cover),
                ),
              ),
            ),
            Container(
              color: Colors.black12,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextField(
                    minLines: 2,
                    maxLines: 15,
                    textInputAction: TextInputAction.send,
                    controller: controller,
                    onSubmitted: null,
                    onChanged: (str) {
                      setState(() {});
                    },
                    decoration:
                    InputDecoration.collapsed(hintText: appLocalization.getTraslateValue("typeSomeThing")),
                  ),
                ],
              )

            )
          ],
        ));
  }
}
