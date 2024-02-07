import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

class Encryption {

  String key = 'your_secret_key_12345'; // Use a strong, unique key

  String encryptText(String text) {
    final keyBytes = Key.fromUtf8(key);
    final iv = IV.fromLength(16); // Create a 16-byte initialization vector
    final encrypter = Encrypter(AES(keyBytes, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(text, iv: iv);
    final encryptedText = encrypted.base64; // Encode as Base64 for easier storage
    return encryptedText;
  }

  String decryptText(String encryptedText) {
    final keyBytes = Key.fromUtf8(key);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(keyBytes, mode: AESMode.cbc));

    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

}