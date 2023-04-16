extension CapExtension on String {
  String get capitalCase => length > 0 ?'${this[0].toUpperCase()}${substring(1)}':'';
  String get upperCase => toUpperCase();
  String get titleCase => replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.capitalCase).join(" ");
}
