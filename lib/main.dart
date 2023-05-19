import 'package:flutter/material.dart';
import 'package:quality_tester/pages/test.dart';
import 'package:quality_tester/pages/benchmark.dart';
// This is Testing branch
void main() {
  runApp(MaterialApp(
      theme:  ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        accentColor: Colors.amber,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.amber[200],
          selectionHandleColor: Colors.amber[300],
          cursorColor: Colors.amber,
        ),
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        bottomNavigationBarTheme: BottomNavigationBarThemeData(

          backgroundColor: Colors.grey[900], // match scaffold background color
          selectedItemColor: Colors.amber[800], // dark amber accent color
        ),
        cardTheme: CardTheme(
          color: Colors.grey[800],
          elevation: 3,
          margin: EdgeInsets.all(8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey[800],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.amber),
        ),
      ),


      home : home()
  ));
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int index =0;
  final screens = [
    benchmark(),
    test()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: screens[index],
        bottomNavigationBar:NavigationBarTheme(data:  NavigationBarThemeData(
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),

          child: NavigationBar(

              selectedIndex: index,
              onDestinationSelected: (index)=>
                  setState(()=>
                  this.index = index
                  ),


              destinations: const [
                NavigationDestination(icon: Icon(Icons.camera_outlined),
                    selectedIcon: Icon(Icons.camera),
                    label: 'benchmark'),
                NavigationDestination(icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'test')

              ]),)


    );
  }
}
