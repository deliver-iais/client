import 'package:deliver/shared/methods/file_helpers.dart';

class File {
  String path;
  String name;
  int? size;
  String? extension;
  bool? isVoice;

  File(this.path, this.name, {this.extension, this.size, this.isVoice});
}

class MimeByNameAndContent {
  final String mimeByName;
  final String mimeByContent;

  const MimeByNameAndContent(this.mimeByName, this.mimeByContent);

  bool hasSameMainType() =>
      mimeByName.getMimeMainType() == mimeByContent.getMimeMainType();
}
