class Message {
  final String text;
  final DateTime sendingTime;

  Message(this.text, this.sendingTime);
}

class SendedMessage extends Message {
  SendedMessage(String text, DateTime sendingTime, this.status)
      : super(text, sendingTime);
  final int status;
}

class RecievedMessage extends Message {
  RecievedMessage(String text, DateTime sendingTime, this.status)
      : super(text, sendingTime);
  final bool status;
}
