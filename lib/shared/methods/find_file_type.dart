String findFileType(String fileName) {
  final lastDot = fileName.lastIndexOf('.');
  return fileName.substring(lastDot + 1).toUpperCase();
}
