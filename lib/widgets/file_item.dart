// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:password_protector/common/colors.dart';

// ignore: must_be_immutable
class FileItem extends StatelessWidget {
  String filePath;
  final Widget trailing;
  bool savedFile;
  double elevation;
  FileItem({
    Key? key,
    required this.filePath,
    required this.trailing,
    this.elevation = 5,
    this.savedFile = false,
  }) : super(key: key);

  String getFileSize(int decimals) {
    File file = File(filePath);
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${((bytes / pow(1024, i)).toStringAsFixed(decimals))} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    String fileName = filePath.split('/').last;
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        elevation: elevation,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        backgroundColor: backgroundColor,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15, right: 5),
          leading: const Icon(
            Icons.folder_zip,
            color: primaryColor,
            size: 32,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (savedFile)
                fileName.endsWith('.aes')
                    ? const Text(
                        'encrypted',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        'decrypted',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              Text(
                fileName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                getFileSize(2),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          trailing: trailing),
    );
  }
}
