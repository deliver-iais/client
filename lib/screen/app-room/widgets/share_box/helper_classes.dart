class StorageFile {
  final List files;
  final String folderName;

  StorageFile({this.files, this.folderName});

  factory StorageFile.fromJson(Map<String, dynamic> json) {
    return new StorageFile(
        files: json['files'] as List,
        folderName: json['folderName'].toString());
  }
}

class FileItem {
  final String artist;
  final String path;
  final String displayName;
  final String album;
  final String title;

  FileItem({this.artist, this.path, this.displayName, this.album, this.title});
}
