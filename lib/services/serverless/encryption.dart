import 'package:encrypt/encrypt.dart';

class Encryption {
  String key = "";
  static String setKey(String uid) {
    return uid.substring(0 , 32);
  }

  static String encryptText(String text, String uid) {
    final key = setKey(uid);
    final keyBytes = Key.fromUtf8(key);
    final iv = IV.fromLength(16); // Create a 16-byte initialization vector
    final ivString = String.fromCharCodes(iv.base16.codeUnits);
    final encrypter = Encrypter(AES(keyBytes, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: iv);
    final encryptedText = encrypted.base64;

    return (ivString+encryptedText);
  }


  static String decryptText(String encryptedText, String uid) {
    final key = setKey(uid);
    final keyBytes = Key.fromUtf8(key);
    final iv = IV.fromBase16(encryptedText.substring(0 , 32));
    final encrypter = Encrypter(AES(keyBytes, mode: AESMode.cbc));

    final decrypted = encrypter.decrypt64(encryptedText.substring(32), iv: iv);
    return decrypted;

  }

}