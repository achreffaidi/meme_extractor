import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folder_picker/folder_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:tflite/tflite.dart';

import 'Helper/sqlHelper.dart';

class ExtractMemes extends StatefulWidget {



  @override
  _ExtractMemesState createState() => _ExtractMemesState();


}



class _ExtractMemesState extends State<ExtractMemes> {

  List<File> lemes ;
  List<Item> memes ;
  Directory folder ;
  ProgressDialog pr ;
  Directory externalDirectory;
  Directory pickedDirectory;
  int selected = 0 ;
  MemesProvider _memesProvider = new MemesProvider();
  bool _database_is_ready = false ;

  void process(File file) async{
    var temp = file.path.split(".") ;
    if(temp.last=="jpg"){
      var recognitions = await Tflite.runModelOnImage(
          path: file.path,   // required
          imageMean: 0.0,   // defaults to 117.0
          imageStd: 255.0,  // defaults to 1.0
          numResults: 2,    // defaults to 5
          threshold: 0.2,   // defaults to 0.1
          asynch: true      // defaults to true
      );
      if(recognitions[0]["index"]==0){
        lemes.add(file);
      }else{
        memes.add(Item(file));
        selected ++ ;
      }

      setState(() {

      });
    }
  }

  @override
  void initState() {
    load();
    memes = new List() ;
    lemes = new List() ;
    init();
    initDataBase();

    super.initState();
  }

  void initDataBase()async{
    _memesProvider.open().then((x){
      _database_is_ready = true ;
      setState(() {

      });
    });
  }


  Future<void> getPermissions() async {
    final permissions =
    await Permission.getPermissionsStatus([PermissionName.Storage]);
    var request = true;
    switch (permissions[0].permissionStatus) {
      case PermissionStatus.allow:
        request = false;
        break;
      case PermissionStatus.always:
        request = false;
        break;
      default:
    }
    if (request) {
      await Permission.requestPermissions([PermissionName.Storage]);
    }
  }

  Future<void> getStorage() async {
    final directory = await getExternalStorageDirectory();

    setState(() {
      externalDirectory = directory;

    });
  }
  Future<void> init() async {
    await getPermissions();
    await getStorage();
  }




  void processList() async {

    var res = await Tflite.loadModel(
        model: "assets/converted_model_v2.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
    );

    List<FileSystemEntity> list = folder.listSync() ;
    int i = 0 ;
    pr = new ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: false);
    pr.style(
      message: 'Processing Images ...',
    );
    pr.show();


    for(FileSystemEntity file in list)  {
      try{

        await process(file) ;
      }catch(e){

      }

      pr.update(  message: "Processing Images ("+(i++).toString()+"/"+list.length.toString()+")");


    }
    pr.hide();
  }
  Widget getItem(Item item) {
    File file = item.file ;
    return
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          child: Card(
            child: Stack(
              children: <Widget>[
                Image.file(file,fit: BoxFit.contain,),
                Positioned(
                    top: 2,
                    right: 2,
                    child: Card(
                        color: Colors.deepPurpleAccent,
                        child: Checkbox(onChanged: (v){
                      if(v){
                        selected++;
                      }else{
                        selected--;
                      }
                      item.checked = v ;

                      setState(() {

                      });
                    },value: item.checked,))),

              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
      Scaffold(
        backgroundColor: Color.lerp(Colors.black, Colors.deepPurple, 0.3),

        appBar: AppBar(title: Text("Extractor"),),
        body:
        Center(
          child: folder==null?
              GestureDetector(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.folder_open,size: 100,color: Colors.grey,),
                    Text("Select Folder",style: TextStyle(fontSize: 30 , color: Colors.grey),)
                  ],
                ),
                onTap: _selectFolder,
              )
          :
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height*0.8,
                  child: GridView.builder(
                    itemCount: memes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
                    itemBuilder: (BuildContext context, int index){

                      return Container(

                          child: getItem(memes[index]));
                    },
                  ),
                ),
                RaisedButton.icon(onPressed: _saveButton, icon: Icon(Icons.save_alt), label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Save ( "+selected.toString()+" Meme )",style: TextStyle(fontSize: 30),),
                ))
              ],
            )),
        ),
        ),

    );
  }

  void _selectFolder() {
    pickAssets() ;
  }



  void pickAssets() async {


    Navigator.of(context).push<FolderPickerPage>(
        MaterialPageRoute(
            builder: (BuildContext context) {
              return FolderPickerPage(
                  pickerIcon: Icon(Icons.album),
                  rootDirectory: externalDirectory,
                  action: (BuildContext context, Directory x) async {
                        setState(() {
                          folder = x ;

                        });
                    Navigator.of(context).pop();

                  });
            })).then((v){
              if(folder!=null) processList();
    });

  }
  void load() async {


    setState(() {

    });
  }




  int itemCount = 0 ;
  void _saveButton() async {

    if(_database_is_ready){

      for(Item item in memes)
      if(item.checked) await _memesProvider.insert(
          Meme(
              item.file.path
          )).then((Meme meme){
        print("saved under id : "+meme.id.toString());
      });
      print("Finish Saving") ;

    }

  }
}


class Item {
  File file ;
  bool checked = true  ;
  int id ;

  Item(File file){
    this.file = file ;
  }
   Item.notChecked(File file , int id ){
    this.file =file ;
    this.checked = false;
    this.id = id ;
  }

  void click(){
    checked = ! checked ;
  }




}
