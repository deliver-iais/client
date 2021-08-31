import 'package:deliver_flutter/shared/methods/platform.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class ShowCaptionDialog extends StatelessWidget {
  final List<String> result;
  final String type;
  final String name;
  final messageRepo;
  final currentRoom;
  final caption;
  final icon;

  const ShowCaptionDialog(
      {Key key,
      this.result,
      this.type,
      this.name,
      this.messageRepo,
      this.currentRoom,
      this.caption,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthPercent;
    if (isDesktop() || isLinux() || isMacOS()) {
      widthPercent = 0.33;
    } else {
      widthPercent = 0.8;
    }
    return SingleChildScrollView(
      child: Container(
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width * widthPercent,
                padding:
                    EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 20),
                margin: EdgeInsets.only(top: 45),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Selected Files ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "send ${result.length} ${type} to ${name}",
                      style: TextStyle(
                          fontSize: 16,
                          color: ExtraTheme.of(context).fileSharingDetails),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Add a caption",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        controller: caption,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Caption',
                          border: OutlineInputBorder(),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        messageRepo.sendMultipleFilesMessages(
                            currentRoom, result,
                            caption: caption.text.toString());
                      },
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                  child: Text(
                                "Send",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: Colors.blue.shade700, fontSize: 18))),
                    ),
                  ],
                )),
            Positioned(
              left: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 45,
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: Container(
                      color: Colors.blue,
                      width: 60,
                      height: 60,
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    )),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
