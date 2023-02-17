// ignore_for_file: public_member_api_docs, so

import 'package:flutter/material.dart';
import 'package:password_protector/screens/results_screen.dart';
import 'package:password_protector/widgets/decrypt_page.dart';
import 'package:password_protector/widgets/encrypt_page.dart';
import 'package:path_provider/path_provider.dart';

import 'package:password_protector/common/colors.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  int tabIndex;
  String filePath;
  HomeScreen({
    Key? key,
    this.tabIndex = 0,
    this.filePath = '',
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.index = widget.tabIndex;
  }

  @override
  void dispose() async {
    super.dispose();
    tabController.dispose();
    final cacheDir = await getTemporaryDirectory();
    cacheDir.deleteSync(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Password Protector'),
          elevation: 0,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 0,
                  child: Text('Results'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Navigator.of(context).pushNamed(ResultsScreen.routeName);
                    break;
                  case 1:
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: tabController,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            indicatorColor: primaryColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            tabs: const [
              Text(
                'Encrypt',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                'Decrypt',
                style: TextStyle(fontSize: 18),
              ),
            ],
            onTap: (value) {
              setState(() {
                tabController.index = value;
              });
            },
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            EncryptPage(
              zipFilePath: widget.tabIndex == 0 ? widget.filePath : '',
            ),
            DecryptPage(
              zipFilePath: widget.tabIndex == 1 ? widget.filePath : '',
            ),
          ],
        ),
      ),
    );
  }
}
