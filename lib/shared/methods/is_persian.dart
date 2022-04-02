extension IsPersian on String {
  bool isPersian() {
    final temp = trim();
    for (var i = 0; i < temp.length; i++) {
      if (temp[i] == '+' ||
          temp[i] == '-' ||
          temp[i] == '*' ||
          temp[i] == '/' ||
          temp[i] == '!' ||
          temp[i] == '#' ||
          temp[i] == '\$' ||
          temp[i] == '%' ||
          temp[i] == '^' ||
          temp[i] == '&' ||
          temp[i] == '(' ||
          temp[i] == ')' ||
          temp[i] == '_' ||
          temp[i] == '=' ||
          temp[i] == '[' ||
          temp[i] == ']' ||
          temp[i] == '\\' ||
          temp[i] == ';' ||
          temp[i] == '\'' ||
          temp[i] == '"' ||
          temp[i] == '?' ||
          temp[i] == '<' ||
          temp[i] == '>' ||
          temp[i] == '.' ||
          temp[i] == ',' ||
          temp[i] == '``' ||
          temp[i] == '~' ||
          temp[i] == ':' ||
          temp[i] == '{' ||
          temp[i] == ' ' ||
          temp[i] == '}') {
        continue;
      } else {
        final eng = RegExp(r'^[a-zA-Z0-9@]+$');
        return !(eng.hasMatch(temp[i]));
      }
    }
    return false;
  }
}
