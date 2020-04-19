import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:tflite_test/Helper/sqlHelper.dart';

import '../ExtractMemesUI.dart';

class SavedMemesUI extends StatefulWidget {
  @override
  _SavedMemesUIState createState() => _SavedMemesUIState();
}




class _SavedMemesUIState extends State<SavedMemesUI> {

  List<Item> memes ;
  MemesProvider _memesProvider = new MemesProvider();
  bool _showSelected = false ;
  int selected  = 0  ;


  @override
  void initState() {
    memes = new List() ;
    initDataBase();
    super.initState();
  }

  void initDataBase()async{
    _memesProvider.open().then((x){
      loadMemes();
      setState(() {

      });
    });
  }

  void closeSelected(){
    for(Item x in memes)x.checked = false  ;
    setState(() {
      selected = 0 ;
      _showSelected = false ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.black, Colors.deepPurple, 0.3),

      appBar: _showSelected? AppBar(
        leading: IconButton(icon: Icon(Icons.close , color: Colors.white,), onPressed: closeSelected),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.delete , color: Colors.white,), onPressed: selected ==0?null: _removeSelected),
          IconButton(icon: Icon(Icons.share , color: Colors.white,), onPressed: selected ==0?null:_shareFiles),
        ],
        title: Text("Selected : "+selected.toString(),style: TextStyle(color: Colors.white),),
      ) :  AppBar(
        title: Text("Saved Memes : "+memes.length.toString()+" Meme") ,

      ),
      body: _getBody(),
    );
  }

  _getBody() {
    return Container(
    child: GridView.builder(
      itemCount: memes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
      itemBuilder: (BuildContext context, int index){
        return Container(
            child: getItem(memes[index]));
      },
    ),
    );

  }

  Future loadMemes() async {

     _memesProvider.getAllMemes().then((List<Meme> list){

      if(list!=null)for(Meme m in list){
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

  void removeItemFromTheList(Item item){
    memes.remove(item);
    setState(() {

    });
  }

  Widget getItem(Item item) {
    File file = item.file ;
    return
      GestureDetector(
        onLongPress:(){
         setState((){
           selected = 1 ;
           item.checked = true ;
           _showSelected = true ;
         }) ;

        },
        onTap: (){
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              item ,
              _memesProvider,
              this,!_showSelected
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            child: Card(
              child: Stack(
                children: <Widget>[
                  Image.file(file,fit: BoxFit.contain,),
                  !_showSelected? Container() : Positioned(
                      top: 2,
                      right: 2,
                      child: Card(
                          color: Colors.deepPurpleAccent,

                          child: Checkbox(

                            onChanged: (v){
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
        ),
      );
  }




  void _shareFiles() async {

    Map<String,Uint8List> map = new Map();

    for(Item i in memes){
    if(i.checked) map[i.file.path.split("/").last]=i.file.readAsBytesSync();
    }
    await Share.files(
        'Share with Friends',
        map,
        '*/*');
    closeSelected();
  }


  void _removeSelected() async {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Remove Memes"),
            content: Text("Do you Really Wanna Remove $selected Memes from The List ? "),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Remove"),
                onPressed: () async {
                  for(int i = memes.length-1;i>=0 ; i--){
                    Item x = memes[i];
                    if(x.checked){
                      await _memesProvider.delete(x.id);
                      memes.remove(x);
                    }
                  }
                  setState(() {

                  });

                  closeSelected();
                  Navigator.of(context).pop();

                },
              ),

            ],
          );
        }
    );


  }
}


class CustomDialog extends StatelessWidget {

  final _SavedMemesUIState parent ;
  final Item item ;
  final MemesProvider _memesProvider ;
  final bool showOptions  ;
  CustomDialog(
      this.item,
      this._memesProvider,
      this.parent,
      this.showOptions
  ) ;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Card(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(item.file,width: MediaQuery.of(context).size.width*0.7,fit: BoxFit.fitWidth,),
            )),
            SizedBox(height: 16.0),
            !showOptions?Container():Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

              GestureDetector(
                  onTap: (){
                    deleteItem(item, context);
                  },
                  child: Icon(Icons.delete,size: 40,)),
              Container(color: Colors.grey,width: 3,height: 40,),
              GestureDetector(
                  onTap: (){
                    _shareOneFile(item.file);
                  },
                  child: Icon(Icons.share,size: 40,))
            ],)

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

  void deleteItem(Item item,BuildContext context){
    _memesProvider.delete(item.id).then((val){
      parent.removeItemFromTheList(item);
      Navigator.of(context).pop();
    });
  }
}