// import 'dart:io';
//
// import 'package:deliver_flutter/db/database.dart';
// import 'package:deliver_flutter/repository/fileRepo.dart';
//
// import 'package:deliver_flutter/repository/stickerRepo.dart';
// import 'package:deliver_flutter/screen/room/widgets/share_box.dart';
// import 'package:deliver_flutter/services/routing_service.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
//
// class StickerWidget extends StatefulWidget {
//   final Function onStickerTap;
//
//   @override
//   _StickerWidgetState createState() => _StickerWidgetState();
//
//   StickerWidget({this.onStickerTap,});
// }
//
// class _StickerWidgetState extends State<StickerWidget> {
//   var _fileRepo = GetIt.I.get<FileRepo>();
//   var _stickerRepo = GetIt.I.get<StickerRepo>();
//   var _routingServices = GetIt.I.get<RoutingService>();
//
//   @override
//   void initState() {
//     _stickerRepo.addSticker();
//     super.initState();
//   }
//
//   String _currentPackId = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: FutureBuilder<List<StickerId>>(
//       future: _stickerRepo.getStickersId(),
//       builder: (c, stickersId) {
//         if (stickersId.hasData && stickersId.data != null) {
//           List<StickerId> downloadedPacketId =
//               _getDownlodedPackId(stickersId.data);
//           if (_currentPackId.isEmpty)
//             _currentPackId = downloadedPacketId[0].packId;
//           return Column(
//             children: [
//               Container(
//                 height: 50,
//                 child: Row(
//                   children: [
//                     if (downloadedPacketId.length > 0)
//                       Flexible(
//                         child: ListView.builder(
//                             itemCount: downloadedPacketId.length,
//                             scrollDirection: Axis.horizontal,
//                             itemBuilder: (c, index) {
//                               return FutureBuilder<Sticker>(
//                                   future: _stickerRepo.getFirstStickerFromPack(
//                                       downloadedPacketId[index].packId),
//                                   builder: (c, sticker) {
//                                     if (sticker.hasData &&
//                                         sticker.data != null) {
//                                       return FutureBuilder<File>(
//                                           future: _fileRepo.getFile(
//                                               sticker.data.uuid,
//                                               sticker.data.name),
//                                           builder: (c, stickerFile) {
//                                             if (stickerFile.hasData &&
//                                                 stickerFile != null)
//                                               return GestureDetector(
//                                                   onTap: () {
//                                                     setState(() {
//                                                       _currentPackId =
//                                                           downloadedPacketId[
//                                                                   index]
//                                                               .packId;
//                                                     });
//                                                   },
//                                                   child: Stack(
//                                                       alignment:
//                                                           AlignmentDirectional
//                                                               .center,
//                                                       children: [
//                                                         Image.file(
//                                                           File(stickerFile
//                                                               .data.path),
//                                                           height: 25,
//                                                           width: 25,
//                                                           fit: BoxFit.cover,
//                                                         )
//                                                       ]));
//                                             else {
//                                               return SizedBox.shrink();
//                                             }
//                                           });
//                                     } else {
//                                       return SizedBox.shrink();
//                                     }
//                                   });
//                             }),
//                       ),
//                     CircleButton(() {
//                       _routingServices.openAddStickerPcakPage();
//                     }, Icons.add, "", 30, context: c),
//                   ],
//                 ),
//               ),
//               FutureBuilder<List<Sticker>>(
//                   future: _stickerRepo.getStickerPackByPackId(_currentPackId),
//                   builder: (c, stickers) {
//                     if (stickers.hasData && stickers.data != null)
//                       return Flexible(
//                         child: GridView.count(
//                           crossAxisCount: 3,
//                           children:
//                               List.generate(stickers.data.length, (index) {
//                             return FutureBuilder<File>(
//                                 future: _fileRepo.getFile(
//                                     stickers.data[index].uuid,
//                                     stickers.data[index].name),
//                                 builder: (c, stickerFile) {
//                                   if (stickerFile.hasData &&
//                                       stickerFile != null) {
//                                     return GestureDetector(
//                                         onTap: () {
//                                           widget.onStickerTap(
//                                               stickers.data[index]);
//                                         },
//                                         child: Stack(
//                                             alignment:
//                                                 AlignmentDirectional.center,
//                                             children: [
//                                               Image.file(
//                                                 File(stickerFile.data.path),
//                                                 height: 80,
//                                                 width: 80,
//                                                 fit: BoxFit.cover,
//                                               )
//                                             ]));
//                                   } else
//                                     return Center(
//                                       child: CircularProgressIndicator(),
//                                     );
//                                 });
//                           }),
//                         ),
//                       );
//                     else
//                       return Center(
//                         child: CircularProgressIndicator(
//                           backgroundColor: Colors.blue,
//                         ),
//                       );
//                   }),
//             ],
//           );
//         } else {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//       },
//     ));
//   }
//
//   List<StickerId> _getDownlodedPackId(List<StickerId> stickersId) {
//     List<StickerId> downloadStickerPackId = [];
//     for (var stickerid in stickersId) {
//       if (stickerid.packISDownloaded) {
//         downloadStickerPackId.add(stickerid);
//       }
//     }
//     return downloadStickerPackId;
//   }
// }
