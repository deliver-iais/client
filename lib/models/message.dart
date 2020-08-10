class Message {
  final String text;
  final DateTime sendingTime;

  Message(this.text, this.sendingTime);
}

class SentMessage extends Message {
  SentMessage(String text, DateTime sendingTime, this.status)
      : super(text, sendingTime);
  final int status;
}

class ReceivedMessage extends Message {
  ReceivedMessage(String text, DateTime sendingTime, this.status)
      : super(text, sendingTime);
  final bool status;
}
