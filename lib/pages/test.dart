import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quality_tester/pages/result.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';


class test extends StatefulWidget {
  const test({Key? key,}) : super(key: key);

  @override
  State<test> createState() => _testState();}



class _testState extends State<test> {
  bool _isLoading = false;

  File? image;




  void showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }





  // final String apiUrl = "https://bae4-203-192-251-163.ngrok-free.app/dimensions";
  final String apiUrl = "http://10.0.2.2:3001/dimensions";
  String? b64;


  Future sendImage(File imageFile, BuildContext context) async {
    setState(() {
      _isLoading = true; // Set loading state to true before starting the async task
    });
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64.encode(imageBytes);

    // print(base64Image);
    final Map<String, String> headers = {
      'Content-Type': 'application/json'
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode({'image': base64Image}),
    );
    if (response.statusCode == 200) {
      // Parse the response JSON
      // print(response.body);
      final responseData = json.decode(response.body);

      // Extract the modified Base64 string and array from the response

      this.b64 = responseData['res_image'];
      final test_dim = responseData['dimensions'];
      var box = await Hive.openBox('myDataBox');
      List ben_dim = box.get('benchmark', defaultValue: []);

      List<List<dynamic>> zipped = List.generate(
        ben_dim.length,
            (index) => [ben_dim[index], test_dim[index]],
      );
      List<double> err = [];

      zipped.forEach((pair) {
        double ben = pair[0];
        double tes = pair[1];
        double res = ((ben-tes)/ben)as double;
        err.add(res);
      });
      print(err);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => result(b64!,err)));
    } else {
      // Handle the request failure
      String errorMessage = 'Request failed with status ${response.statusCode}';
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      print('Request failed with status: ${response.statusCode}');
    }
    setState(() {
      _isLoading = false; // Set loading state to true before starting the async task
    });
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
          title: const Text("Scan the Deformation"),
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
                          onPressed: () {
                            // Button action
                            showOptionsDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Set the border radius

                            ),
                            elevation: 2,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFA68F28), // Darker yellow color
                                  Color(0xFF918F65), // Dull yellow color
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Container(
                              width: 200, // Specify the desired width of the button
                              height: 40,

                              alignment: Alignment.center,
                              child: Text(
                                'Select Test Image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),


                      ],

                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  image != null
                      ?  Stack(
                    children: [
                      if (!_isLoading)
                        ElevatedButton(
                          onPressed: () {
                            // Button action
                            sendImage(image!,context);
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Set the border radius

                              ),
                              elevation: 5
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                // gradient: LinearGradient(
                                //   colors: [Color(0xFF37474F), Color(0xFF78909C)],
                                //   begin: Alignment.topCenter,
                                //   end: Alignment.bottomCenter,
                                // ),
                                color: Colors.blue

                            ),
                            child: Container(
                              width: 200, // Specify the desired width of the button
                              height: 40,

                              alignment: Alignment.center,
                              child:Row(children: [
                                SizedBox(
                                  width: 50,
                                ),
                                Icon(
                                  Icons.cloud_upload, // Replace with your desired icon
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Upload',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),],),
                            ),
                          ),
                        ),
                      if (_isLoading)
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ): SizedBox(height: 10,width:10),
                ],
              )),

            ],
          ),
        )
    );
  }
}



