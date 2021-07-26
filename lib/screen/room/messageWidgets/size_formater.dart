String sizeFormater(int bytes) {
  if (bytes < 1000)
    return bytes.toString() + ' B';
  else if (bytes < 1000000)
    return (bytes / 1000).round().toString() + ' KB';
  else
    return (bytes / 1000000).round().toString() + ' MB';
}
