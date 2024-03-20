import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img_lib;

class ScanController extends GetxController{

  late Interpreter interpreter;

  @override
  void onInit() {
    super.onInit();

    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();

  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var cameraCount = 0;
  String showLabel ="";
  var isCameraInitialized = false.obs;

  initCamera() async{
    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = await CameraController(
        cameras[0],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg
      );
      await cameraController.initialize().then((value){

          cameraController.startImageStream((image) {
            cameraCount++;
            if(cameraCount %100 == 0){
              cameraCount=1;
              print("Calling objectDetector");
              objectDetector(image);
            }
            update();
          });
      }
      );
      isCameraInitialized(true);
      update();
    }else{
      print("Permission Denied");
    }
  }

  initTFLite()async{
    interpreter = await Interpreter.fromAsset('assets/best-84-f16.tflite');
    print("Loaded Model");
  }

  objectDetector(CameraImage image) async{
    int startTime = new DateTime.now().millisecondsSinceEpoch;

    print("Running Model");
    // Get Byte Data
    Uint8List imageBytes = image.planes[0].bytes;
    // Decode Image to resize
    img_lib.Image? decodedImg = img_lib.decodeImage(imageBytes);
    // Resize Image
    decodedImg = img_lib.copyResize(decodedImg!, width: 640, height: 640);
    // Get Decoded Bytes
    var decodedBytes = decodedImg?.getBytes(order: img_lib.ChannelOrder.rgb).toList();

    List<double>? standardizedBytes;
    if (decodedBytes != null) {
      standardizedBytes = decodedBytes.map((byte) => byte / 255.0).toList();
    }

    // Get values as RGB
    List<List<List<double>>> imgArr = [];
    for(int y = 0; y < decodedImg!.width; y++) {
      imgArr.add([]);
      for(int x = 0; x < decodedImg.height; x++) {
        double red = standardizedBytes![y*decodedImg.height*3 + x*3];
        double green = standardizedBytes![y*decodedImg.height*3 + x*3 + 1];
        double blue = standardizedBytes![y*decodedImg.height*3 + x*3 + 2];
        imgArr[y].add([red, green, blue]);
      }
    }

    // Transpose Array from 640,640,3 to 3,640,640
    List<List<List<double>>> transposedImgArr = List.generate(3, (_) => List.generate(decodedImg!.height, (_) => List.generate(decodedImg!.width, (_) => 0)));
    for (int y = 0; y < decodedImg!.width; y++) {
      for (int x = 0; x < decodedImg.height; x++) {
        transposedImgArr[0][x][y] = imgArr[x][y][0]; // Red channel
        transposedImgArr[1][x][y] = imgArr[x][y][1]; // Green channel
        transposedImgArr[2][x][y] = imgArr[x][y][2]; // Blue channel
      }
    }

    // if output tensor shape [1,2] and type is float32
    List<dynamic> recognitions = List.filled(100*7, 0).reshape([100,7]);
    int endTime = DateTime.now().millisecondsSinceEpoch;
    // inference
    interpreter.run([transposedImgArr], recognitions);

    print("################################");
    print("Recognitions:");
    recognitions.removeWhere((element) => element[6]<0.25);
    print(recognitions);
    // Iterate through recognitions and extract labels and bounding boxes
    for (int i = 0; i < recognitions.length; i++) {
      // Access each recognition
      List<dynamic> recognition = recognitions[i];

      // Extract individual values from the recognition
      double batchId = recognition[0];
      double x1 = recognition[1];
      double y1 = recognition[2];
      double w = recognition[3];
      double h = recognition[4];
      int classIndex = recognition[5].toInt(); // Assuming classIndex is stored as double
      List<dynamic> lastRecognition = recognitions.last;
      double score = lastRecognition.last;      // Extract label based on class index
      List<String> labels = ['Bench', 'Chair', 'Downstairs','Elevator','Stairs','Table','closedDoor','openedDoor','person' ]; // Replace with your actual labels
      String label = labels[classIndex];
      showLabel += 'label is  $label';
      print('Bounding Box: ($x1, $y1) - ($w, $h), Label: $label, score : $score');
    }

    print('label is ---------------------');
    // print(recognitions[0][5]); // Access label at index 5);
    print("Inference took ${endTime - startTime}ms");

  }

}