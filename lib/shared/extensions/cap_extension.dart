extension CapExtension on String {
  String get capitalCase => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get upperCase => this.toUpperCase();
  String get titleCase => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.capitalCase).join(" ");
}