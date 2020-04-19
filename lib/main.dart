import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folder_picker/folder_picker.dart';
import 'package:tflite/tflite.dart';

import 'ExtractMemesUI.dart';
import 'Helper/SavedMemesUI.dart';
import 'Helper/sqlHelper.dart';
import 'aboutmeUI.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMeme',

      theme: ThemeData(

        primarySwatch: Colors.deepPurple,
        backgroundColor: Colors.blueGrey
      ),
      home: MyHomePage(title: 'MyMeme'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Directory externalDirectory;
  Directory pickedDirectory;
  List<Item> memes ;
  MemesProvider _memesProvider = new MemesProvider();


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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    memes = new List() ;
    initDataBase().then((x){
      loadMemes().then((x){
        setState(() {

        });
      });
    });
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
    double buttonWidth = MediaQuery.of(context).size.width*0.6 ;
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


            RaisedButton.icon(onPressed: _extractMemes, icon: Icon(Icons.folder,size: 30,color: Colors.deepOrangeAccent,), label: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(width:  buttonWidth , child: Center(child: Text("Extract Memes" , style: TextStyle(fontSize: 30),))),
            )) ,
            RaisedButton.icon(onPressed: _savedMemes, icon: Center(child: Icon(Icons.favorite,size: 30,color: Colors.redAccent,)), label: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(width:  buttonWidth , child: Center(child: Text("My Memes", style: TextStyle(fontSize: 30),))) ,),),
            RaisedButton.icon(onPressed: memes.isEmpty?null: _randomMemes, icon: Icon(Icons.all_inclusive,size: 30,color: Colors.pink,), label: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(width:  buttonWidth , child: Center(child: Text("Pick Random", style: TextStyle(fontSize: 30),))) ,),)
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
      ).then((v){
        loadMemes().then((x){
          setState(() {

          });
        });
      });

  }

  void _savedMemes() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavedMemesUI()),
      );

  }

  Future initDataBase()async{
    await _memesProvider.open().then((x){
      loadMemes();
      setState(() {

      });
    });
  }


  Future loadMemes() async {

    _memesProvider.getAllMemes().then((List<Meme> list){

     if(list!=null) for(Meme m in list){
        try{
          File f = File(m.path);
          memes.add(Item.notChecked(f,m.id));
          setState(() {

          });
        }catch(e){

        }

      }

    });

  }

  void _randomMemes() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomRandomMemeDialog(
         memes
      ),
    );
  }
}

class CustomRandomMemeDialog extends StatefulWidget {


  List<Item> memes ;

  CustomRandomMemeDialog(
      this.memes,
      ) ;

  @override
  _CustomRandomMemeDialogState createState() => _CustomRandomMemeDialogState(memes);
}

class _CustomRandomMemeDialogState extends State<CustomRandomMemeDialog> {


  List<Item> memes ;
  Item current ;
  var randomizer;



  @override
  Widget build(BuildContext context) {

    Item item = current;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height*0.7,
        padding: EdgeInsets.all(
            20.0
        ),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Stack(
          // To make the card compact
          children: <Widget>[
            Center(
              child: Card(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(item.file,width: MediaQuery.of(context).size.width*0.7,fit: BoxFit.fitWidth,),
              )),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                          onTap: (){
                            generateRandom();
                            setState(() {

                            });
                          },
                          child: Icon(Icons.refresh,size: 40,)),
                      Container(color: Colors.grey,width: 3,height: 40,),
                      GestureDetector(
                          onTap: (){
                            _shareOneFile(item.file);
                          },
                          child: Icon(Icons.share,size: 40,))
                    ],),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  void _shareOneFile(File file) async {

    Map<String,Uint8List> map = new Map();


    map[file.path.split("/").last]=file.readAsBytesSync();

    await Share.files(
        'Share with Friends',
        map,
        '*/*');

  }

  void generateRandom() {
    var num = randomizer.nextInt(memes.length);
    current = memes.elementAt(num);
  }

  _CustomRandomMemeDialogState(List<Item> items){
    memes = items ;
    randomizer = new Random();
    generateRandom() ;
  }
}