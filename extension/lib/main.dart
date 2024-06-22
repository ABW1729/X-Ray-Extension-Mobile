import 'package:flutter/material.dart';
import 'package:flutter_overlay_window_example/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_overlay_window_example/overlays/messanger_chathead.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    
    if (await Permission.manageExternalStorage.isDenied) {

    debugPrint('no access storage');
    await Permission.manageExternalStorage.request();
    debugPrint('access storage granted');

    }
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MessangerChatHead(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
