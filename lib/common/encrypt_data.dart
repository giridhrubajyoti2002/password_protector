// ignore_for_file: use_build_context_synchronously

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/material.dart';
import 'package:password_protector/common/utils.dart';
import 'package:password_protector/screens/results_screen.dart';
import 'package:path_provider/path_provider.dart';

class EncryptData {
  static Future<String?> encryptFile(
      BuildContext context, String srcFilePath, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String? encFilePath;
    try {
      final filesDir = await getApplicationSupportDirectory();
      encFilePath =
          '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.aes';
      encFilePath = crypt.encryptFileSync(srcFilePath, encFilePath);
      final cacheDir = await getTemporaryDirectory();
      cacheDir.deleteSync(recursive: true);
      showSnackBar(
          context: context, content: "Encryption completed successfully");
      Navigator.of(context).pushNamed(ResultsScreen.routeName);
    } catch (e) {
      encFilePath = null;
      showSnackBar(
        context: context,
        content: "Something wrong happened. Please try again",
      );
    }
    return encFilePath;
  }

  static Future<String?> decryptFile(
      BuildContext context, String srcFilePath, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String? decFilePath;
    try {
      final filesDir = await getApplicationSupportDirectory();
      decFilePath =
          '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.zip';
      decFilePath = crypt.decryptFileSync(srcFilePath, decFilePath);
      final cacheDir = await getTemporaryDirectory();
      cacheDir.deleteSync(recursive: true);
      showSnackBar(
          context: context, content: "Decryption completed successfully");

      Navigator.of(context).pushNamed(ResultsScreen.routeName);
    } catch (e) {
      decFilePath = null;
      showSnackBar(
          context: context, content: "Incorrect password or corrupted file.");
    }
    return decFilePath;
  }
}
