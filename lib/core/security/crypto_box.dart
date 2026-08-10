import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../storage/secure_store.dart';

class CryptoBox {
  late final enc.Key _key;
  late final enc.Encrypter _encrypter;

  CryptoBox._(this._key) {
    _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.gcm));
  }

  static Future<CryptoBox> create() async {
    final keyString = await SecureStore.getFileEncryptionKey();
    final keyBytes = base64Url.decode(keyString);
    final key = enc.Key(Uint8List.fromList(keyBytes));
    return CryptoBox._(key);
  }

  /// Encrypt data (IV is generated randomly and prepended to the ciphertext).
  ///
  /// ملاحظة: يجب أن يُسبَق النص المشفّر بالـ IV العشوائي حتى يمكن فك تشفيره لاحقاً.
  /// كان الإصدار السابق يولّد IV عشوائياً ثم يهمله، بينما يفك التشفير بـ IV أصفار
  /// (IV.fromLength) فيستحيل فك التشفير. الآن يعتمد الزوج على encryptFile/decryptFile
  /// اللتين تُدرجان الـ IV وتستخرجانه بشكل متسق.
  enc.Encrypted encrypt(Uint8List data) {
    return enc.Encrypted(encryptFile(data));
  }

  /// Decrypt data (IV is read from the first 16 bytes of the ciphertext).
  Uint8List decrypt(enc.Encrypted encrypted) {
    return decryptFile(Uint8List.fromList(encrypted.bytes));
  }

  /// Encrypt string
  String encryptString(String plainText) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    // Store IV with encrypted data
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypt string
  String decryptString(String encryptedWithIv) {
    final parts = encryptedWithIv.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted format');
    }
    final iv = enc.IV.fromBase64(parts[0]);
    final encrypted = enc.Encrypted.fromBase64(parts[1]);
    return _encrypter.decrypt(encrypted, iv: iv);
  }

  /// Encrypt file bytes with IV prepended
  Uint8List encryptFile(Uint8List data) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(data, iv: iv);

    // Prepend IV to encrypted data
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setRange(0, iv.bytes.length, iv.bytes);
    result.setRange(iv.bytes.length, result.length, encrypted.bytes);

    return result;
  }

  /// Decrypt file bytes (IV is prepended)
  Uint8List decryptFile(Uint8List encryptedData) {
    if (encryptedData.length < 16) {
      throw ArgumentError('Encrypted data too short');
    }

    // Extract IV
    final iv = enc.IV(encryptedData.sublist(0, 16));
    final encrypted = enc.Encrypted(encryptedData.sublist(16));

    return Uint8List.fromList(_encrypter.decryptBytes(encrypted, iv: iv));
  }

  /// Calculate SHA-256 hash
  static String calculateHash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// Calculate SHA-256 hash from file chunks
  static String calculateHashFromChunks(List<Uint8List> chunks) {
    // Concatenate all chunks and compute hash
    final allBytes = <int>[];
    for (final chunk in chunks) {
      allBytes.addAll(chunk);
    }
    final digest = sha256.convert(allBytes);
    return digest.toString();
  }

  /// Verify hash
  static bool verifyHash(Uint8List data, String expectedHash) {
    final actualHash = calculateHash(data);
    return actualHash == expectedHash;
  }

  /// Generate random IV for testing
  static enc.IV generateIV() {
    return enc.IV.fromSecureRandom(16);
  }
}
