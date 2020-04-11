import 'package:flutter/material.dart';

class AboutMe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Me"),),
      backgroundColor: Color.lerp(Colors.black, Colors.deepPurple, 0.3),

      body: Center(child : Text("Made With ♥ by Ashref Faidi" , style: TextStyle(color: Colors.white , fontSize: 50),textAlign: TextAlign.center,),),
    );
  }
}
