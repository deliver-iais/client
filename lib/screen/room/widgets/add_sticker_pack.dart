// import 'dart:io';
//
// import 'package:deliver/localization/i18n.dart';
// import 'package:deliver/db/database.dart';
// import 'package:deliver/repository/fileRepo.dart';
// import 'package:deliver/repository/stickerRepo.dart';
// import 'package:deliver/services/routing_service.dart';
// import 'package:deliver_public_protocol/pub/v1/sticker.pb.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
//
// class AddStickerPack extends StatelessWidget {
//   var _stickerRepo = GetIt.I.get<StickerRepo>();
//   var _fileRepo = GetIt.I.get<FileRepo>();
//   var _routingService = GetIt.I.get<RoutingService>();
//
//   AddStickerPack({
//     super.key,
//   });
//
//   AppLocalization _i18n;
//
//   @override
//   Widget build(BuildContext context) {
//     _i18n = AppLocalization.of(context);
//     return Scaffold(
//         appBar: AppBar(
//             title: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 _i18n.get("add_sticker_pack"),
//               ),
//             ),
//             leading: _routingService.backButtonLeading()),
//         body: StreamBuilder<List<StickerId>>(
//             stream: _stickerRepo.getNotDownloadedPackId(),
//             builder: (c, stickersId) {
//               if (stickersId.hasData && stickersId.data != null) {
//                 return Container(
//                   child: Column(
//                     children: [
//                       Flexible(
//                           child: ListView.builder(
//                               itemCount: stickersId.data.length,
//                               itemBuilder: (c, index) {
//                                 return FutureBuilder<StickerPack>(
//                                     future: _stickerRepo
//                                         .downloadStickerPackByPackId(
//                                             stickersId.data[index].packId),
//                                     builder: (c, stickerPck) {
//                                       if (stickerPck.hasData &&
//                                           stickerPck != null) {
//                                         return Column(
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Text(stickerPck.data.name),
//                                                 RaisedButton(
//                                                     child: Text(_i18n
//                                                         .get(
//                                                             "add_sticker_pack")),
//                                                     onPressed: () {
//                                                       _stickerRepo
//                                                           .InsertStickerPack(
//                                                               stickerPck.data);
//                                                     })
//                                               ],
//                                             ),
//                                             Flexible(
//                                                 child: ListView.builder(
//                                                     scrollDirection:
//                                                         Axis.horizontal,
//                                                     itemCount: 3,
//                                                     itemBuilder: (c, i) {
//                                                       return FutureBuilder<
//                                                               File>(
//                                                           future:
//                                                               _fileRepo.getFile(
//                                                                   stickerPck
//                                                                       .data.stickers[0].file
//                                                                       .uuid,
//                                                                   stickerPck
//                                                                       .data.stickers[0]
//                                                                       .file
//                                                                       .name),
//                                                           builder: (c, file) {
//                                                             if (file.hasData &&
//                                                                 file.data !=
//                                                                     null) {
//                                                               return Image.file(
//                                                                 File(file
//                                                                     .data.path),
//                                                                 width: 15,
//                                                                 height: 15,
//                                                               );
//                                                             } else {
//                                                               return SizedBox
//                                                                   .shrink();
//                                                             }
//                                                           });
//                                                     }))
//                                           ],
//                                         );
//                                       } else {
//                                         return SizedBox.shrink();
//                                       }
//                                     });
//                               }))
//                     ],
//                   ),
//                 );
//               }
//               return Center(
//                 child: CircularProgressIndicator(
//                   backgroundColor: Colors.blue,
//                 ),
//               );
//             }));
//   }
// }
