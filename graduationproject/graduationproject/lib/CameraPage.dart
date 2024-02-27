
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'PreviewPage.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController; // create a CameraController
  // create a method to initialize a selected camera.
  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(cameraDescription, ResolutionPreset.high); //  initialize the controller. This returns a Future.
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }
  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {return null;}
    if (_cameraController.value.isTakingPicture) {return null;}
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
  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    initCamera(widget.cameras![0]);
  }
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
                _cameraController.value.isInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),

            IconButton(
            onPressed: takePicture,
            iconSize: 50,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.photo_camera,
         ),
          ),
    ],
    ),
    );

  }
}
