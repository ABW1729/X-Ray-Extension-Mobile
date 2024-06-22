import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_overlay_window_example/loader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_overlay_window_example/response.dart';
import  'package:flutter_overlay_window_example/loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:native_screenshot/native_screenshot.dart';

class MessangerChatHead extends StatefulWidget {
    static GlobalKey previewContainer = GlobalKey();
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead>  {
  Color color = const Color(0xFFFFFFFF);
  BoxShape _currentShape = BoxShape.circle;
    bool isLoading = false;
      Uint8List? _capturedImage;
    final controller=ScreenshotController();
    String base64Image="";
      static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
    String? apiResponse;
    List<String> links=[];
  String? messageFromOverlay;
 
  @override
  void initState() {
    super.initState();
    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameOverlay,
    );
    log("$res : HOME");
    _receivePort.listen((message) {
      log("message from UI: $message");
      setState(() {
        messageFromOverlay = 'message from UI: $message';
      });
    });
  }

    @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Material(
        color: Colors.transparent,
        elevation: 0.0,
        child: GestureDetector(
          onTap: () async {
            if (_currentShape == BoxShape.rectangle) {
              await FlutterOverlayWindow.resizeOverlay(50, 50, true);
              setState(() {
                _currentShape = BoxShape.circle;
              });
            } else {
              await FlutterOverlayWindow.resizeOverlay(
                WindowSize.matchParent,
                WindowSize.matchParent,
                false,
              );
              setState(() {
                _currentShape = BoxShape.rectangle;
              });
            }
            setState(() {
              isLoading = true;
            });
            ByteData bytes = await rootBundle.load('assets/image.png');
            List<int> imageBytes = bytes.buffer.asUint8List();

            base64Image = base64Encode(imageBytes);
            String apiUrl = 'http://192.168.0.103:5000/upload';

            try {
              var response = await http.post(
                Uri.parse(apiUrl),
                body: {
                  'image': base64Image,
                },
              );
              print('Response status: ${response.statusCode}');
               print('Response status: ${response.body}');
      List<dynamic> objects = jsonDecode(response.body)['detected_objects'];
      List<String> productLinks = [];
      List<Widget> productWidgets = [];

      for (int i = 0; i < objects.length; i++) {
        var object = objects[i];
        String amazonLink = object['amazon_link'];
        String base64Image = object['image']; // Remove data:image/jpeg;base64, prefix
        
        // Decode base64 image
        Uint8List decodedImage = base64Decode(base64Image);
        print(decodedImage);
        // Add product link and image widget
       productLinks.add(' $amazonLink');
      }
              setState(() {
                links = productLinks;
              });
              
            } catch (e) {
              print('Error sending image data: $e');
             
            }

            setState(() {
              isLoading = false;
            });
          },
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: _currentShape,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (apiResponse != null)
                     ...links.map((link) => Text(link)).toList()
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void processApiResponse(String responseBody) {
    try {
      // Parse JSON response
      List<dynamic> objects = jsonDecode(responseBody)['detected_objects'];

      List<String> productLinks = [];
      List<Widget> productWidgets = [];

      for (int i = 0; i < objects.length; i++) {
        var object = objects[i];
        String amazonLink = object['amazon_link'];
        String base64Image = object['image'].split(',')[1]; // Remove data:image/jpeg;base64, prefix

        // Decode base64 image
        Uint8List decodedImage = base64Decode(base64Image);

        // Add product link and image widget
        productLinks.add('${i + 1}. $amazonLink');
        productWidgets.add(
          Column(
            children: [
              Text('$amazonLink'), // Product link
              Image.memory(decodedImage), // Decoded image
              SizedBox(height: 20),
            ],
          ),
        );
      }

      // Update UI with product links and images
      setState(() {
        apiResponse = productLinks.join('\n');
      });

    } catch (e) {
      print('Error parsing API response: $e');
    }
  }

    Widget buildProductList() {
    if (apiResponse == null) {
      return Text('Tap to send image and get response');
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(apiResponse!),
        ),
      );
    }
  }
}



  

