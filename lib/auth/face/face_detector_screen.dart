// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class FaceDetectorScreen extends StatefulWidget {
  const FaceDetectorScreen({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<FaceDetectorScreen> createState() => _FaceDetectorScreenState();
}

class _FaceDetectorScreenState extends State<FaceDetectorScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMKey =
      GlobalKey<ScaffoldMessengerState>();
  bool faceDetectorChecking = false;
  XFile? imageFile;
  String facesmiling = "";
  String headRotation = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (faceDetectorChecking)
                const CircularProgressIndicator.adaptive(),
              if (!faceDetectorChecking && imageFile == null)
                Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(15)),
                    width: 300,
                    height: 300,
                    child: Center(
                      child: Text("Pick a Image of a Person Face"),
                    )),
              if (imageFile != null && !faceDetectorChecking)
                Image.file(
                  File(imageFile!.path),
                  width: 350,
                  height: 450,
                  fit: BoxFit.contain,
                ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onPickBtnImgSelected(btnName: 'Camera');
                        },
                        icon: Icon(Icons.camera_alt_rounded),
                        label: Text("Camera"),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  //     child: ElevatedButton.icon(
                  //       onPressed: () {
                  //         onPickBtnImgSelected(btnName: 'Gallary');
                  //       },
                  //       label: Text("Gallary"),
                  //       icon: Icon(Icons.image_rounded),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    facesmiling,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPickBtnImgSelected({required String btnName}) async {
    ImageSource imageSource;
    if (btnName == "Camera") {
      imageSource = ImageSource.camera;
    } else {
      imageSource = ImageSource.gallery;
    }
    final scaffoldstate = _scaffoldMKey.currentState;
    try {
      XFile? file = await ImagePicker().pickImage(source: imageSource);
      if (file != null) {
        faceDetectorChecking = true;
        imageFile = file;
        setState(() {});
        getImageFacedetections(file);
      }
    } catch (e) {
      faceDetectorChecking = false;
      imageFile = null;
      facesmiling = "Error Occured while getting image";
      scaffoldstate?.showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 4),
      ));
      setState(() {});
    }
  }

  void getImageFacedetections(XFile source) async {
    final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true));
    final InputImage inputImage = InputImage.fromFilePath(source.path);

    final List<Face> faces = await faceDetector.processImage(inputImage);
    double? smileprob = 0.0;

    // extract faces
    for (Face face in faces) {
      if (face.smilingProbability != null) {
        smileprob = face.smilingProbability;

        if (smileprob != null && smileprob < 0.45) {
          facesmiling = "You are 😐";
        }
        if (smileprob != null && smileprob >= 0.45) {
          facesmiling = "You are 🙂";
        }
        if (smileprob != null && smileprob >= 0.75) {
          facesmiling = "You are 😀";
        }

        if (smileprob != null && smileprob >= 0.86) {
          facesmiling = "You are 🤣";
        }
      }
    }
    faceDetector.close();
    faceDetectorChecking = false;
    setState(() {});
    
    for (Face face in faces) {
      if (face.smilingProbability != null) {
        smileprob = face.smilingProbability;

        if (smileprob != null && smileprob < 0.45) {
          Timer(
              Duration(seconds: 7),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => SignInScreen())));
        } else {
          snackBar(context, title: 'please authentic face');
        }
        if (smileprob != null && smileprob >= 0.45) {
          print('3');
          // snackBar(context,title: 'please authentic face');

          Timer(
              Duration(seconds: 7),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => SignInScreen())));
        } else {
          snackBar(context, title: 'please authentic face');
        }
        if (smileprob != null && smileprob >= 0.75) {
          print('2');
          snackBar(context, title: 'please authentic face');

          Timer(
              Duration(seconds: 7),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => SignInScreen())));
        } else {
          snackBar(context, title: 'please authentic face');
        }

        if (smileprob != null && smileprob >= 0.86) {
          print('1');
          snackBar(context, title: 'please authentic face');

          Timer(
              Duration(seconds: 7),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => SignInScreen())));
        } else {
          snackBar(context, title: 'please authentic face');
        }
      }
    }
    // Timer(
    //     Duration(seconds: 7),
    //     () => Navigator.of(context).pushReplacement(MaterialPageRoute(
    //         builder: (BuildContext context) => FaceScreen())));
  }
}
