// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';

String applicationFolderName = 'Password_Protector';

void showSnackBar({
  required BuildContext context,
  required String content,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    ),
  );
}

Future<dynamic> showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required List<Widget> actions,
}) async {
  final result = showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
        actionsAlignment: MainAxisAlignment.spaceAround,
        // actionsPadding: EdgeInsets.all(5),
      );
    },
  );
  return result;
}

showCircularProgressIndicator(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const Center(child: CircularProgressIndicator());
    },
    barrierDismissible: false,
  );
}

void hideCircularProgressIndicator(BuildContext context) {
  Navigator.of(context).pop();
}

void compressToZipFile(Map<String, dynamic> context) {
  final messenger = HandledIsolate.initialize(context);
  messenger.listen((map) {
    List<String> filePaths = map['filePaths'] as List<String>;
    String zipPath = map['zipPath'] as String;
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    for (var path in filePaths) {
      encoder.addFile(File(path));
    }
    encoder.close();
    messenger.send(zipPath);
  });
}

Future<String?> pickProtectedFile(BuildContext context) async {
  String? filePath;
  FilePickerResult? pickedFiles =
      await FilePicker.platform.pickFiles(allowMultiple: true);
  if (pickedFiles != null) {
    if (pickedFiles.files.length != 1 ||
        !pickedFiles.files[0].name.endsWith('.aes')) {
      showSnackBar(
          context: context,
          content: pickedFiles.files.length != 1
              ? 'Please select single encrypted file'
              : 'Please selece file with .aes extension');
      return null;
    }
    filePath = pickedFiles.files[0].path;
  }
  return filePath;
}
