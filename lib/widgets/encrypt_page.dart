// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:password_protector/common/encrypt_data.dart';
import 'package:password_protector/common/utils.dart';
import 'package:password_protector/widgets/loader.dart';
import 'package:password_protector/widgets/select_file_button.dart';
import 'package:permission_handler/permission_handler.dart';

import 'file_item.dart';

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
  bool _isFileLoading = false;
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
      showCircularProgressIndicator(context);
      final filePath = await pickFiles(context);
      if (filePath != null) {
        setState(() {
          zipFilePath = filePath;
          _isFileSelected = true;
        });
      }
      hideCircularProgressIndicator(context);
    } else if (status.isPermanentlyDenied) {
      showSnackBar(
          context: context, content: "Please provide storage permission");
      await Future.delayed(const Duration(seconds: 3));
      openAppSettings();
    }
  }

  void encryptFile() async {
    if (_formKey.currentState!.validate()) {
      String? encFilePath = await EncryptData.encryptFile(
          context, zipFilePath, _textController.text.trim());
      if (encFilePath != null) {
        setState(() {
          _textController.text = '';
          _isFileSelected = false;
        });
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
                        setState(() {
                          _isFileSelected = false;
                        });
                      },
                    ),
                  )
                : _isFileLoading
                    ? const Loader()
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
