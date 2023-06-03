import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quality_tester/pages/dimension.dart';
import 'package:hive/hive.dart';

class benchmark extends StatefulWidget {
  const benchmark({Key? key,}) : super(key: key);

  @override
  State<benchmark> createState() => _benchmarkState();}



class _benchmarkState extends State<benchmark> {

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



  final String apiUrl = "https://bae4-203-192-251-163.ngrok-free.app/dimensions";
  // final String apiUrl = "http://10.0.2.2:3001/dimensions";
  String? b64;

  Future sendImage(File imageFile, BuildContext context) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64.encode(imageBytes);

    // print(base64Image);
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
       'Connection': 'keep-alive'
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode({'image': base64Image}),
    );
    if (response.statusCode == 200) {
      // Parse the response JSON
      print(response.body);
      final responseData = json.decode(response.body);

      // Extract the modified Base64 string and array from the response

      this.b64 = responseData['res_image'];
      List dimensions = responseData['dimensions'];
      var box = await Hive.openBox('myDataBox');
      box.put('benchmark', dimensions);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => dimension(b64!)));
    } else {
      // Handle the request failure
      print('Request failed with status: ${response.statusCode}');
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
          title: const Text("Scan the benchmark"),
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



