import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:handwrittendigitpredictor/DrawDigit/drawn_line.dart';
import 'package:handwrittendigitpredictor/DrawDigit/sketcher.dart';
import 'package:handwrittendigitpredictor/FlaskAPI/API.dart';
import 'package:handwrittendigitpredictor/homepage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:handwrittendigitpredictor/homepage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line = DrawnLine([],Colors.white, 0);
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  late Uint8List pngBytes;
  String queryText = '';
  CroppedFile? _croppedFile;

  StreamController<List<DrawnLine>> linesStreamController = StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController = StreamController<DrawnLine>.broadcast();

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

      pngBytes = base64.decode(base64string);
      print("Bytes Arrays: ++++++++++++++");
      print(pngBytes);
    }
  }

  pickedImage() async {

    try {
      var pickedFile = await ImagePicker().pickImage(source:ImageSource.gallery);
      if(pickedFile != null){
        _cropImage(pickedFile);
      }else{
        print("No image is selected.");
      }
    }catch (e) {
      print("error while picking file.");
    }
  }

  Future<void> save() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      // print(image); // size of image
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = byteData!.buffer.asUint8List();
      //print("My drawn bytecode images: $pngBytes ");
      var saved = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: DateTime.now().toIso8601String(),
        isReturnImagePathOfIOS: true,
      );
      pickedImage();
    } catch (e) {
      print(e);
    }
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = DrawnLine([], Colors.white, 0);
    });
  }

  Future<void> predictDigit() async{
    save();
    try{
        String url =  'http://10.0.2.2:5000/api?Query=' + pngBytes.toString();
        print(url);
        var dataAns = await getData(url);
        var decodedData = jsonDecode(dataAns);
        setState(() {
          queryText = decodedData['Query'];
        });
        print("My predicted value $queryText");
    }catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Draw a digit", style: TextStyle(fontSize: 25))),
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Stack(
          children: [
            buildAllPaths(context),
            buildCurrentPath(context),
            buildStrokeToolbar(),
            buildColorToolbar(),
            buildButton(),
            appBarWidget()
          ],
        ),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          //margin: const EdgeInsets.only(top: 56.0,),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                size: const Size(200,200),
                painter: Sketcher(
                  lines: [line],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        //margin: const EdgeInsets.only(top: 56.0,),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // change background from here
        color: Colors.white,
        padding: const EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              size: const Size(200,200),
              painter: Sketcher(
                lines: lines,
              ),
            );
          },
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);

    linesStreamController.add(lines);
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 280.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 100.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Divider(
            height: 20.0,
          ),
          buildClearButton(),
          const Divider(
            height: 20.0,
          ),
          buildSaveButton(),
          const Divider(
            height: 20.0,
          ),
          //buildColorButton(Colors.red),
          buildColorButton(Colors.green),
          buildColorButton(Colors.deepOrange),
          buildColorButton(Colors.black),

        ],
      ),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: const CircleAvatar(
        child: Icon(
          Icons.save,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: const CircleAvatar(
        child: Icon(
          Icons.highlight_remove,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget predictButton(){
    return GestureDetector(
      onTap: predictDigit,
      child: Container(
        margin: const EdgeInsets.all(10),
        // ignore: deprecated_member_use
        child: OutlineButton(
          child: const Text("Predict Digit", style: TextStyle(fontSize: 20.0),),
          highlightedBorderColor: Colors.blue,
          color: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          borderSide: const BorderSide(
              color: Colors.brown,
              width: 3
          ),
          onPressed:  predictDigit,
        ),
      ),
    );
  }

  Widget buildButton() {
    return Positioned(
      top: 760.0,
      left: 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        color: Colors.brown[200],
        child: Center(
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              predictButton(),
              Text(queryText == ''? "Predicted Result":queryText,
                style: const TextStyle(color: Colors.brown, fontSize: 50.0),),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBarWidget() {
    return Positioned(
      top: 0.0,
      left: 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 56,
        color: Colors.brown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: GestureDetector(
                    onTap: (){Get.to(const HomePage());},
                    child: const Icon(Icons.arrow_back, size: 30,color: Colors.white,)
                )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.8,
              child: const Center(child: Text("Draw a digit",style: TextStyle(color: Colors.white, fontSize: 30.0),)),
            ),
          ],
        ),
      ),
    );
  }
}
