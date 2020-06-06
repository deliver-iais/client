class Message {
  final String text;
  final DateTime sendingTime;
  final bool status;
  final bool isSender;

  Message(this.text, this.sendingTime, this.status, this.isSender);
}