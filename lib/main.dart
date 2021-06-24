import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    LabelImages(),
  );
}

class LabelImages extends StatefulWidget {
  @override
  _LabelImagesState createState() => _LabelImagesState();
}

class _LabelImagesState extends State<LabelImages> {
  ImagePicker imagePicker;
  File _file;
  String result = '';
  ImageLabeler imageLabeler;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    imageLabeler = GoogleMlKit.vision.imageLabeler();
  }

  imageFromCamera() async {
    PickedFile pickedFile = await imagePicker.getImage(
      source: ImageSource.camera,
    );
    _file = File(
      pickedFile.path,
    );
    setState(() {});
    doImageLabeling();
  }

  imageFormGallery() async {
    PickedFile pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
    );
    _file = File(
      pickedFile.path,
    );
    setState(() {});
    doImageLabeling();
  }

  doImageLabeling() async {
    final inputImage = InputImage.fromFile(_file);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result = '';
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence * 100;
      setState(() {
        result += text + '   ' + confidence.toStringAsFixed(2) + '%' + '\n';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    imageLabeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'images/image.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 100,
                ),
                child: Stack(
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'images/frame.png',
                            height: 250,
                            width: 250,
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: TextButton(
                        onPressed: imageFormGallery,
                        onLongPress: imageFromCamera,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 8,
                          ),
                          child: _file != null
                              ? Image.file(
                                  _file,
                                  width: 150,
                                  height: 225,
                                  fit: BoxFit.fill,
                                )
                              : Container(
                                  width: 150,
                                  height: 225,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[800],
                                      ),
                                      Text(
                                        'Press for Gallery',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Long Press for Camera',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    top: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      '$result',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
