import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';

class result extends StatefulWidget {
  final String imageBase64;
  final List<double> err;

  result(this.imageBase64, this.err);

  @override
  _resultState createState() => _resultState();
}

class _resultState extends State<result> {
  Image? image;
  bool isImageFullscreen = false;
  Completer<Null>? _loadImageCompleter;

  @override
  void initState() {
    super.initState();
    _loadImageCompleter = Completer<Null>();
    _loadImageFromBase64String();
  }

  Future<Null> _loadImageFromBase64String() async {
    if (widget.imageBase64 != null && widget.imageBase64.isNotEmpty) {
      image = Image.memory(
        base64Decode(widget.imageBase64),
        fit: BoxFit.contain,
      );
      _loadImageCompleter?.complete();
    }
  }

  void _toggleImageFullscreen() {
    setState(() {
      isImageFullscreen = !isImageFullscreen;
    });
  }

  @override
  void dispose() {
    _loadImageCompleter?.complete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double error = 0;
    widget.err.forEach((element) {
      error = error + (element * element);
    });
    widget.err.sort();
    if(widget.err.length >1){
    error = error-(widget.err[0]*widget.err[0]);}
    error = sqrt(error);
    error = error * 100;
    String err_str = error.toStringAsFixed(4);

    final imageWidget = GestureDetector(
      // onTap: _toggleImageFullscreen,
      child: image == null
          ? Center(child: CircularProgressIndicator())
          : isImageFullscreen
          ? Container(
        child: Image.memory(
          base64Decode(widget.imageBase64),
          fit: BoxFit.contain,
        ),
      )
          : Image.memory(
        base64Decode(widget.imageBase64),
        fit: BoxFit.contain,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Processed Image"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 300,
              child: imageWidget,
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    'Error percentage =',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$err_str %',
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Error Analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height:10 ),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dividerThickness: 3,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text('Edge',style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          ),),
                        DataColumn(
                          label: Text('Error %',style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          color: Colors.red),
                        ),)
                      ],
                      rows: widget.err.asMap().entries.map(
                            (entry) {
                          final edge = entry.key+1;
                          final value = entry.value.abs() * 100;
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text(edge.toString())),
                              DataCell(Text(value.toStringAsFixed(4))),
                            ],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
          ),
        ),
      ),
    );
  }
}
