import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:handwrittendigitpredictor/FlaskAPI/API.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../Widget/UploadCard.dart';

class ImageFromCameraOrGallery extends StatefulWidget {
  ImageSource imageSourceType;
  ImageFromCameraOrGallery({Key? key,  required this.imageSourceType}) : super(key: key);

  @override
  State<ImageFromCameraOrGallery> createState() => _ImageFromCameraOrGalleryState();
}

class _ImageFromCameraOrGalleryState extends State<ImageFromCameraOrGallery> {

  XFile? imagePath;
  String queryText = '';
  late Uint8List decodedBytes;
  CroppedFile? _croppedFile;
  late bool _loading = false;


  Future<void> _cropImage(var _pickedFile) async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop The Image',
              toolbarColor: Colors.brown,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Crop The Image',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
      File imageFile = File(_croppedFile!.path); //convert Path to File
      Uint8List imageBytes = await imageFile.readAsBytes(); //convert to bytes
      String base64string = base64.encode(imageBytes); //convert bytes to base64 string
      //print(base64string);
      /* Output:
              /9j/4Q0nRXhpZgAATU0AKgAAAAgAFAIgAAQAAAABAAAAAAEAAAQAAAABAAAJ3
              wIhAAQAAAABAAAAAAEBAAQAAAABAAAJ5gIiAAQAAAABAAAAAAIjAAQAAAABAAA
              AAAIkAAQAAAABAAAAAAIlAAIAAAAgAAAA/gEoAA ... long string output
       */

      decodedBytes = base64.decode(base64string);
      print("Bytes Arrays: ++++++++++++++");
      print(decodedBytes);
    }
  }

  openImage() async {

    try {
      var pickedFile = await ImagePicker().pickImage(source: widget.imageSourceType);
      //print("$pickedFile"); // instance of xFile
      //you can use ImageCourse.camera for Camera capture
      if(pickedFile != null){
        _cropImage(pickedFile);
      }else{
        print("No image is selected.");
      }
    }catch (e) {
      print("error while picking file.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Image Prediction", style: TextStyle(fontSize: 25),),
          backgroundColor: Colors.brown,
        ),

        body: Container(
          color: Colors.brown[100],
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
              children: [
                _croppedFile != null ? _image(): const UploadCard(),

                const SizedBox(height: 30,),

                //open button ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlineButton(
                      child: const Text("Select Image", style: TextStyle(fontSize: 20.0),),
                      highlightedBorderColor: Colors.blue,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      borderSide: const BorderSide(
                          color: Colors.brown,
                          width: 3
                      ),
                      onPressed: () {
                        openImage();
                        queryText = "";
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: OutlineButton(
                        child: const Text("Predict Image", style: TextStyle(fontSize: 20.0),),
                        highlightedBorderColor: Colors.blue,
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        borderSide: const BorderSide(
                            color: Colors.brown,
                            width: 3
                        ),
                        onPressed: ()async {
                          String url =  'http://10.0.2.2:5000/api?Query=' + decodedBytes.toString();
                          print(url);
                          var dataAns = await getData(url);
                          var decodedData = jsonDecode(dataAns);
                          setState(() {
                            _loading = true;
                            queryText = decodedData['Query'];
                            if(queryText != '') _loading = false;
                          });

                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                const Text("Predicted Value", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,
                    color: Colors.brown),),
                const SizedBox(height: 30,),
                _loading == false ? Text(queryText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40,
                    color: Colors.brown),) : const CircularProgressIndicator(color:Colors.blue,),
              ]
          ),
        )

    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          //maxWidth: 0.9 * screenWidth,
          maxHeight: 0.5 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else if (imagePath != null) {
      final path = imagePath!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.9 * screenWidth,
          maxHeight: 0.5 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

}


