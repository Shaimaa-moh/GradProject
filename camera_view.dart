import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigate_in_my_lens/controller/Yolo_controller.dart';
import '../controller/TextController.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1320,
        height: 700,
        child: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CameraPreview(controller.cameraController),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    controller.showLabel,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            )
                : const Center(child: Text("Loading ..."));
          },
        ),
      ),
    );
  }
}
