// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_protector/common/utils.dart';
import 'package:password_protector/screens/home_screen.dart';
import 'package:password_protector/widgets/file_item.dart';
import 'package:password_protector/widgets/loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class ResultsScreen extends ConsumerStatefulWidget {
  static const routeName = '/history';
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  Stream<List<String>> getProtectedFiles() async* {
    final filesDir = await getApplicationSupportDirectory();
    List<String> filePaths = [];
    for (var file in filesDir.listSync()) {
      filePaths.add(file.path);
    }
    yield filePaths;
  }

  bool deleteFile(BuildContext context, String filePath) {
    File file = File(filePath);
    try {
      file.delete();
      showSnackBar(context: context, content: 'File deleted successfully.');
      return true;
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    return false;
  }

  void deleteAllFiles(BuildContext context) async {
    try {
      final filesDir = await getApplicationSupportDirectory();
      filesDir.delete(recursive: true);
      showSnackBar(
          context: context, content: 'All files deleted successfully.');
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void saveToPhone(BuildContext context, String filePath) async {
    final downloadsDirPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
    String appDirPath = '$downloadsDirPath/$applicationFolderName';
    final status = await Permission.accessMediaLocation.request();
    if (status.isGranted) {
      try {
        String fileName = filePath.split('/').last;
        final destFilePath = "$appDirPath/$fileName";
        await File(destFilePath).create(recursive: true);
        File file = File(filePath);
        file.copy(destFilePath);
        showSnackBar(
            context: context,
            content: 'Saved to ../Download/Password_Protector/');
      } catch (e) {
        showSnackBar(context: context, content: e.toString());
      }
    } else if (!status.isGranted) {
      openAppSettings();
    } else {
      showSnackBar(context: context, content: 'Please try again');
    }
  }

  // String rename(String filePath, var renameFormKey, var renameTextController) {
  //   if (renameFormKey.currentState == null) {
  //     print("null");
  //   } else if (renameFormKey.currentState!.validate()) {
  //     Navigator.of(context).pop();
  //     final dirPath = filePath.split('/');
  //     dirPath.removeLast();
  //     String newPath =
  //         "${dirPath.join('/')}/${renameTextController.text.trim()}";
  //     File(filePath).rename(newPath);
  //     filePath = newPath;
  //   }
  //   return filePath;
  // }

  // String renameFile(String filePath) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       final renameFormKey = GlobalKey<FormState>();
  //       final renameTextController = TextEditingController();
  //       renameTextController.text = filePath.split('/').last;
  //       return AlertDialog(
  //         title: const Text(
  //           'Rename',
  //           textAlign: TextAlign.center,
  //         ),
  //         actionsAlignment: MainAxisAlignment.spaceAround,
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Enter new name',
  //               textAlign: TextAlign.left,
  //             ),
  //             const SizedBox(height: 10),
  //             TextFormField(
  //               controller: renameTextController,
  //               key: renameFormKey,
  //               style: const TextStyle(fontSize: 14),
  //               decoration: InputDecoration(
  //                 contentPadding:
  //                     const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //               ),
  //               validator: (value) {
  //                 if (value!.split('.').last != filePath.split('.').last) {
  //                   return 'File extension cannot be changed.';
  //                 }
  //                 return null;
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text(
  //               'Cancel',
  //               style: TextStyle(fontSize: 16),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               filePath =
  //                   rename(filePath, renameFormKey, renameTextController);
  //             },
  //             child: const Text(
  //               'Ok',
  //               style: TextStyle(color: primaryColor, fontSize: 16),
  //             ),
  //           )
  //         ],
  //       );
  //     },
  //   );
  //   return filePath;
  // }

  @override
  Widget build(BuildContext context) {
    List<String> filePaths = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          PopupMenuButton(
            iconSize: 28,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Delete all'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 0:
                  showAlertDialog(
                    context: context,
                    title: 'Delete all files ?',
                    content:
                        'This will delete all the files stored in this application',
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteAllFiles(context);
                          setState(() {
                            filePaths = [];
                          });
                        },
                        child: const Text(
                          'Ok',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: StreamBuilder<List<String>>(
          stream: getProtectedFiles(),
          initialData: const [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            filePaths = snapshot.data!;
            return ListView.builder(
              itemCount: filePaths.length,
              itemBuilder: (context, index) {
                String filePath = filePaths[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: FileItem(
                    elevation: 0,
                    filePath: filePath,
                    savedFile: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Text(filePath.endsWith('.aes')
                                  ? 'Decrypt'
                                  : 'Encrypt'),
                              const SizedBox(width: 10),
                              Icon(filePath.endsWith('.aes')
                                  ? Icons.no_encryption
                                  : Icons.enhanced_encryption),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: const [
                              Text('Save to phone'),
                              SizedBox(width: 10),
                              Icon(Icons.download),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: const [
                              Text('Share'),
                              SizedBox(width: 10),
                              Icon(Icons.share),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Row(
                            children: const [
                              Text('Delete'),
                              SizedBox(width: 10),
                              Icon(Icons.delete),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 0:
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              HomeScreen.routeName,
                              (route) => false,
                              arguments: {
                                'tabIndex': filePath.endsWith('.aes') ? 1 : 0,
                                'filePath': filePath,
                              },
                            );
                            break;
                          case 1:
                            saveToPhone(context, filePath);
                            break;
                          case 2:
                            Share.shareXFiles([XFile(filePath)]);
                            break;
                          case 3:
                            showAlertDialog(
                              context: context,
                              title: 'Are you sure ?',
                              content: 'This will delete the file.',
                              actions: [
                                TextButton(
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    'Ok',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    if (deleteFile(context, filePath)) {
                                      setState(() {
                                        filePaths.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ],
                            );
                            break;
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
