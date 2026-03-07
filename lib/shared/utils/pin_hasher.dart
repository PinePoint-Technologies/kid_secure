import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinHasher {
  static String hash(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();

  static bool verify(String pin, String hashed) => hash(pin) == hashed;
}
