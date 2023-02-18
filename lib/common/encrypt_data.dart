// ignore_for_file: use_build_context_synchronously

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/foundation.dart';
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
    showCircularProgressIndicator(context);
    bool isError = false;
    try {
      final filesDir = await getApplicationSupportDirectory();
      encFilePath =
          '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.aes';
      showSnackBar(context: context, content: 'Encrypting...');
      encFilePath = await compute(
        (Map map) {
          return crypt.encryptFileSync(
            map['srcFilePath'],
            map['encFilePath'],
          );
        },
        {
          'srcFilePath': srcFilePath,
          'encFilePath': encFilePath,
        },
      );
      // crypt.encryptFileSync(srcFilePath, encFilePath);
      final cacheDir = await getTemporaryDirectory();
      cacheDir.deleteSync(recursive: true);
      showSnackBar(
          context: context, content: "Encryption completed successfully");
    } catch (e) {
      encFilePath = null;
      isError = true;
      showSnackBar(
        context: context,
        content: "Something wrong happened. Please try again",
      );
    }
    hideCircularProgressIndicator(context);
    if (!isError) {
      Navigator.of(context).pushNamed(ResultsScreen.routeName);
    }
    return encFilePath;
  }

  static Future<String?> decryptFile(
      BuildContext context, String srcFilePath, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String? decFilePath;
    bool isError = false;
    showCircularProgressIndicator(context);
    try {
      final filesDir = await getApplicationSupportDirectory();
      decFilePath =
          '${filesDir.path}/${srcFilePath.split('/').last.split('.').first}.zip';
      showSnackBar(context: context, content: 'Decrypting...');
      decFilePath = await compute(
        (Map map) {
          return crypt.decryptFileSync(
            map['srcFilePath'],
            map['decFilePath'],
          );
        },
        {
          'srcFilePath': srcFilePath,
          'decFilePath': decFilePath,
        },
      );
      // crypt.decryptFileSync(srcFilePath, decFilePath);
      final cacheDir = await getTemporaryDirectory();
      cacheDir.deleteSync(recursive: true);
      showSnackBar(
          context: context, content: "Decryption completed successfully");
    } catch (e) {
      decFilePath = null;
      isError = true;
      showSnackBar(
          context: context, content: "Incorrect password or corrupted file.");
    }
    hideCircularProgressIndicator(context);
    if (!isError) {
      Navigator.of(context).pushNamed(ResultsScreen.routeName);
    }
    return decFilePath;
  }
}
