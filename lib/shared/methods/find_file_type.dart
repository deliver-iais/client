String findFileType(String fileName) {
  int lastDot = fileName.lastIndexOf('.');
  return fileName.substring(lastDot + 1).toUpperCase();
}
