// ignore_for_file: use_build_context_synchronously

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class EncryptData {
  static Future<String> encryptFile(String srcFilePath, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String encFilePath = '';
    try {
      final filesDir = await getApplicationSupportDirectory();
      encFilePath =
          '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.aes';
      encFilePath = await compute((Map map) {
        return crypt.encryptFileSync(map['srcFilePath'], map['encFilePath']);
      }, {'srcFilePath': srcFilePath, 'encFilePath': encFilePath});
      final cacheDir = await getTemporaryDirectory();
      cacheDir.deleteSync(recursive: true);
    } catch (e) {
      encFilePath = '';
    }
    return encFilePath;
  }

  static Future<String> decryptFile(String srcFilePath, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String decFilePath = '';
    try {
      final filesDir = await getApplicationSupportDirectory();
      decFilePath =
          '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.zip';
      decFilePath = await compute((Map map) {
        return crypt.decryptFileSync(map['srcFilePath'], map['decFilePath']);
      }, {'srcFilePath': srcFilePath, 'decFilePath': decFilePath});
      final cacheDir = await getTemporaryDirectory();
      cacheDir.deleteSync(recursive: true);
    } catch (e) {
      debugPrint(e.toString());
      decFilePath = '';
    }
    return decFilePath;
  }
}
