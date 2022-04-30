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
          temp[i] == '}' ||
          temp[i] == '0' ||
          temp[i] == '1' ||
          temp[i] == '2' ||
          temp[i] == '3' ||
          temp[i] == '4' ||
          temp[i] == '5' ||
          temp[i] == '6' ||
          temp[i] == '7' ||
          temp[i] == '8' ||
          temp[i] == '9') {
        continue;
      } else {
        final eng = RegExp(r'^[a-zA-Z@]+$');
        return !(eng.hasMatch(temp[i]));
      }
    }
    return false;
  }
}
