import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DrawDigit/drawing_page.dart';
import 'package:image_picker/image_picker.dart';
import './pickedImages/imageFromCameraOrGallery.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Digit Predictor", style: TextStyle(fontSize: 30),),
        backgroundColor: Colors.brown[400],
      ),
      body: Container(
        color: Colors.brown[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("The hand written digit recognition aims to classify within the hands written digits(0-9). ", style: TextStyle(color: Colors.brown,
                fontWeight: FontWeight.bold,fontSize: 19),),
              ),
              GestureDetector(
                onTap: (){
                   Get.to(const DrawingPage());
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/edit_icon.png'),
                  radius: 92,
                ),
              ),

              GestureDetector(
                onTap: (){ // imageSourceType: ImageSource.gallery
                  Get.to(ImageFromCameraOrGallery(imageSourceType: ImageSource.gallery));
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/gallery_icon.png'),
                  radius: 100,
                ),
              ),

              GestureDetector(
                onTap: (){// imageSourceType: ImageSource.camera,
                  Get.to(ImageFromCameraOrGallery(imageSourceType: ImageSource.camera));
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/camera.png'),
                  radius: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

