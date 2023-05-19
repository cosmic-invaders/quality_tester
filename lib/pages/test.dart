import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class test extends StatefulWidget {
  const test({Key? key,}) : super(key: key);

  @override
  State<test> createState() => _testState();}



class _testState extends State<test> {

  File? image;


  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }



  // final String apiUrl = "https://a48e-203-192-251-182.ngrok.io/imageapi";
  final String apiUrl = "http://10.0.2.2:3000/imageapi";
  String? b64;

  Future sendImage(File imageFile, BuildContext context) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64.encode(imageBytes);

    print(base64Image);
    final Map<String, String> headers = {
      'Content-Type': 'application/json'
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      // handle success

      print('output from here');
      print(response.body);
      this.b64 = response.body;
      // Navigator.of(context).push(MaterialPageRoute(
      //     builder: (context) => segmentation(b64!)));

    } else {
      // handle error
      print('Error sending image: ${response.statusCode}');
    }

  }

  @override
  Widget build(BuildContext context) {
    var assetsImage = new AssetImage('assets/illustration.png');
    var emptyimage = new Image(image: assetsImage, fit: BoxFit.cover);
    // SvgPicture.asset("assets/alarm_icon.svg");
    final size = MediaQuery.of(context).size;

    // Calculate the width and height as a percentage of screen size
    final boxWidth = size.width * 0.75;
    final boxHeight = size.height * 0.4;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Quality test"),
        ),

        body: Center(
          child: Column(

            children: [

              SafeArea(child: Column(
                children: [
                  SizedBox(height: 50,),

                  Container(
                      height: boxHeight, // set the height
                      width: boxWidth,

                      // alignment: Alignment.center,
                      child: FittedBox(fit: BoxFit.contain,

                        child: InteractiveViewer(child:  image != null
                            ? Image.file(image!)
                            : emptyimage,
                        ),)
                  ),


                  SizedBox(height: 100,),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          // color: Colors.red[400],

                            child: const Text(
                                "Pick Image from Gallery",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                )
                            ),
                            onPressed: () {
                              pickImage();
                            }
                        ),
                        SizedBox(width: 20,),
                        ElevatedButton(
                          // color: Colors.red[400],
                            child: const Text(
                                "Pick Image from Camera",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                )
                            ),
                            onPressed: () {
                              pickImageC();
                            }
                        ),
                      ],

                    ),
                  ),
                  image != null
                      ? ElevatedButton(
                    // color: Colors.orange[200],
                      child: const Text(
                          "UPLOAD",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          )
                      ),
                      onPressed: () {
                        sendImage(image!, context);
                      }
                  ) : SizedBox(height: 10,width:10),
                ],
              )),



            ],
          ),
        )
    );
  }
}



