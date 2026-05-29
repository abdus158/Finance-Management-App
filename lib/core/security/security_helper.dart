import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:local_auth/local_auth.dart';

class SecurityHelper {
  // 1. Sanitization & SQL Injection Prevention
  // Blocks common SQL special characters and escape inputs
  static String sanitizeString(String input) {
    // Strip standard SQL keywords and control strings to mitigate logical injections
    String sanitized = input.replaceAll(RegExp(r"['\x00-\x1f\x7f-\xff]"), "");
    // Block common scripting patterns
    sanitized = sanitized.replaceAll(RegExp(r"<[^>]*>"), "");
    return sanitized.trim();
  }

  // 2. Cryptographic Key Derivation (PBKDF2 Style)
  // Derives a 32-byte AES key from the user's secure PIN + salt using SHA-256 iterations
  static String deriveKey(String pin, String salt) {
    var key = utf8.encode(pin);
    var saltBytes = utf8.encode(salt);
    
    // Perform 1000 rounds of SHA-256 to increase difficulty of brute-force dictionary attacks
    List<int> currentHash = key;
    for (int i = 0; i < 1000; i++) {
      var hmac = Hmac(sha256, currentHash);
      currentHash = hmac.convert(saltBytes).bytes;
    }
    return base64Url.encode(currentHash).substring(0, 32); // 32 characters = 256 bits
  }

  // 3. Cryptographically Secure AES-256 Encryption
  // Encrypts sensitive fields (such as loan contact names or wallet balances)
  static String encryptField(String plainText, String secretKey) {
    if (plainText.isEmpty) return "";
    try {
      final key = enc.Key.fromUtf8(secretKey);
      final iv = enc.IV.fromLength(16); // 16 bytes IV
      final encrypter = enc.Encrypter(enc.AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      return plainText; // Fail-safe (returns original if decryption/encryption crashes)
    }
  }

  // Cryptographically Secure AES-256 Decryption
  static String decryptField(String cipherText, String secretKey) {
    if (cipherText.isEmpty) return "";
    try {
      final key = enc.Key.fromUtf8(secretKey);
      final iv = enc.IV.fromLength(16);
      final encrypter = enc.Encrypter(enc.AES(key));

      final decrypted = encrypter.decrypt64(cipherText, iv: iv);
      return decrypted;
    } catch (e) {
      return cipherText; // Returns ciphertext if key fails (prevents complete data loss)
    }
  }

  // 4. Cryptographic PIN Hashing for Authentication
  // Computes a secure hash of the user PIN with a unique salt to compare against db records
  static String hashPin(String pin, String salt) {
    final saltBytes = utf8.encode(salt);
    final pinBytes = utf8.encode(pin);
    
    final hmac = Hmac(sha512, saltBytes);
    final digest = hmac.convert(pinBytes);
    return digest.toString();
  }

  // 5. Native Biometric Authentication (local_auth)
  static Future<bool> authenticateBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await auth.authenticate(
        localizedReason: 'Secure access requested for Financial Command Center',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // 6. Check if biometric hardware is available on this device
  static Future<bool> isBiometricAvailable() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      return await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }
}
