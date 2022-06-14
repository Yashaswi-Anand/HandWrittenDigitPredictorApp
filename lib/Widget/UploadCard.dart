import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UploadCard extends StatelessWidget {
  const UploadCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Center(
        child: Card(
          color: Colors.brown[100],
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            width: kIsWeb ? 380.0 : 320.0,
            height: 300.0,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DottedBorder(
                      radius: const Radius.circular(12.0),
                      borderType: BorderType.RRect,
                      dashPattern: const [8, 4],
                      color: Colors.brown.withOpacity(0.8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.brown[200],
                              size: 80.0,
                            ),
                            const SizedBox(height: 24.0),
                            const Text(
                              'Upload an image from device',
                              style: TextStyle(color: Colors.brown, fontSize: 15),
                            )
                          ],
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
