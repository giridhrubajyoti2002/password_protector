import 'package:flutter/material.dart';
import 'package:password_protector/common/colors.dart';

class SelectFileButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SelectFileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: const ListTile(
        leading: ImageIcon(
          AssetImage('assets/icons/file_icon.png'),
          color: primaryColor,
          size: 28,
        ),
        title: Text(
          'Select File',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right_outlined,
          color: primaryColor,
          size: 32,
        ),
      ),
    );
  }
}
