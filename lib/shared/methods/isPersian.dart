extension IsPersian on String {
  bool isPersian() {
    // RegExp exp = new RegExp(r"^([\u0600-\u06FF]+\s?)+$");
    // return exp.hasMatch(this.trim());

    String temp = this.trim();
    for (var i = 0; i < temp.length; i++) {
      // print(temp);
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
          temp[i] == '\"' ||
          temp[i] == '?' ||
          temp[i] == '<' ||
          temp[i] == '>' ||
          temp[i] == '.' ||
          temp[i] == ',' ||
          temp[i] == '``' ||
          temp[i] == '~' ||
          temp[i] == ':' ||
          temp[i] == '{' ||
          temp[i] == '}') {
        continue;
      } else {
        RegExp eng = RegExp(r'^[a-zA-Z0-9]+$');
        // print(eng.hasMatch(temp[i]).toString() + ' ' + temp);
        return !(eng.hasMatch(temp[i]));
      }
    }
    return false;
    // RegExp exp = new RegExp(r"^([\u0600-\u06FF]+\s?)+$");
  }
}
