class File {
  String path;
  String name;
  int? size;
  String? extention;

  File(this.path, this.name, {this.extention, this.size});
}
