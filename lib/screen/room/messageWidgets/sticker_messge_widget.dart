import 'package:deliver/box/message.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StickerMessageWidget extends StatefulWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const StickerMessageWidget(
    this.message, {
    Key? key,
    required this.colorScheme,
    required this.isSender,
    required this.isSeen,
  }) : super(key: key);

  @override
  StickerMessageWidgetState createState() => StickerMessageWidgetState();
}

class StickerMessageWidgetState extends State<StickerMessageWidget> {
  // final _fileRepo = GetIt.I.get<FileRepo>();
  // final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Container();
    // FileProto.File stickerMessage = widget.message.json.toFile();
    // i18n = AppLocalization.of(context);
    // return Container(
    //     color:theme.backgroundColor,
    //     child: Stack(
    //       children: [
    //         FutureBuilder<File>(
    //           future:
    //               fileRepo.getFile(stickerMessage.uuid, stickerMessage.name),
    //           builder: (c, sticker) {
    //             if (sticker.hasData && sticker.data != null) {
    //               return GestureDetector(
    //                 child: Image.file(
    //                   File(sticker.data.path),
    //                   width: 200,
    //                   height: 200,
    //                 ),
    //                 onTap: () {
    //                   showDialog(
    //                     context: c,
    //                     builder: (c) {
    //                       return FutureBuilder<StickerPacket>(
    //                         future: _stickerRepo
    //                             .getStickerPackByUUID(stickerMessage.uuid),
    //                         builder: (c, stickerPacket) {
    //                           if (stickerPacket.hasData &&
    //                               stickerPacket.data != null &&
    //                               stickerPacket.data.stickers != null) {
    //                             return AlertDialog(
    //                               title: Container(
    //                                   height: 30,
    //                                   color: Colors.blue,
    //                                   child: Center(
    //                                       child: FutureBuilder<Sticker>(
    //                                     future: _stickerRepo
    //                                         .getSticker(stickerMessage.uuid),
    //                                     builder: (c, packname) {
    //                                       if (packname.hasData &&
    //                                           packname != null) {
    //                                         return Text(packname.data.packName,
    //                                             style: TextStyle());
    //                                       }
    //                                       return SizedBox.shrink();
    //                                     },
    //                                   )
    //                                   )),
    //                               titlePadding: EdgeInsets.only(
    //                                   left: 0, right: 0, top: 0),
    //                               actionsPadding:
    //                                   EdgeInsets.only(bottom: 10, right: 5),
    //                               actions: <Widget>[
    //                                 GestureDetector(
    //                                   child: Text(
    //                                     i18n
    //                                         .getTraslateValue("close"),
    //                                     style: TextStyle(
    //                                         fontSize: 16, color: Colors.blue),
    //                                   ),
    //                                   onTap: () {
    //                                     Navigator.pop(context);
    //                                   },
    //                                 )
    //                               ],
    //                               content: Container(
    //                                 width:
    //                                     MediaQuery.of(context).size.width / 2,
    //                                 height: MediaQuery.of(context).size.height *
    //                                     2 /
    //                                     5,
    //                                 child: Column(
    //                                   children: [
    //                                     Expanded(
    //                                         child: GridView.count(
    //                                       crossAxisCount: 3,
    //                                       children: List.generate(
    //                                           stickerPacket.data.stickers
    //                                               .length, (index) {
    //                                         return GestureDetector(
    //                                             onTap: () {},
    //                                             child: FutureBuilder<File>(
    //                                               future: fileRepo.getFile(
    //                                                   stickerPacket.data
    //                                                       .stickers[index].uuid,
    //                                                   stickerPacket
    //                                                       .data
    //                                                       .stickers[index]
    //                                                       .name),
    //                                               builder: (c, stickerFile) {
    //                                                 if (stickerFile.hasData &&
    //                                                     stickerFile.data !=
    //                                                         null) {
    //                                                   return Stack(
    //                                                       alignment:
    //                                                           AlignmentDirectional
    //                                                               .center,
    //                                                       children: [
    //                                                         GestureDetector(
    //                                                           child: Image.file(
    //                                                             File(stickerFile
    //                                                                 .data.path),
    //                                                             height: 80,
    //                                                             width: 80,
    //                                                             fit: BoxFit
    //                                                                 .cover,
    //                                                           ),
    //                                                           onTap: () {
    //                                                             //todo
    //                                                           },
    //                                                         )
    //                                                       ]);
    //                                                 } else {
    //                                                   return Center(
    //                                                     child:
    //                                                         CircularProgressIndicator(),
    //                                                   );
    //                                                 }
    //                                               },
    //                                             ));
    //                                       }),
    //                                     )),
    //                                     if (!stickerPacket.data.isExit)
    //                                       Center(
    //                                         child: GestureDetector(
    //                                           child: Text(
    //                                             i18n
    //                                                 .getTraslateValue(
    //                                                     "add_sticker"),
    //                                             style: TextStyle(
    //                                                 color:theme
    //                                                     .primaryColor),
    //                                           ),
    //                                           onTap: () {
    //                                             _stickerRepo.saveStickers(
    //                                                 stickerPacket
    //                                                     .data.stickers);
    //                                             Navigator.pop(context);
    //                                           },
    //                                         ),
    //                                       )
    //                                   ],
    //                                 ),
    //                               ),
    //                             );
    //                           } else {
    //                             return Center(
    //                               child: CircularProgressIndicator(),
    //                             );
    //                           }
    //                         },
    //                       );
    //                     },
    //                   );
    //                 },
    //               );
    //             } else {
    //               return SizedBox.shrink();
    //             }
    //           },
    //         ),
    //         TimeAndSeenStatus(widget.message, widget.isSender, true,widget.isSeen)
    //       ],
    //     ));
  }
}
