// ignore_for_file: use_build_context_synchronously

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:path_provider/path_provider.dart';

class EncryptData {
  static void encryptFile(Map<String, dynamic> context) async {
    final messenger = HandledIsolate.initialize(context);
    messenger.listen((map) async {
      String srcFilePath = map['srcFilePath'] as String;
      String password = map['password'] as String;
      AesCrypt crypt = AesCrypt();
      crypt.setOverwriteMode(AesCryptOwMode.rename);
      crypt.setPassword(password);
      String encFilePath = '';
      try {
        final filesDir = await getApplicationSupportDirectory();
        encFilePath =
            '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.aes';
        crypt.encryptFileSync(srcFilePath, encFilePath);
        final cacheDir = await getTemporaryDirectory();
        cacheDir.deleteSync(recursive: true);
      } catch (e) {
        debugPrint(e.toString());
      }
      messenger.send(encFilePath);
    });
  }

  static void decryptFile(Map<String, dynamic> context) async {
    final messenger = HandledIsolate.initialize(context);
    messenger.listen((map) async {
      String srcFilePath = map['srcFilePath'] as String;
      String password = map['password'] as String;
      AesCrypt crypt = AesCrypt();
      crypt.setOverwriteMode(AesCryptOwMode.rename);
      crypt.setPassword(password);
      String decFilePath = '';
      try {
        final filesDir = await getApplicationSupportDirectory();
        decFilePath =
            '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.aes';
        crypt.decryptFileSync(srcFilePath, decFilePath);
        final cacheDir = await getTemporaryDirectory();
        cacheDir.deleteSync(recursive: true);
      } catch (e) {
        debugPrint(e.toString());
      }
      messenger.send(decFilePath);
    });
  }
}
