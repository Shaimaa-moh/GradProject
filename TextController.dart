import 'dart:typed_data';
import 'dart:io';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img_lib;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

class TextController extends GetxController {

  late Interpreter interpreter;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();

  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var cameraCount = 0;

  bool textScan = false;
  XFile ? imageFile;
  String scannedText = "";
  var isCameraInitialized = false.obs;

  initCamera() async {
    if (await Permission.camera
        .request()
        .isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.nv21
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 100 == 0) {
            cameraCount = 1;
            print("Calling objectDetector");
            RecognizeText(image);
          }
          update();
        });
      }
      );
      isCameraInitialized(true);
      update();
    } else {
      print("Permission Denied");
    }
  }


  void RecognizeText(CameraImage image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    Uint8List imageBytes = image.planes[0].bytes;
    InputImageFormat? format = InputImageFormatValue.fromRawValue(image!.format.raw);
    final inputImage = InputImage.fromBytes(
      bytes: imageBytes, metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: format!,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
        print(scannedText);
      }
    }
    int endTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    int totaltime = endTime - startTime;
    print(scannedText);
    print('Total time taken ${totaltime}');
    textScan = false;
  }
}