
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'PreviewPage.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}


class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController; // create a CameraController

  late CameraImage img;
   String result= "";
   bool isWorking = false;

   // load the model  of yolov7
  loadModel() async{
    await Tflite.loadModel(
      model: "assets/best-86.tflite",
      labels: "assets/labels.txt",
    );
  }
  // create a method to initialize a selected camera.
   Future initCamera(CameraDescription cameraDescription) async  {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high); //  initialize the controller. This returns a Future.
    try {
      _cameraController.initialize().then((_)  {
        if (!mounted)
          {
            return;
          }
        setState(() {

          _cameraController.startImageStream((imageFromStream) =>
         {
           if(! isWorking){ // camera is not busy
             isWorking =true ,
             img =imageFromStream ,
             RunOnStream(),

           }}
         );
        });
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }
  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {

      return null;
    }

    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => PreviewPage(
            picture: picture,
          )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  RunOnStream () async {
    var recognitions = await Tflite.detectObjectOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(),

        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 0,         // defaults to 127.5
        imageStd: 255.0,      // defaults to 127.5
        // numResults: 2,        // defaults to 5
        threshold: 0.1,       // defaults to 0.1
        numResultsPerClass: 2,// defaults to 5
        anchors: [0.57273,0.677385,1.87446,2.06253,3.33843,5.47434,7.88282,3.52778,9.77052,9.16828],     // defaults to [0.57273,0.677385,1.87446,2.06253,3.33843,5.47434,7.88282,3.52778,9.77052,9.16828]
        blockSize: 32,        // defaults to 32
        numBoxesPerBlock: 5,  // defaults to 5
        asynch: true // defaults to true
    );
    result="";
    recognitions?.forEach((response) {
      result += response["label"]+ " "+ (response["confidence"] as double).toStringAsFixed(2) +"\n\n";
    });
    setState(() {
      result;
    });
    isWorking = false;
  }

  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    loadModel();
    initCamera(widget.cameras![0]);


  }
  @override
  void dispose() async{
    super.dispose();
    await Tflite.close();
    // Dispose of the controller when the widget is disposed.
    _cameraController?.dispose();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            _cameraController.value.isInitialized ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),

            IconButton(
            onPressed: takePicture,
            iconSize: 50,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.photo_camera,
         ),
          ),
            Text(
              result,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
    ],
    ),
    );

  }
}
