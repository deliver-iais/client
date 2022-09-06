String sizeFormatter(int bytes) {
  if (bytes < 1000) {
    return '$bytes B';
  } else if (bytes < 1000000) {
    return '${(bytes / 1000).round()} KB';
  } else {
    return '${(bytes / 1000000).round()} MB';
  }
}
