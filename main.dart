import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;
import 'package:image_picker/image_picker.dart' as pkr;
import 'package:navigate_in_my_lens/views/camera_view.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraView(), // Change to ImagePickerDemo or CameraView to pick images from gallery or Camera
    );
  }
}


// class MyApp extends StatelessWidget {
//   final TesseractTextRecognizer recognizer = TesseractTextRecognizer();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Tesseract OCR Test'),
//         ),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               final String imagePath = 'assets/tessdata/test2.jpeg';
//               // Call processImage method to extract text from the image
//               final String result = await recognizer.processImage(imagePath);
//
//               // Display the result
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text('Text Extracted from Image'),
//                     content: SingleChildScrollView(
//                       child: Text(result),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Text('Close'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Text('Process Image'),
//           ),
//         ),
//       ),
//     );
//   }
// }
////////////////////////////////////////////////////////////////////
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   FlutterVision vision = FlutterVision();
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     init_Tesseract();
//   }
//
//   Future<void> init_Tesseract() async {
//     try {
//       await vision.loadTesseractModel(
//         args: {
//           'psm': '11',
//           'oem': '1',
//           'preserve_interword_spaces': '1',
//         },
//         language: 'en',
//       );
//       print('Tesseract model loaded successfully');
//     } catch (e) {
//       print('Error initializing Tesseract model: $e');
//     }
//   }
//
//   Future<void> PickImage() async {
//     setState(() {
//       isLoading = true;
//     });
//     final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (photo != null) {
//       try {
//         final result = await vision.tesseractOnImage(bytesList: await photo.readAsBytes());
//         print('OCR Result: $result');
//       } catch (e) {
//         print('Error performing OCR: $e');
//       }
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('OCR EXAMPLE'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           PickImage();
//         },
//         tooltip: 'Pick Image',
//         child: const Icon(Icons.image),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
