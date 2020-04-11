import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folder_picker/folder_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:tflite/tflite.dart';

import 'ExtractMemesUI.dart';
import 'Helper/SavedMemesUI.dart';
import 'aboutmeUI.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
        backgroundColor: Colors.blueGrey
      ),
      home: MyHomePage(title: 'MyMeme'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File _image;
  Directory externalDirectory;
  Directory pickedDirectory;
  Future getImage() async {
   //TODO ffff
  }

  String title = "loading" ;
  String res ;
  void load() async {
    res = await Tflite.loadModel(
        model: "assets/converted_model_v2.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
    );
    title = res ;
    setState(() {

    });
  }
  @override
  void initState() {

    load();
    super.initState();
  }





  Future<Directory> pickAssets() async {


    Navigator.of(context).push<FolderPickerPage>(
        MaterialPageRoute(
            builder: (BuildContext context) {
              return FolderPickerPage(
                  pickerIcon: Icon(Icons.album),
                  rootDirectory: externalDirectory,
                  action: (BuildContext context, Directory folder) async {

                    Navigator.of(context).pop();
                  return folder;
                  });
            }));

    return externalDirectory ;
  }


  Widget getItem(File file){
    return
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Card(
              child: Image.file(file,fit: BoxFit.fitHeight,),
            ),
          ),
        );
  }
  @override
  Widget build(BuildContext context) {
    double pictWidth = MediaQuery.of(context).size.width*0.6 ;

    return Scaffold(
      backgroundColor: Color.lerp(Colors.black, Colors.deepPurple, 0.3),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info , color: Colors.white,), onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutMe()),
            );

          })
        ],
        title: Text(widget.title),
      ),
      body :
      Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset("assets/title.png" ,  width: pictWidth,fit: BoxFit.fitWidth,),
            Image.asset("assets/face.png" , height: pictWidth , width: pictWidth,fit: BoxFit.fill,),
            RaisedButton.icon(onPressed: _extractMemes, icon: Icon(Icons.folder,size: 30,), label: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Extract Memes" , style: TextStyle(fontSize: 30),),
            )) ,
            RaisedButton.icon(onPressed: _savedMemes, icon: Icon(Icons.favorite,size: 30,), label: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("My Memes", style: TextStyle(fontSize: 30),)) ,)
          ],
        ),
      ),

     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  void _extractMemes() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ExtractMemes()),
      );

  }

  void _savedMemes() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavedMemesUI()),
      );

  }


}
