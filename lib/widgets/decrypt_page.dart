// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:password_protector/common/encrypt_data.dart';
import 'package:password_protector/common/utils.dart';
import 'package:password_protector/screens/results_screen.dart';
import 'package:password_protector/widgets/select_file_button.dart';
import 'package:permission_handler/permission_handler.dart';

import 'file_item.dart';

class DecryptPage extends StatefulWidget {
  static const String routeName = '/decrypt-page';
  final String zipFilePath;
  const DecryptPage({super.key, this.zipFilePath = ''});

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage>
    with TickerProviderStateMixin {
  bool _isFileSelected = false;
  bool _isPasswordVisible = false;
  late String protectedFilePath;
  late TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    protectedFilePath = widget.zipFilePath;
    if (protectedFilePath.isNotEmpty) {
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
      final filePath = await pickProtectedFile(context);
      if (filePath != null) {
        protectedFilePath = filePath;
        setState(() {
          _isFileSelected = true;
        });
      }
    } else if (status.isPermanentlyDenied) {
      showSnackBar(
          context: context, content: "Please provide storage permission");
      await Future.delayed(const Duration(seconds: 3));
      openAppSettings();
    }
  }

  void decryptFile() async {
    if (_formKey.currentState!.validate()) {
      showSnackBar(context: context, content: 'Decrypting...');
      // isolates.kill('decrypt');
      // isolates.spawn(
      //   EncryptData.decryptFile,
      //   name: 'decrypt',
      //   onReceive: (String filePath) {
      //     decFilePath = filePath;
      //     isolates.kill('decrypt');
      //   },
      //   onInitialized: () {
      //     isolates.send({
      //       'srcFilePath': protectedFilePath,
      //       'password': _textController.text.trim(),
      //     }, to: 'decrypt');
      //   },
      // );
      showCircularProgressIndicator(context);
      String decFilePath = await EncryptData.decryptFile(
          protectedFilePath, _textController.text.trim());
      // while (isolates.isolates.containsKey('decrypt')) {
      //   await Future.delayed(const Duration(milliseconds: 100));
      // }
      hideCircularProgressIndicator(context);
      if (decFilePath.isNotEmpty) {
        showSnackBar(
            context: context, content: 'Decryption completed successfully.');
        setState(() {
          _textController.text = '';
          _isFileSelected = false;
        });
        Navigator.of(context).pushNamed(ResultsScreen.routeName);
      } else {
        showSnackBar(
            context: context, content: "Incorrect password or corrupted file.");
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
                    filePath: protectedFilePath,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        size: 28,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        protectedFilePath = '';
                        setState(() {
                          _isFileSelected = false;
                        });
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
                          onPressed: decryptFile,
                          child: const Text(
                            'Decrypt',
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
