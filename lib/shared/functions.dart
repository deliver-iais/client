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

String findSendingTime(DateTime sendingTime) {
  var now = DateTime.now();
  var difference = now.difference(sendingTime);
  if (difference.inMinutes <= 2) {
    return "just now";
  } else if (difference.inDays < 1 && sendingTime.day == now.day) {
    var min = sendingTime.minute.toString();
    if (sendingTime.minute < 10) min = "0" + min;
    if (sendingTime.hour >= 12) {
      return (sendingTime.hour - 12).toString() + ":" + min + " pm.";
    } else {
      return sendingTime.hour.toString() + ":" + min + " am.";
    }
  } else if (difference.inDays <= 7) {
    switch (sendingTime.weekday) {
      case 1:
        return "Mon.";
      case 2:
        return "Tues.";
      case 3:
        return "Wed.";
      case 4:
        return "Thurs.";
      case 5:
        return "Fri.";
      case 6:
        return "Sat.";
      case 7:
        return "Sun.";
    }
  } else {
    switch (sendingTime.month) {
      case 1:
        return sendingTime.day.toString() + " Jan.";
      case 2:
        return sendingTime.day.toString() + " Feb.";
      case 3:
        return sendingTime.day.toString() + " Mar.";
      case 4:
        return sendingTime.day.toString() + " Apr.";
      case 5:
        return sendingTime.day.toString() + " May";
      case 6:
        return sendingTime.day.toString() + " Jun.";
      case 7:
        return sendingTime.day.toString() + " Jul.";
      case 8:
        return sendingTime.day.toString() + " Aug.";
      case 9:
        return sendingTime.day.toString() + " Sept.";
      case 10:
        return sendingTime.day.toString() + " Oct.";
      case 11:
        return sendingTime.day.toString() + " Nov.";
      case 12:
        return sendingTime.day.toString() + " Dec.";
    }
  }
  return "";
}
