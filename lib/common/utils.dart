// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

String applicationFolderName = 'Password_Protector';

void showSnackBar({
  required BuildContext context,
  required String content,
}) {
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

void showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required List<Widget> actions,
}) {
  showDialog(
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
}

void showCircularProgressIndicator(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    },
  );
}

void hideCircularProgressIndicator(BuildContext context) {
  Navigator.of(context).pop();
}

Future<String?> pickFiles(BuildContext context) async {
  String? zipFilePath;
  FilePickerResult? pickedFiles =
      await FilePicker.platform.pickFiles(allowMultiple: true);
  if (pickedFiles != null) {
    Directory cacheDir = await getTemporaryDirectory();
    final encoder = ZipFileEncoder();
    final time = DateFormat('dd-MM-yyyy_HH:mm:ss').format(DateTime.now());
    String fileName = pickedFiles.files.length == 1
        ? "${pickedFiles.files[0].name.split('.').first}.zip"
        : '$time.zip';
    encoder.create('${cacheDir.path}/$fileName');
    for (var file in pickedFiles.files) {
      if (file.path != null) {
        encoder.addFile(File(file.path!));
      }
    }
    encoder.close();
    zipFilePath = encoder.zipPath;
    // FilePicker.platform.clearTemporaryFiles();
    // cacheDir.deleteSync(recursive: true);
  } else {
    showSnackBar(context: context, content: "No files selected");
  }
  return zipFilePath;
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
