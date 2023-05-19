import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class result extends StatefulWidget {
  final String imageBase64;
  final List<double> err;

  result(this.imageBase64,this.err);

  @override
  _resultState createState() => _resultState();
}

class _resultState extends State<result> {
  late Image image;

  @override
  void initState() {
    super.initState();
    _loadImageFromBase64String();
  }

  Future<Null> _loadImageFromBase64String() async {
    if (widget.imageBase64 != null && widget.imageBase64.isNotEmpty) {
      setState(() {
        image = Image.memory(
          base64Decode(widget.imageBase64),
          fit: BoxFit.contain,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double error=0;
    widget.err.forEach((element) {
      error = error + (element*element);
    });
    error = sqrt(error);
    error = error * 100;
    String err_str = error.toStringAsFixed(4);

    return Scaffold(
      appBar: AppBar(
        title: Text("Processed Image"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Column(
                  children:[
                  InteractiveViewer(child: image == null
                      ? Center(child: CircularProgressIndicator())
                      : image,),
                    SizedBox(height: 30,),
                    SelectableText(
                      'Error percentage : $err_str %',
                      style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.yellow),
                    ),
                    ]
              ),
            ),

          ],
        ),
      ),
    );
  }
}
