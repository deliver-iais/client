class File {
  String path;
  String name;
  int? size;
  String? extension;

  File(this.path, this.name, {this.extension, this.size});
}
