import 'package:flutter/material.dart';
import 'package:flutter_1/screens/second_screen.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 116, 160, 196),
        appBar: AppBar(
          title: Center(child: Text("Best App of All Time", style: TextStyle(color: Colors.white),)),
          backgroundColor: const Color.fromARGB(255, 0, 87, 157),
          elevation: 0,
          leading: Icon(Icons.menu, color: Colors.white,),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.logout, color: Colors.white,))],
        ),
        body: Center( 
          child: ElevatedButton(child: Text("Second page"),
          onPressed: () => {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SecondPage()))
          },),
        ),
      ),
    );
  }


}