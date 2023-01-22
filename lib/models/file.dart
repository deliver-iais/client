import 'package:deliver/shared/methods/file_helpers.dart';

class File {
  String path;
  String name;
  int? size;
  String? extension;
  bool? isVoice;

  File(this.path, this.name, {this.extension, this.size, this.isVoice});

  File copyWith({
    String? path,
    String? name,
    int? size,
    String? extension,
    bool? isVoice,
  }) =>
      File(
        path ?? this.path,
        name ?? this.name,
        size: size ?? this.size,
        extension: extension ?? this.extension,
        isVoice: isVoice ?? this.isVoice,
      );
}

class MimeByNameAndContent {
  final String mimeByName;
  final String mimeByContent;

  const MimeByNameAndContent(this.mimeByName, this.mimeByContent);

  bool hasSameMainType() =>
      mimeByName.getMimeMainType() == mimeByContent.getMimeMainType();
}
