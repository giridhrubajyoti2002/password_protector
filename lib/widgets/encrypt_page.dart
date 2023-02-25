// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:password_protector/common/encrypt_data.dart';
import 'package:password_protector/common/utils.dart';
import 'package:password_protector/main.dart';
import 'package:password_protector/screens/results_screen.dart';
import 'package:password_protector/widgets/file_item.dart';
import 'package:password_protector/widgets/select_file_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EncryptPage extends StatefulWidget {
  static const String routeName = '/encrypt-page';
  final String zipFilePath;
  const EncryptPage({super.key, this.zipFilePath = ''});

  @override
  State<EncryptPage> createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage>
    with TickerProviderStateMixin {
  bool _isFileSelected = false;
  bool _isPasswordVisible = false;
  late String zipFilePath;
  late TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    zipFilePath = widget.zipFilePath;
    if (zipFilePath.isNotEmpty) {
      _isFileSelected = true;
    }
    _textController = TextEditingController();
  }

  @override
  void dispose() async {
    super.dispose();
    _textController.dispose();
  }

  void selectFile() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      pickFiles();
    } else if (status.isPermanentlyDenied) {
      showSnackBar(
          context: context, content: "Please provide storage permission");
      openAppSettings();
    }
  }

  void pickFiles() async {
    FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
      final filePaths = <String>[];
      for (var file in pickedFiles.files) {
        if (file.path != null) {
          filePaths.add(file.path!);
        }
      }
      Directory cacheDir = await getTemporaryDirectory();
      final time = DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());
      String fileName = filePaths.length == 1
          ? "${filePaths[0].split('/').last.split('.').first}.zip"
          : '$time.zip';
      String zipPath = '${cacheDir.path}/$fileName';
      isolates.kill('createZip');
      isolates.spawn(
        compressToZipFile,
        name: 'createZip',
        onReceive: (String zipPath) {
          zipFilePath = zipPath;
          isolates.kill('createZip');
        },
        onInitialized: () {
          isolates.send({'filePaths': filePaths, 'zipPath': zipPath},
              to: 'createZip');
        },
      );
    } else {
      showSnackBar(context: context, content: 'No files selected.');
    }
    showCircularProgressIndicator(context);
    while (isolates.isolates.containsKey('createZip')) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    hideCircularProgressIndicator(context);
    if (zipFilePath.isNotEmpty) {
      setState(() {
        _isFileSelected = true;
      });
    }
  }

  void encryptFile() async {
    if (_formKey.currentState!.validate()) {
      showSnackBar(context: context, content: 'Encrypting...');
      // isolates.kill('encrypt');
      // isolates.spawn(
      //   EncryptData.encryptFile,
      //   name: 'encrypt',
      //   onReceive: (String filePath) {
      //     encFilePath = filePath;
      //     isolates.kill('encrypt');
      //   },
      //   onInitialized: () {
      //     isolates.send({
      //       'srcFilePath': zipFilePath,
      //       'password': _textController.text.trim(),
      //     }, to: 'encrypt');
      //   },
      // );
      showCircularProgressIndicator(context);

      String encFilePath = await EncryptData.encryptFile(
          zipFilePath, _textController.text.trim());
      // while (isolates.isolates.containsKey('encrypt')) {
      //   await Future.delayed(const Duration(milliseconds: 100));
      // }
      hideCircularProgressIndicator(context);
      if (encFilePath.isNotEmpty) {
        showSnackBar(
            context: context, content: 'Encryption completed successfully.');
        setState(() {
          _textController.text = '';
          _isFileSelected = false;
        });
        Navigator.of(context).pushNamed(ResultsScreen.routeName);
      } else {
        showSnackBar(
          context: context,
          content: "Something wrong happened. Please try again",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _isFileSelected
                ? FileItem(
                    filePath: zipFilePath,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        size: 28,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        zipFilePath = '';
                        setState(
                          () {
                            _isFileSelected = false;
                          },
                        );
                      },
                    ),
                  )
                : SelectFileButton(onPressed: selectFile),
            const SizedBox(
              height: 100,
            ),
            _isFileSelected
                ? Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _textController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            hintText: 'Enter file password',
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password cannot be empty';
                            } else if (value.length < 4) {
                              return 'Password length should be at least 4';
                            } else if (value.length >= 16) {
                              return 'Password length should be maximum 16';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 2),
                        ),
                        child: TextButton(
                          onPressed: encryptFile,
                          child: const Text(
                            'Encrypt',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
